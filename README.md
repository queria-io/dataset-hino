# dataset-hino

東京都日野市が公開している自治体標準オープンデータセットを、Queria のカタログ
（[data.queria.io](https://data.queria.io/)）へ取り込むデータセットです。

## データ出典

[日野市オープンデータ](https://www.city.hino.lg.jp/opendata/)が公開している CSV を、
デジタル庁のデータセット定義書の様式のまま収録しています。ライセンスは CC BY 4.0 です。

日野市のオープンデータカタログは CKAN ではなく自前の CGI（`/cgi-opd/opendata.cgi`）で、
機械可読な一覧の出口がありません。そのため種別を推定せず、公開ページと CSV の URL を
`hino_datasets.yml` に直接持っています。URL が変わったらそこを直します。

## 収録テーブル

`ods` スキーマに18種別 + 取り込み結果の1本。1テーブル=1種別です。

| テーブル | 内容 | 行数 | データ時点 |
| --- | --- | ---: | --- |
| `public_facility` | 公共施設 | 727 | 2024-03-28 |
| `garbage_separation` | ゴミの分別方法（1行=1品目） | 826 | 2024-03-28 |
| `care_service` | 介護サービス事業所 | 306 | 2024-03-28 |
| `emergency_radio` | 防災行政無線 | 123 | 2024-03-28 |
| `population` | 地域・年齢別人口 | 110 | 2022-04-01 |
| `aed` | AED設置箇所 | 107 | 2024-03-28 |
| `public_toilet` | 公衆トイレ | 96 | 2024-03-28 |
| `cultural_property` | 文化財 | 90 | 2024-03-28 |
| `preschool` | 子育て施設 | 57 | 2024-03-28 |
| `evacuation_space` | 緊急避難場所 | 51 | 2024-03-28 |
| `bicycle_parking` | 公営駐輪場 | 45 | 2024-03-28 |
| `polling_place` | 投票所 | 30 | 2024-03-28 |
| `school_district` | 小中学校通学区域 | 26 | 2024-03-28 |
| `educational_institution` | 教育機関 | 24 | 2024-03-28 |
| `public_wireless_lan` | 公衆無線LAN | 6 | 2024-03-28 |
| `event` | イベント | 5 | 2024-03-28 |
| `fire_hydrant` | 消防水利施設 | 2 | 2024-03-28 |
| `garbage_collection_place` | ゴミ集積所 | 1 | 2024-03-28 |
| `source_files` | 取り込みの実行結果 | 18 | — |

行数は 2026-09-11 時点の実測です。`fire_hydrant` と `garbage_collection_place` の
行数が少ないのは取り込みの欠落ではなく、原典の CSV がその件数で公開されているためです。
テーブルの中身が少ないときは `source_files` の `status` と `row_count` を見ると、
原典がそうなのか取り込みで落ちたのかを切り分けられます。

## 列の揃え方

列名は東京都オープンデータカタログを取り込んだ `metro_tokyo` の `ods` スキーマと
揃えてあります。同じ列名で近隣自治体と並べて集計できます。

座標は3種類の列で表します。`lat` / `lon` は原典の値をそのまま残し、地図に使える座標を
`geo_lat` / `geo_lon` に入れ、採用した値の由来を `geo_source` に持ちます。
日野市の CSV は原典の座標がそのまま使えるため、座標を持つ行の `geo_source` は `source` です。
住所を非公開にしている文化財のように原典が座標を持たない行では、`geo_lat` / `geo_lon` /
`geo_source` / `geometry` がいずれも NULL になります。

`as_of` は日野市が公開ページに掲げている「データ時点」で、ファイルの取得日ではありません。

## 施設・設備分離型の結合

防災行政無線・公営駐輪場・投票所・ゴミ集積所の4種別は、データセット定義書Bの
施設・設備分離型で公開されていて、本体のファイルが住所と座標を持ちません。
併走する施設情報ファイル（`132128_facility.csv`）を施設_ID で結合して補っています。

結合は本体側が空の列だけを埋め、原典が持つ値は上書きしません。結合できた行数は
`source_files` の `facility_joined` で確認できます。

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

`queria sync`（pull → ビルド → push）が走ります。`uv run dbt run` / `uv run dbt build` を
直接実行すると DuckLake カタログとの不整合が起きるので使いません。

書き込みはすべて Queria が発行する資格情報を要するため、ローカルだけで完結する経路は
ありません。公開せずに通しで確かめたいときは、queria-cli の `tools/rotate.py` を
スタンドインに対して回します（手順は `queria-cli/tools/README.md`）。

SQL の検証には `queria sql` を使います。

## ライセンス

収録データは日野市の [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) です。
