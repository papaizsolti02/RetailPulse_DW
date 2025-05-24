import json
import pyodbc
import requests
from typing import List, Tuple


def daily_user_processing(
    connection: pyodbc.Connection,
    cursor: pyodbc.Cursor
) -> None:
    """
    Retrieves user data from the RandomUser API, formats it, and ingests it
    into the SQL Server database via a stored procedure.

    Parameters:
        connection (pyodbc.Connection): An active connection to the SQL Server database.
        cursor (pyodbc.Cursor): A cursor object for executing SQL commands.

    Returns:
        None
    """
    try:
        print("Fetching user data from external API...")
        response = requests.get("https://randomuser.me/api/?results=5000")
        response.raise_for_status()
        users = response.json().get('results', [])

        if not users:
            print("No user data retrieved from API.")
            return

        print(f"Retrieved {len(users)} users.")

        records: List[Tuple[str, str]] = [
            (json.dumps(user), 'https://randomuser.me/api/') for user in users
        ]

        sp_call = "{CALL [raw].[IngestRawUsers] (?, ?)}"

        print("Inserting raw user data into the database...")
        cursor.executemany(sp_call, records)
        connection.commit()

        print("User data inserted successfully.")
    except requests.RequestException as req_err:
        print(f"Failed to fetch user data from API: {req_err}")
    except pyodbc.Error as db_err:
        print(f"Database error during insertion: {db_err}")
        connection.rollback()
    except Exception as ex:
        print(f"Unexpected error occurred: {ex}")
        connection.rollback()
