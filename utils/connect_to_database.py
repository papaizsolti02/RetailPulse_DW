import pyodbc
import logging
import utils.logger_config
from typing import Tuple, Optional


def connect_to_database(
    server: str,
    database: str
) -> Optional[Tuple[pyodbc.Connection, pyodbc.Cursor]]:
    """
    Establishes a connection to a SQL Server database using Windows Authentication.
    Returns both the connection object and a cursor with fast execution enabled.

    Parameters:
        server (str): The name or address of the SQL Server instance.
        database (str): The name of the database to connect to.

    Returns:
        Optional[Tuple[pyodbc.Connection, pyodbc.Cursor]]:
            A tuple containing the connection and cursor if successful; None if connection fails.

    Raises:
        None explicitly. Catches and prints pyodbc.Error on failure.
    """
    logger = logging.getLogger(__name__)

    try:
        logger.info("Connecting to self-hosted database!")
        conn = pyodbc.connect(
            'DRIVER={ODBC Driver 17 for SQL Server};'
            f'SERVER={server};'
            f'DATABASE={database};'
            'Trusted_Connection=yes;'
        )
        cursor = conn.cursor()
        cursor.fast_executemany = True
        logger.info("Connection established successfully to self-hosted database!")
        return conn, cursor
    except pyodbc.Error as e:
        logger.error(f"Failed to connect to self-hosted database: {e}!")
        return None
