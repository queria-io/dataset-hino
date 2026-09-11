{# 自治体標準ODS「公衆トイレ一覧」の生データ。
   pipelines/ods.py が日野市公開の CSV を標準キーに正規化して data/ods/public_toilet.ndjson に保存する。 #}

{{ config(materialized='table') }}

select *
from read_json(
    'data/ods/public_toilet.ndjson',
    format='newline_delimited',
    columns={
        'municipality_code': 'VARCHAR',
        'facility_id': 'VARCHAR',
        'name': 'VARCHAR',
        'name_kana': 'VARCHAR',
        'address': 'VARCHAR',
        'prefecture': 'VARCHAR',
        'city': 'VARCHAR',
        'install_position': 'VARCHAR',
        'lat': 'VARCHAR',
        'lon': 'VARCHAR',
        'male_total': 'VARCHAR',
        'female_total': 'VARCHAR',
        'unisex_total': 'VARCHAR',
        'barrier_free_total': 'VARCHAR',
        'wheelchair': 'VARCHAR',
        'baby_facility': 'VARCHAR',
        'ostomate': 'VARCHAR',
        'start_time': 'VARCHAR',
        'end_time': 'VARCHAR',
        'available_notes': 'VARCHAR',
        'image': 'VARCHAR',
        'notes': 'VARCHAR',
        '_extras': 'JSON',
        '_as_of': 'VARCHAR',
        '_source_url': 'VARCHAR',
        '_source_page': 'VARCHAR',
        '_fetched_at': 'VARCHAR'
    }
)
