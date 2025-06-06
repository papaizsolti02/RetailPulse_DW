import pyodbc
import logging
import pandas as pd
import utils.logger_config

def ingest_and_process_products_db(
    connection: pyodbc.Connection,
    cursor: pyodbc.Cursor,
    data: pd.DataFrame
) -> None:
    """
    Ingests and processes product data through raw, stage, and production layers in a SQL Server database.

    This function performs the following operations:
    1. Truncates the [raw].[Products] table to remove any existing data.
    2. Inserts the provided product data from the DataFrame into the [raw].[Products] table 
       using the [raw].[IngestRawProducts] stored procedure.
    3. Processes the raw data into the [stage].[Products] table by calling [stage].[ProcessRawProducts].
    4. Upserts staged data into the [prod].[Products] dimension using [prod].[UpsertProductsDim].

    All actions are logged, and exceptions are caught and logged as well. If any error occurs, the transaction is rolled back.

    Parameters:
        connection (pyodbc.Connection): An open pyodbc connection to the SQL Server database.
        cursor (pyodbc.Cursor): A database cursor used to execute SQL statements.
        data (pd.DataFrame): A pandas DataFrame containing the product records with the following columns:
            - name
            - description
            - color
            - brand
            - category
            - gender
            - price
    """
    try:
        logger = logging.getLogger(__name__)
        final_products = [
            (
                row["name"],
                row["description"],
                row["color"],
                row["brand"],
                row["category"],
                row["gender"],
                row["price"]
            )
            for _, row in data.iterrows()
        ]
        cursor.execute(f"TRUNCATE TABLE [raw].[Products]")

        sp_call = "{CALL [raw].[IngestRawProducts] (?, ?, ?, ?, ?, ?, ?)}"

        logger.info("Inserting raw products into [raw].[Products]!")
        cursor.executemany(sp_call, final_products)
        connection.commit()
        logger.info("Raw products inserted successfully!")

        logger.info("Processing raw products into [stage].[Products]!")
        cursor.execute("EXEC [stage].[ProcessRawProducts]")
        connection.commit()
        logger.info("Raw products processed successfully!")

        logger.info("Upserting staged products into [prod].[Products]!")
        cursor.execute("EXEC [prod].[UpsertProductsDim]")
        connection.commit()
        logger.info("Staged products upserted successfully!")
    except pyodbc.Error as db_err:
        logger.error(f"Database error during insertion/processing: {db_err}!")
        connection.rollback()
    except Exception as ex:
        logger.error(f"Unexpected error occurred: {ex}!")
        connection.rollback()
