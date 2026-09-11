{# 投票所（期日前投票所を含む）のステージング。緯度経度を数値化する。 #}

with source as (
    select * from {{ ref('raw_polling_place') }}
)
select
    municipality_code,
    organization_name,
    facility_id,
    polling_place_id,
    voting_district_number,
    name,
    name_kana,
    name_en,
    description,
    address,
    prefecture,
    city,
    ward,
    town,
    town_id,
    street_number,
    building_name,
    postal_code,
    phone_number,
    try_cast(lat as double) as lat,
    try_cast(lon as double) as lon,
    {{ ods_geo_columns() }},
    crs,
    crs_code,
    polling_place_type,
    voting_district,
    election_type,
    notes,
    _extras as extras,
    _as_of as as_of,
    _source_url as source_url,
    _source_page as source_page
from source
