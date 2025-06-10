import pyodbc
import logging
import utils.logger_config
from typing import Union

def check_table_exists(
    connection: pyodbc.Connection,
    cursor: pyodbc.Cursor,
    schema_name: str,
    table_name: str,
) -> bool:
    try:
        logger = logging.getLogger(__name__)
        logger.info(f"Checking if [{schema_name}].[{table_name}] table exists!")
        check_table_sql = f"""
            SELECT 1
            FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_SCHEMA = '{schema_name}' AND TABLE_NAME = '{table_name}';
        """
        cursor.execute(check_table_sql)
        table_exists = cursor.fetchone()

        return table_exists is not None
    except pyodbc.Error as db_err:
        logger.error(f"Database error during lookup of [{schema_name}].[{table_name}]: {db_err}!")