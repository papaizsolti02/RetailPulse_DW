import pyodbc
import logging
from typing import List
import utils.logger_config

def generate_subset_users(
    connection: pyodbc.Connection,
    cursor: pyodbc.Cursor,
) -> List[dict]:
    try:
        logger = logging.getLogger(__name__)
        logger.info(f"Retrieving a subset of users with their country")

        query = """
            DECLARE @RandomUserCount INT = FLOOR(RAND() * (50 - 10 + 1)) + 10;

            SELECT TOP (@RandomUserCount)
                u.Email AS UserEmail,
                t.Country
            FROM
                prod.UsersDim u
            JOIN prod.SubTerritoriesDim st
                ON u.SubTerritoryId = st.SubTerritoryId
            JOIN prod.TerritoriesDim t
                ON st.TerritoryId = t.TerritoryId
            WHERE u.IsCurrent = 1
            ORDER BY NEWID();
        """

        cursor.execute(query)
        rows = cursor.fetchall()

        logger.info(f"Query returned {len(rows)} rows from [prod].[UsersDim].")
        return rows
    except pyodbc.Error as db_err:
        logger.error(f"Database error during retrieving subset of users from [prod].[UsersDim]: {db_err}!")
        connection.rollback()

