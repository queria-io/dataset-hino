-- 取り込みの実行結果（1行=1種別。データ時点・行数・失敗理由の把握用）
select
    dataset_id,
    dataset_title,
    try_cast(as_of as date) as as_of,
    status,
    reason,
    encoding,
    row_count,
    facility_joined,
    url,
    page,
    fetched_at
from {{ ref('raw_source_files') }}
