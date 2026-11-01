日野市が公開している自治体標準オープンデータセットを、デジタル庁のデータセット定義書の
様式のまま収録したスキーマ。1テーブル=1種別で、18種別ある。

日野市のオープンデータカタログは CKAN ではなく自前の CGI で、機械可読な一覧の出口が無い。
そのため取り込みは種別ごとの CSV の URL を直接持つ形にしてある（`hino_datasets.yml`）。

列は東京都オープンデータカタログを取り込んだ `metro_tokyo` の `ods` スキーマと揃えてあるので、
同じ列名で近隣自治体と並べて集計できる。

全国地方公共団体コード・所在地・緯度経度・法人番号・町字ID は、Queria の語彙の名前の列
（`local_government_code` / `full_address` / `latitude` / `longitude` / `legal_entity_number` /
`street_address_id`）で持つ。同じ値の `municipality_code` / `address` / `lat` / `lon` /
`corporate_number` / `town_id` は非推奨で、当面は残す。

座標の扱いは3列で表す。`latitude` / `longitude` は原典の値をそのまま残し、地図に使える座標は
`geo_lat` / `geo_lon` に入れる。由来は `geo_source` を見る。

防災行政無線・公営駐輪場・投票所・ゴミ集積所の4種別は、データセット定義書Bの
施設・設備分離型で公開されていて、本体のファイルが住所と座標を持たない。
併走する施設情報ファイル（`132128_facility.csv`）を施設_ID で結合して補っている。

各テーブルのデータ時点は `as_of` 列と、`source_files` テーブルで確認できる。
テーブルの行数が少ないときは `source_files` の `status` と `row_count` を見ると、
原典がそうなのか取り込みで落ちたのかを切り分けられる。
