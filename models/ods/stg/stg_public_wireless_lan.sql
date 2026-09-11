{# 公衆無線LANアクセスポイントのステージング。緯度経度を数値化する。 #}

with source as (
    select * from {{ ref('raw_public_wireless_lan') }}
)
select
    municipality_code,
    facility_id,
    name,
    name_kana,
    address,
    prefecture,
    city,
    postal_code,
    phone_number,
    try_cast(lat as double) as lat,
    try_cast(lon as double) as lon,
    {{ ods_geo_columns() }},
    installer,
    ssid,
    coverage_area,
    url,
    notes,
    _extras as extras,
    _as_of as as_of,
    _source_url as source_url,
    _source_page as source_page
from source
