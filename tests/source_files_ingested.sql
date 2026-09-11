-- 取り込みが成功していない種別があればビルドを落とす。
--
-- 取得失敗・ヘッダー不一致・必須列欠落のとき pipelines/ods.py は空の NDJSON を書いて
-- 次の種別へ進む。read_json はそれを 0 行として正常に読むので、そのままだと
-- 「727行のテーブルが 0 行に置き換わったまま dbt build は緑」で push まで進んでしまう。
-- Sync は毎週無人で走るため、上流の URL 差し替え1本で公開中のデータが消える。
--
-- ここで落とせば push の手前で止まり、前に公開した内容がそのまま残る。
-- degraded（施設情報ファイルを結合できず住所と座標を欠く）は、本体の行は取れていて
-- 公開する価値があるので落とさない。source_files の status で追える。
select
    dataset_id,
    status,
    reason,
    row_count
from {{ ref('source_files') }}
where status not in ('ok', 'degraded')
