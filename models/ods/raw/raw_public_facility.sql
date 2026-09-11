{# 自治体標準ODS「公共施設一覧」の生データ。
   pipelines/ods.py が日野市公開の CSV を標準キーに正規化して data/ods/public_facility.ndjson に保存する。 #}

{{ config(materialized='table') }}

select *
from read_json(
    'data/ods/public_facility.ndjson',
    format='newline_delimited',
    columns={
        'municipality_code': 'VARCHAR',
        'facility_id': 'VARCHAR',
        'name': 'VARCHAR',
        'name_kana': 'VARCHAR',
        'name_alias': 'VARCHAR',
        'poi_code': 'VARCHAR',
        'address': 'VARCHAR',
        'prefecture': 'VARCHAR',
        'city': 'VARCHAR',
        'postal_code': 'VARCHAR',
        'phone_number': 'VARCHAR',
        'lat': 'VARCHAR',
        'lon': 'VARCHAR',
        'corporate_number': 'VARCHAR',
        'corporate_name': 'VARCHAR',
        'available_days': 'VARCHAR',
        'start_time': 'VARCHAR',
        'end_time': 'VARCHAR',
        'available_notes': 'VARCHAR',
        'access': 'VARCHAR',
        'parking': 'VARCHAR',
        'description': 'VARCHAR',
        'url': 'VARCHAR',
        'notes': 'VARCHAR',
        '_extras': 'JSON',
        '_as_of': 'VARCHAR',
        '_source_url': 'VARCHAR',
        '_source_page': 'VARCHAR',
        '_fetched_at': 'VARCHAR'
    }
)
