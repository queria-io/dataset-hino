{# ゴミ集積所一覧のステージング。緯度経度を数値化する。

   本体ファイル（132128_garbage_collection_place.csv）は住所も座標も持たず、併走する
   132128_facility.csv 側にある。pipelines/ods.py が施設_ID で結合して埋めてあるので、
   ここでは結合済みの列をそのまま受ける。

   収集日（ゴミ種類ごとの曜日）は統制語彙が無く自由記述が入るため文字列のまま保持する。 #}

with source as (
    select * from {{ ref('raw_garbage_collection_place') }}
)
select
    municipality_code,
    facility_id,
    collection_place_id,
    name,
    name_kana,
    name_en,
    address,
    prefecture,
    city,
    town,
    street_number,
    building_name,
    postal_code,
    phone_number,
    try_cast(lat as double) as lat,
    try_cast(lon as double) as lon,
    {{ ods_geo_columns() }},
    garbage_type,
    collection_day,
    district,
    description,
    caution,
    url,
    _extras as extras,
    _as_of as as_of,
    _source_url as source_url,
    _source_page as source_page
from source
