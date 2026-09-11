"""日野市オープンデータ データパイプライン。

1. ods: 日野市が公開する自治体標準オープンデータセットの取得と正規化
2. dbt: dbt ビルド
"""

import logging

from dbt.cli.main import dbtRunner

from pipelines.ods import download_and_normalize

logging.basicConfig(level=logging.INFO, format="%(message)s")
logger = logging.getLogger("pipelines")


def dbt_build():
    dbt = dbtRunner()
    for command in (["deps"], ["build"], ["docs", "generate"]):
        result = dbt.invoke(command)
        if not result.success:
            raise SystemExit(f"dbt {' '.join(command)} failed")


def main():
    logger.info("1/2: ods (自治体標準オープンデータセット)")
    download_and_normalize()

    logger.info("2/2: dbt build")
    dbt_build()


if __name__ == "__main__":
    main()
