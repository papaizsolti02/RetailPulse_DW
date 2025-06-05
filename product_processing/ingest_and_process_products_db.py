import pyodbc
import logging
import pandas as pd
import utils.logger_config

def ingest_and_process_products_db(
    connection: pyodbc.Connection,
    cursor: pyodbc.Cursor,
    data: pd.DataFrame
) -> None:
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
    except Exception as e:
        logger.error(f"Error during products ingestion: {e}!")