# 日野市

東京都日野市が公開する自治体標準オープンデータセット 18 種類を、SQL で検索・集計できるテーブルにしたデータセットです。公共施設・AED・緊急避難場所・介護サービス事業所・子育て施設・文化財・投票所・ゴミの分別方法などを、デジタル庁のデータセット定義書の様式のまま収録しています。

## 出典と利用条件

- [日野市オープンデータ](https://www.city.hino.lg.jp/opendata/)が公開している CSV を加工して作成しています
- ライセンスは [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) です

## テーブル

`ods` スキーマに 18 種類と、取り込みの結果のテーブルがあります。1 テーブルが 1 種類です。

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

行数は 2026-09-11 時点です。データ時点は日野市が公開ページに掲げている値で、ファイルの取得日ではありません（各行の `as_of`）。

## 使い方

日野市と都内の区市町村の AED の数を並べる（`metro_tokyo` の `ods` スキーマと列名を合わせています）:

```sql
SELECT org, count(*) AS aeds
FROM (
  SELECT '日野市' AS org, name FROM hino.ods.aed
  UNION ALL
  SELECT org_title, name FROM metro_tokyo.ods.aed
)
GROUP BY ALL
ORDER BY aeds DESC;
```

## 列

- 全国地方公共団体コード・所在地・緯度経度・法人番号・町字 ID は、Queria の語彙の名前の列（`local_government_code`・`full_address`・`latitude`・`longitude`・`legal_entity_number`・`street_address_id`）で持ちます。同じ値の `municipality_code`・`address`・`lat`・`lon`・`corporate_number`・`town_id` は非推奨で、当面は残します
- `latitude`・`longitude` は原典の値のままです。地図に表示するときは、Queria が付与した `geo_lat`・`geo_lon` を使ってください。採用した値の由来は `geo_source` にあります
- 住所を非公開にしている文化財のように原典が座標を持たない行は、`geo_lat`・`geo_lon`・`geo_source`・`geometry` が NULL です

## 注意

- 防災行政無線・公営駐輪場・投票所・ゴミ集積所の 4 種類は、本体のファイルが住所と座標を持ちません。施設情報ファイル（`132128_facility.csv`）と施設_ID で結合して、空の列だけを埋めています。結合できた行数は `source_files` の `facility_joined` にあります
- `fire_hydrant` と `garbage_collection_place` の行数が少ないのは、原典の CSV がその件数で公開されているためです
- テーブルの行が少ないときは、`source_files` の `status` と `row_count` で、原典の件数なのか取り込みの失敗なのかを確認できます

## 更新

```bash
uv sync
bash scripts/build.sh
```
