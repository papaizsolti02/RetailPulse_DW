import pyodbc
import logging
from typing import List
import utils.logger_config

def generate_subset_products(
    connection: pyodbc.Connection,
    cursor: pyodbc.Cursor,
) -> List[dict]:
    try:
        logger = logging.getLogger(__name__)
        logger.info(f"Retrieving a subset of products!")

        query = """
            SELECT TOP (100)
                ProductId,
                Name,
                Price
            FROM prod.ProductsDim
            ORDER BY NEWID();
        """

        cursor.execute(query)
        rows = cursor.fetchall()

        logger.info(f"Query returned {len(rows)} rows from [prod].[ProductsDim].")
        return rows
    except pyodbc.Error as db_err:
        logger.error(f"Database error during retrieving subset of products from [prod].[ProductsDim]: {db_err}!")
        connection.rollback()

