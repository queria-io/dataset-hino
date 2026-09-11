{# 自治体標準ODS「投票所一覧」の生データ。
   pipelines/ods.py が日野市公開の CSV を標準キーに正規化して data/ods/polling_place.ndjson に保存する。 #}

{{ config(materialized='table') }}

select *
from read_json(
    'data/ods/polling_place.ndjson',
    format='newline_delimited',
    columns={
        'municipality_code': 'VARCHAR',
        'organization_name': 'VARCHAR',
        'facility_id': 'VARCHAR',
        'polling_place_id': 'VARCHAR',
        'voting_district_number': 'VARCHAR',
        'name': 'VARCHAR',
        'name_kana': 'VARCHAR',
        'name_en': 'VARCHAR',
        'description': 'VARCHAR',
        'address': 'VARCHAR',
        'prefecture': 'VARCHAR',
        'city': 'VARCHAR',
        'ward': 'VARCHAR',
        'town': 'VARCHAR',
        'town_id': 'VARCHAR',
        'street_number': 'VARCHAR',
        'building_name': 'VARCHAR',
        'postal_code': 'VARCHAR',
        'phone_number': 'VARCHAR',
        'lat': 'VARCHAR',
        'lon': 'VARCHAR',
        'crs': 'VARCHAR',
        'crs_code': 'VARCHAR',
        'polling_place_type': 'VARCHAR',
        'voting_district': 'VARCHAR',
        'election_type': 'VARCHAR',
        'notes': 'VARCHAR',
        'available_days': 'VARCHAR',
        'start_time': 'VARCHAR',
        'end_time': 'VARCHAR',
        'available_notes': 'VARCHAR',
        'url': 'VARCHAR',
        'poi_code': 'VARCHAR',
        '_extras': 'JSON',
        '_as_of': 'VARCHAR',
        '_source_url': 'VARCHAR',
        '_source_page': 'VARCHAR',
        '_fetched_at': 'VARCHAR'
    }
)
