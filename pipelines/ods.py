"""日野市が公開する自治体標準オープンデータセット (ODS) の取り込み。

hino_datasets.yml に定義した種別ごとに CSV をダウンロードし、ヘッダーを標準キーに
正規化して data/ods/<id>.ndjson に出力する。取得結果（成功・失敗・理由）は
data/ods/source_files.ndjson に記録し、1ファイルの失敗で全体を止めない。

日野市のカタログは CKAN ではなく自前 CGI（/cgi-opd/opendata.cgi）で API を持たない。
種別を推定する余地がないので、設定に URL を直接書いて取りに行く。

定義書 B の施設・設備分離型（防災行政無線・公営駐輪場・投票所・ゴミ集積所）は
本体ファイルが住所と座標を持たない。併走する 132128_facility.csv を施設_ID で
結合して補う。

データソース: 日野市オープンデータ
https://www.city.hino.lg.jp/opendata/
"""

import csv
import json
import logging
import re
import time
import unicodedata
from dataclasses import dataclass, field
from datetime import UTC, datetime
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

import yaml

logger = logging.getLogger("pipelines")

# 素の urllib は名乗らないと 403 を返すホストがあるため、必ず UA を付ける
USER_AGENT = "dataset-hino (+https://github.com/queria-io/dataset-hino)"

# 同一ホストへの最小リクエスト間隔（秒）。取りに行くのは24本だけなので控えめでよい
REQUEST_INTERVAL = 0.5

# 5xx / 接続断のリトライ回数
MAX_RETRIES = 2

# ヘッダー行とみなす条件: 先頭 N 行のうち、既知ヘッダーが M 個以上並ぶ最初の行
HEADER_SCAN_ROWS = 5
HEADER_MIN_MATCHES = 2

DEFAULT_REQUIRED_COLUMNS = ["name", "address"]
DEFAULT_IDENTITY_COLUMN = "name"

# 施設ファイルから本体へ移す標準キー。facility_id は結合キーなので移さない。
# facility_lat / facility_lon は本体の lat / lon が空のときだけ座標として使う
FACILITY_FILL_KEYS = [
    "address", "prefecture", "city", "town", "town_id", "street_number",
    "building_name", "postal_code", "phone_number", "available_days",
    "start_time", "end_time", "available_notes", "url", "poi_code",
]


@dataclass
class OdsDataset:
    """hino_datasets.yml の1エントリ（データセット種別）。"""

    id: str
    title: str
    page: str
    url: str
    as_of: str
    # 正規化済みヘッダー名 → 標準キー（先勝ちのため列挙順を保持した dict）
    header_map: dict[str, str]
    required_columns: list[str]
    identity_column: str
    facility_url: str | None = None
    facility_header_map: dict[str, str] = field(default_factory=dict)


def normalize_header(header: str) -> str:
    """CSV ヘッダー名を照合用に正規化する（BOM・引用符・空白・改行の除去、NFKC）。"""
    s = header.replace("﻿", "").strip().strip('"').strip("'")
    s = unicodedata.normalize("NFKC", s)
    return re.sub(r"\s+", "", s)


def _build_header_map(columns: list[dict]) -> dict[str, str]:
    header_map: dict[str, str] = {}
    for column in columns:
        for source in column["source"]:
            header_map.setdefault(normalize_header(source), column["key"])
    return header_map


def load_config(path: str = "hino_datasets.yml") -> list[OdsDataset]:
    config = yaml.safe_load(Path(path).read_text(encoding="utf-8"))
    facility_header_map = _build_header_map(config["facility_columns"])
    datasets = []
    for entry in config["datasets"]:
        datasets.append(
            OdsDataset(
                id=entry["id"],
                title=entry["title"],
                page=entry["page"],
                url=entry["url"],
                as_of=entry["as_of"],
                header_map=_build_header_map(entry["columns"]),
                required_columns=entry.get("required_columns", DEFAULT_REQUIRED_COLUMNS),
                identity_column=entry.get("identity_column", DEFAULT_IDENTITY_COLUMN),
                facility_url=entry.get("facility_url"),
                facility_header_map=facility_header_map,
            )
        )
    return datasets


class _Throttle:
    """最小リクエスト間隔を保証する。"""

    def __init__(self, interval: float = REQUEST_INTERVAL):
        self._interval = interval
        self._last = 0.0

    def wait(self) -> None:
        elapsed = time.monotonic() - self._last
        if elapsed < self._interval:
            time.sleep(self._interval - elapsed)
        self._last = time.monotonic()


