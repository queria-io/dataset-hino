{# 自治体標準ODS「緊急避難場所一覧」の生データ。
   pipelines/ods.py が日野市公開の CSV を標準キーに正規化して data/ods/evacuation_space.ndjson に保存する。 #}

{{ config(materialized='table') }}

select *
from read_json(
    'data/ods/evacuation_space.ndjson',
    format='newline_delimited',
    columns={
        'municipality_code': 'VARCHAR',
        'facility_id': 'VARCHAR',
        'name': 'VARCHAR',
        'name_kana': 'VARCHAR',
        'address': 'VARCHAR',
        'prefecture': 'VARCHAR',
        'city': 'VARCHAR',
        'postal_code': 'VARCHAR',
        'phone_number': 'VARCHAR',
        'lat': 'VARCHAR',
        'lon': 'VARCHAR',
        'elevation': 'VARCHAR',
        'for_flood': 'VARCHAR',
        'for_landslide': 'VARCHAR',
        'for_storm_surge': 'VARCHAR',
        'for_earthquake': 'VARCHAR',
        'for_tsunami': 'VARCHAR',
        'for_large_fire': 'VARCHAR',
        'for_inland_flooding': 'VARCHAR',
        'for_volcano': 'VARCHAR',
        'shelter_overlap': 'VARCHAR',
        'capacity_note': 'VARCHAR',
        'target_area': 'VARCHAR',
        'url': 'VARCHAR',
        'notes': 'VARCHAR',
        '_extras': 'JSON',
        '_as_of': 'VARCHAR',
        '_source_url': 'VARCHAR',
        '_source_page': 'VARCHAR',
        '_fetched_at': 'VARCHAR'
    }
)
