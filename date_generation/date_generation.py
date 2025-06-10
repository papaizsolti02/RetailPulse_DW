import pyodbc
import logging
import utils.logger_config
from utils.check_table_exists import check_table_exists

def date_generation(
    connection: pyodbc.Connection,
    cursor: pyodbc.Cursor,
) -> None:
    """
    Creates the [prod].[DateDim] table by executing a stored procedure, 
    only if the table does not already exist.

    Parameters:
        connection (pyodbc.Connection): Active database connection.
        cursor (pyodbc.Cursor): Database cursor used to execute SQL commands.

    Returns:
        None

    Logs:
        - Info message if the table already exists or after successful generation.
        - Error message if a database exception occurs.

    Notes:
        - Uses `check_table_exists` to verify if [prod].[DateDim] already exists.
        - Executes stored procedure [prod].[GenerateDateDim] if table is missing.
    """
    try:
        logger = logging.getLogger(__name__)

        table_exists = check_table_exists(connection, cursor, 'prod', 'DateDim')
        if table_exists:
            logger.info("[prod].[DateDim] already exists. Skipping generation!")
        else:
            logger.info("Generating date dimension!")
            cursor.execute("EXEC [prod].[GenerateDateDim]")
            connection.commit()
            logger.info("Date dimension successfully created!")

    except pyodbc.Error as db_err:
        logger.error(f"Database error during date dimension creation: {db_err}!")
        connection.rollback()
