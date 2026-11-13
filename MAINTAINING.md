# 運用メモ

## 取り込み元の一覧

日野市のオープンデータカタログは CKAN ではなく自前の CGI（`/cgi-opd/opendata.cgi`）で、
機械可読な一覧の出口がありません。そのため種別を推定せず、公開ページと CSV の URL を
`hino_datasets.yml` に直接持っています。URL が変わったらそこを直します。

## 施設情報ファイルの結合

施設情報ファイルを取得できなかったときと、取得できたのに施設_ID が突合しなかったときは、
住所と座標を欠いたまま公開することになるため `status` に `degraded` を記録します。
本体の行自体は取れているので公開は止めません。一方、本体ファイルの取得や様式の判定に
失敗したときは 0 行で公開してしまわないよう、`tests/source_files_ingested.sql` が
ビルドを落とします。

## ビルド

```bash
uv sync
bash scripts/build.sh
```

`scripts/build.sh` は公開中のバージョンを `fdl checkout` してから取り込み・ビルドし、`fdl commit` と `fdl push` で公開します（`shared/scripts/build-fdl.sh`）。手元では `FDL_TOKEN` に Queria の API トークンを入れます。GitHub Actions では Queria のトークンを OIDC で取得します。`uv run dbt run` / `uv run dbt build` を直接実行すると作業カタログが作られないので使いません。

SQL の検証には `queria sql` を使います。