def _fetch(url: str, throttle: _Throttle) -> bytes:
    """CSV を取得する。5xx・接続断は指数バックオフで再試行、4xx は即失敗。"""
    for attempt in range(MAX_RETRIES + 1):
        throttle.wait()
        try:
            req = Request(url, headers={"User-Agent": USER_AGENT})
            with urlopen(req, timeout=60) as resp:
                return resp.read()
        except (HTTPError, URLError, TimeoutError) as e:
            status = getattr(e, "code", None)
            retryable = status is None or status >= 500
            if not retryable or attempt == MAX_RETRIES:
                raise
            time.sleep(2**attempt)
    raise AssertionError("unreachable")


def _decode(data: bytes) -> tuple[str, str]:
    """バイト列を (テキスト, エンコーディング名) で返す。

    日野市の CSV は UTF-8 BOM 付きだが、原課が差し替えたときに cp932 が混ざりうる。
    cp932 は UTF-8 バイト列を誤って受理するため、必ず utf-8 を先に試す。
    """
    if data[:2] in (b"\xff\xfe", b"\xfe\xff"):
        return data.decode("utf-16"), "utf-16"
    for encoding in ("utf-8-sig", "cp932"):
        try:
            return data.decode(encoding), encoding
        except UnicodeDecodeError:
            continue
    return data.decode("utf-8", errors="replace"), "utf-8(replace)"


def _find_header(rows: list[list[str]], header_map: dict[str, str]) -> int | None:
    """既知ヘッダーが並ぶ最初の行番号を返す（タイトル行・注釈行のスキップ用）。"""
    for i, row in enumerate(rows[:HEADER_SCAN_ROWS]):
        matches = sum(1 for cell in row if normalize_header(cell) in header_map)
        if matches >= HEADER_MIN_MATCHES:
            return i
    return None


def _normalize_rows(
    rows: list[list[str]],
    header_index: int,
    header_map: dict[str, str],
    identity_column: str | None,
) -> tuple[list[dict], list[str]]:
    """ヘッダーを標準キーにマッピングし、1行=1dict に正規化する。

    どの標準キーにもマッチしないヘッダーの値は _extras に退避する。
    標準キーは先勝ち（同じキーに複数ヘッダーがマッチしたら最初の列を採用）。
    識別列が空の行は実体を持たないため落とす（表末尾のバージョン表記など）。
    """
    header = rows[header_index]
    key_by_index: dict[int, str] = {}
    extra_by_index: dict[int, str] = {}
    mapped: set[str] = set()
    for i, cell in enumerate(header):
        normalized = normalize_header(cell)
        key = header_map.get(normalized)
        if key and key not in mapped:
            key_by_index[i] = key
            mapped.add(key)
        elif normalized:
            extra_by_index[i] = normalized

    records = []
    for row in rows[header_index + 1 :]:
        record: dict = {}
        extras: dict = {}
        for i, cell in enumerate(row):
            value = cell.strip()
            if not value:
                continue
            if i in key_by_index:
                record[key_by_index[i]] = value
            elif i in extra_by_index:
                extras[extra_by_index[i]] = value
        if identity_column and not record.get(identity_column):
            continue
        if extras:
            record["_extras"] = extras
        records.append(record)
    return records, sorted(mapped)


def _read_csv(data: bytes, header_map: dict[str, str], identity_column: str | None):
    """バイト列を (レコード列, マップできた標準キー, エンコーディング) にする。

    ヘッダー行が見つからないときはレコード列に None を返す。呼び出し側が
    理由を source_files.ndjson に記録して次の種別へ進めるようにするため。
    """
    text, encoding = _decode(data)
    rows = list(csv.reader(text.splitlines()))
    header_index = _find_header(rows, header_map)
    if header_index is None:
        return None, [], encoding
    records, mapped = _normalize_rows(rows, header_index, header_map, identity_column)
    return records, mapped, encoding


def _merge_facility(records: list[dict], facility_records: list[dict]) -> int:
    """施設ファイルの住所・座標を本体レコードへ施設_ID で結合する。

    本体側が値を持つ列は上書きしない。座標は本体の lat / lon が両方とも
    空のときだけ施設側の値を採用する（原典が持つ座標を消さないため）。
    戻り値は結合できた行数。
    """
    by_id = {r["facility_id"]: r for r in facility_records if r.get("facility_id")}
    joined = 0
    for record in records:
        facility = by_id.get(record.get("facility_id", ""))
        if facility is None:
            continue
        joined += 1
        for key in FACILITY_FILL_KEYS:
            if not record.get(key) and facility.get(key):
                record[key] = facility[key]
        if not record.get("lat") and not record.get("lon"):
            if facility.get("facility_lat") and facility.get("facility_lon"):
                record["lat"] = facility["facility_lat"]
                record["lon"] = facility["facility_lon"]
        if not record.get("name") and facility.get("facility_name"):
            record["name"] = facility["facility_name"]
    return joined


