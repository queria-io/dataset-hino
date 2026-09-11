{# 防災行政無線設置一覧のステージング。緯度経度を数値化する。

   本体ファイル（132128_emergency_radio.csv）は住所も座標も持たず、併走する
   132128_facility.csv 側にある。pipelines/ods.py が施設_ID で結合して埋めてあるので、
   ここでは結合済みの列をそのまま受ける。 #}

with source as (
    select * from {{ ref('raw_emergency_radio') }}
)
select
    municipality_code,
    facility_id,
    equipment_id,
    radio_id,
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
    district,
    description,
    notes,
    _extras as extras,
    _as_of as as_of,
    _source_url as source_url,
    _source_page as source_page
from source
