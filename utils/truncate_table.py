import pyodbc
import logging
import utils.logger_config

def truncate_table(
    connection: pyodbc.Connection,
    cursor: pyodbc.Cursor,
    schema_name: str,
    table_name: str,
) -> None:
    try:
        logger = logging.getLogger(__name__)
        logger.info(f"Truncating table [{schema_name}].[{table_name}]!")
        cursor.execute(f"TRUNCATE TABLE [{schema_name}].[{table_name}]")
        connection.commit()
        logger.info(f"Truncation successfully done for [{schema_name}].[{table_name}]")
        return None
    except pyodbc.Error as db_err:
        logger.error(f"Database error during truncating [{schema_name}].[{table_name}]: {db_err}!")
        connection.rollback()