def download_and_normalize(
    config_path: str = "hino_datasets.yml", dest_dir: str = "data/ods"
) -> None:
    """対象 CSV をダウンロードして種別ごとの NDJSON に正規化する。

    失敗は1種別単位で隔離し、source_files.ndjson に理由を記録して続行する。
    """
    dest = Path(dest_dir)
    dest.mkdir(parents=True, exist_ok=True)

    datasets = load_config(config_path)
    throttle = _Throttle()
    fetched_at = datetime.now(UTC).isoformat()

    with (dest / "source_files.ndjson").open("w", encoding="utf-8") as source_files:

        def log_source(dataset: OdsDataset, **fields):
            entry = {
                "dataset_id": dataset.id,
                "dataset_title": dataset.title,
                "url": dataset.url,
                "page": dataset.page,
                "as_of": dataset.as_of,
                "fetched_at": fetched_at,
                **fields,
            }
            source_files.write(json.dumps(entry, ensure_ascii=False) + "\n")

        for dataset in datasets:
            out_path = dest / f"{dataset.id}.ndjson"
            try:
                data = _fetch(dataset.url, throttle)
            except Exception as e:
                logger.info(f"  failed: {dataset.id} ({e})")
                log_source(dataset, status="failed", reason=f"fetch_error: {e}")
                out_path.write_text("", encoding="utf-8")
                continue

            # CSV を装った zip/xlsx（PK マジック）はテキストとして扱えないため隔離
            if data[:4] == b"PK\x03\x04":
                log_source(dataset, status="skipped", reason="not_csv: zip/xlsx content")
                out_path.write_text("", encoding="utf-8")
                continue

            records, mapped, encoding = _read_csv(
                data, dataset.header_map, dataset.identity_column
            )
            if records is None:
                log_source(
                    dataset, status="skipped", reason="header_mismatch", encoding=encoding
                )
                out_path.write_text("", encoding="utf-8")
                continue

            # 住所と座標を欠いたまま公開すると地図に出ない行が黙って増えるので、
            # 施設ファイルを取れなかった場合も、取れたのに結合できなかった場合も
            # degraded として記録に残す
            joined = None
            degraded_reason = None
            if dataset.facility_url:
                try:
                    facility_data = _fetch(dataset.facility_url, throttle)
                    facility_records, _, _ = _read_csv(
                        facility_data, dataset.facility_header_map, identity_column=None
                    )
                except Exception as e:
                    logger.info(f"  facility fetch failed: {dataset.id} ({e})")
                    facility_records = None
                if facility_records is None:
                    degraded_reason = "facility_unavailable"
                else:
                    joined = _merge_facility(records, facility_records)
                    # 結合で埋まった列を必須列の判定に含める
                    mapped = sorted({key for r in records for key in r if not key.startswith("_")})
                    if records and joined == 0:
                        degraded_reason = "facility_join_empty"
                    elif joined < len(records):
                        degraded_reason = f"facility_join_partial: {joined}/{len(records)}"

            # 種別の必須列を取れないファイルは様式が変わったとみなして隔離する
            missing = [c for c in dataset.required_columns if c not in mapped]
            if missing:
                log_source(
                    dataset,
                    status="skipped",
                    reason=f"required_columns_missing: {missing}",
                    encoding=encoding,
                )
                out_path.write_text("", encoding="utf-8")
                continue

            with out_path.open("w", encoding="utf-8") as writer:
                for record in records:
                    record["_as_of"] = dataset.as_of
                    record["_source_url"] = dataset.url
                    record["_source_page"] = dataset.page
                    record["_fetched_at"] = fetched_at
                    writer.write(json.dumps(record, ensure_ascii=False) + "\n")

            fields = {
                "status": "degraded" if degraded_reason else "ok",
                "encoding": encoding,
                "row_count": len(records),
            }
            if degraded_reason:
                fields["reason"] = degraded_reason
            if joined is not None:
                fields["facility_joined"] = joined
            log_source(dataset, **fields)
            suffix = f", {joined} joined" if joined is not None else ""
            if degraded_reason:
                suffix += f" (degraded: {degraded_reason})"
            logger.info(f"  {dataset.id}: {len(records)} rows{suffix}")
