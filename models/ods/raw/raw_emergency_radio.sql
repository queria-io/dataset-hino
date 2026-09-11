{# 自治体標準ODS「防災行政無線設置一覧」の生データ。
   pipelines/ods.py が日野市公開の CSV を標準キーに正規化して data/ods/emergency_radio.ndjson に保存する。 #}

{{ config(materialized='table') }}

select *
from read_json(
    'data/ods/emergency_radio.ndjson',
    format='newline_delimited',
    columns={
        'municipality_code': 'VARCHAR',
        'facility_id': 'VARCHAR',
        'equipment_id': 'VARCHAR',
        'radio_id': 'VARCHAR',
        'name': 'VARCHAR',
        'name_kana': 'VARCHAR',
        'name_en': 'VARCHAR',
        'description': 'VARCHAR',
        'lat': 'VARCHAR',
        'lon': 'VARCHAR',
        'crs': 'VARCHAR',
        'crs_code': 'VARCHAR',
        'district': 'VARCHAR',
        'notes': 'VARCHAR',
        'address': 'VARCHAR',
        'prefecture': 'VARCHAR',
        'city': 'VARCHAR',
        'town': 'VARCHAR',
        'town_id': 'VARCHAR',
        'street_number': 'VARCHAR',
        'building_name': 'VARCHAR',
        'postal_code': 'VARCHAR',
        'phone_number': 'VARCHAR',
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
