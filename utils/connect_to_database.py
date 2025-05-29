import pyodbc
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
    try:
        conn = pyodbc.connect(
            'DRIVER={ODBC Driver 17 for SQL Server};'
            f'SERVER={server};'
            f'DATABASE={database};'
            'Trusted_Connection=yes;'
        )
        cursor = conn.cursor()
        cursor.fast_executemany = True
        return conn, cursor
    except pyodbc.Error as e:
        print(f"[ERROR] Failed to connect to database '{database}' on server '{server}': {e}")
        return None
