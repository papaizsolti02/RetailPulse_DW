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
    """
    Checks whether a given table exists in the specified schema of the connected database.

    Parameters:
        connection (pyodbc.Connection): Active database connection.
        cursor (pyodbc.Cursor): Cursor used to execute the SQL command.
        schema_name (str): Name of the schema where the table is expected.
        table_name (str): Name of the table to check for existence.

    Returns:
        bool: True if the table exists, False otherwise.

    Logs:
        - Info message before checking.
        - Error message if a database error occurs during execution.
    """
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
