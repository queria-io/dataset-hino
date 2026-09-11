{# 自治体標準ODS「公衆無線LANアクセスポイント一覧」の生データ。
   pipelines/ods.py が日野市公開の CSV を標準キーに正規化して data/ods/public_wireless_lan.ndjson に保存する。 #}

{{ config(materialized='table') }}

select *
from read_json(
    'data/ods/public_wireless_lan.ndjson',
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
        'installer': 'VARCHAR',
        'ssid': 'VARCHAR',
        'coverage_area': 'VARCHAR',
        'url': 'VARCHAR',
        'notes': 'VARCHAR',
        '_extras': 'JSON',
        '_as_of': 'VARCHAR',
        '_source_url': 'VARCHAR',
        '_source_page': 'VARCHAR',
        '_fetched_at': 'VARCHAR'
    }
)
