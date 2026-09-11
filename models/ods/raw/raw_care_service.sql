{# 自治体標準ODS「介護サービス事業所一覧」の生データ。
   pipelines/ods.py が日野市公開の CSV を標準キーに正規化して data/ods/care_service.ndjson に保存する。 #}

{{ config(materialized='table') }}

select *
from read_json(
    'data/ods/care_service.ndjson',
    format='newline_delimited',
    columns={
        'municipality_code': 'VARCHAR',
        'facility_id': 'VARCHAR',
        'name': 'VARCHAR',
        'name_kana': 'VARCHAR',
        'name_en': 'VARCHAR',
        'service_type': 'VARCHAR',
        'location_municipality_code': 'VARCHAR',
        'town_id': 'VARCHAR',
        'address': 'VARCHAR',
        'prefecture': 'VARCHAR',
        'city': 'VARCHAR',
        'town': 'VARCHAR',
        'street_number': 'VARCHAR',
        'building_name': 'VARCHAR',
        'postal_code': 'VARCHAR',
        'phone_number': 'VARCHAR',
        'fax_number': 'VARCHAR',
        'lat': 'VARCHAR',
        'lon': 'VARCHAR',
        'corporate_number': 'VARCHAR',
        'corporate_name': 'VARCHAR',
        'business_number': 'VARCHAR',
        'available_days': 'VARCHAR',
        'available_notes': 'VARCHAR',
        'capacity': 'VARCHAR',
        'url': 'VARCHAR',
        'notes': 'VARCHAR',
        '_extras': 'JSON',
        '_as_of': 'VARCHAR',
        '_source_url': 'VARCHAR',
        '_source_page': 'VARCHAR',
        '_fetched_at': 'VARCHAR'
    }
)
