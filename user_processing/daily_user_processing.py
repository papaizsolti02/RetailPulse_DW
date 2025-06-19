import json
import pyodbc
import random
import logging
import requests
import utils.logger_config
from typing import List, Tuple
from utils.truncate_table import truncate_table


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
        logger = logging.getLogger(__name__)

        num_users = random.randint(100, 500)

        logger.info("Fetching user data from external API!")
        response = requests.get(f"https://randomuser.me/api/?results={num_users}")
        response.raise_for_status()
        users = response.json().get('results', [])

        if not users:
            logger.warning("No user data retrieved from API!")
            return

        logger.info(f"Retrieved {len(users)} users!")

        records: List[Tuple[str, str]] = [
            (json.dumps(user), 'https://randomuser.me/api/') for user in users
        ]

        # Truncate raw Users table
        truncate_table(connection, cursor, 'raw', 'Users')

        sp_call = "{CALL [raw].[IngestRawUsers] (?, ?)}"

        logger.info("Inserting raw user data into the database!")
        cursor.executemany(sp_call, records)
        connection.commit()
        logger.info("Raw users inserted successfully!")

        logger.info("Processing Raw Users into the staging table, processing TerritoriesDim, SubTerritoriesDim into production tables!")
        cursor.execute("EXEC [stage].[ProcessRawUsers]")
        connection.commit()
        logger.info("Raw users processed successfully into production table, territores and subterritories processed!")
    except requests.RequestException as req_err:
        logger.error(f"Failed to fetch user data from API: {req_err}!")
    except pyodbc.Error as db_err:
        logger.error(f"Database error during insertion: {db_err}!")
        connection.rollback()
    except Exception as ex:
        logger.error(f"Unexpected error occurred: {ex}!")
        connection.rollback()
