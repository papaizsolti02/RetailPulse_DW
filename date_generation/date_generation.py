import pyodbc
import logging
import utils.logger_config
from utils.check_table_exists import check_table_exists

def date_generation(
    connection: pyodbc.Connection,
    cursor: pyodbc.Cursor,
) -> None:
    try:
        logger = logging.getLogger(__name__)

        logger.info("Check if date dimension [prod].[DateDim] already exists")
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