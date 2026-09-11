-- 小中学校通学区域情報（自治体標準ODS、日野市）
select
    municipality_code,
    school_id,
    school_code,
    name,
    name_kana,
    school_type,
    poi_code,
    prefecture,
    district,
    city,
    ward,
    school_municipality_code,
    district_addresses,
    registered_date,
    abolished_date,
    polygon_file,
    notes,
    extras,
    as_of,
    source_url,
    source_page
from {{ ref('stg_school_district') }}
