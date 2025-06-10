import pyodbc
import logging
from typing import List, Tuple, Optional
import utils.logger_config

def table_projection(
    connection: pyodbc.Connection,
    cursor: pyodbc.Cursor,
    columns: List[str],
    schema_name: str,
    table_name: str,
) -> Optional[List[Tuple]]:
    """
    Executes a SELECT query on the specified table and returns the results for given columns.

    Parameters:
        connection (pyodbc.Connection): Active database connection.
        cursor (pyodbc.Cursor): Database cursor used to execute SQL commands.
        columns (List[str]): List of column names to select.
        schema_name (str): Schema name of the table.
        table_name (str): Table name.

    Returns:
        List of tuples with the selected values, or None on error.
    """
    try:
        logger = logging.getLogger(__name__)
        logger.info(f"Selecting columns {columns} from [{schema_name}].[{table_name}]")

        column_list = ", ".join([f"[{col}]" for col in columns])
        query = f"SELECT {column_list} FROM [{schema_name}].[{table_name}]"

        cursor.execute(query)
        rows = cursor.fetchall()

        logger.info(f"Query returned {len(rows)} rows from [{schema_name}].[{table_name}].")
        return rows
    except pyodbc.Error as db_err:
        logger.error(f"Database error during SELECT on [{schema_name}].[{table_name}]: {db_err}!")
        connection.rollback()

