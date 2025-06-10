import pyodbc
import logging
import utils.logger_config

def truncate_table(
    connection: pyodbc.Connection,
    cursor: pyodbc.Cursor,
    schema_name: str,
    table_name: str,
) -> None:
    """
    Truncates all data from the specified table within the given schema.

    Parameters:
        connection (pyodbc.Connection): Active database connection.
        cursor (pyodbc.Cursor): Cursor used to execute the SQL command.
        schema_name (str): Name of the schema containing the target table.
        table_name (str): Name of the table to be truncated.

    Returns:
        None

    Logs:
        - Info message before and after successful truncation.
        - Error message if a database exception occurs during truncation.

    Notes:
        - TRUNCATE is a DDL operation and cannot be rolled back in some databases.
        - Make sure the table has no foreign key constraints that would prevent truncation.
    """
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
