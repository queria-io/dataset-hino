{# 公共施設のステージング。緯度経度を数値化する。 #}

with source as (
    select * from {{ ref('raw_public_facility') }}
)
select
    municipality_code,
    facility_id,
    name,
    name_kana,
    name_alias,
    poi_code,
    address,
    prefecture,
    city,
    postal_code,
    phone_number,
    try_cast(lat as double) as lat,
    try_cast(lon as double) as lon,
    {{ ods_geo_columns() }},
    corporate_number,
    corporate_name,
    available_days,
    start_time,
    end_time,
    available_notes,
    access,
    parking,
    description,
    url,
    notes,
    _extras as extras,
    _as_of as as_of,
    _source_url as source_url,
    _source_page as source_page
from source
