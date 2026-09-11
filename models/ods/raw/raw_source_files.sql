{# 取り込みの実行結果。pipelines/ods.py が data/ods/source_files.ndjson に書く。 #}

{{ config(materialized='table') }}

select *
from read_json(
    'data/ods/source_files.ndjson',
    format='newline_delimited',
    columns={
        'dataset_id': 'VARCHAR',
        'dataset_title': 'VARCHAR',
        'url': 'VARCHAR',
        'page': 'VARCHAR',
        'as_of': 'VARCHAR',
        'status': 'VARCHAR',
        'reason': 'VARCHAR',
        'encoding': 'VARCHAR',
        'row_count': 'BIGINT',
        'facility_joined': 'BIGINT',
        'fetched_at': 'VARCHAR'
    }
)
