{# 介護サービス事業所のステージング。緯度経度・定員を数値化する。
   実施サービスは自治体ごとに表記が揺れる（統制語彙が定義書側にないため）が生値を保持する。 #}

with source as (
    select * from {{ ref('raw_care_service') }}
)
select
    municipality_code,
    facility_id,
    name,
    name_kana,
    name_en,
    service_type,
    location_municipality_code,
    town_id,
    address,
    prefecture,
    city,
    town,
    street_number,
    building_name,
    postal_code,
    phone_number,
    fax_number,
    try_cast(lat as double) as lat,
    try_cast(lon as double) as lon,
    {{ ods_geo_columns() }},
    corporate_number,
    corporate_name,
    business_number,
    available_days,
    available_notes,
    try_cast(capacity as integer) as capacity,
    url,
    notes,
    _extras as extras,
    _as_of as as_of,
    _source_url as source_url,
    _source_page as source_page
from source
