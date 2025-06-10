import pyodbc
import logging
import requests
import pandas as pd
import utils.logger_config
from utils.check_table_exists import check_table_exists


def daily_exchange_rate_processing(
    connection: pyodbc.Connection,
    cursor: pyodbc.Cursor
) -> None:
    """
    Executes the daily exchange rate processing workflow, which consists of:

    1. Checking for the existence of the [config].[CountryInfo] table.
       - If it doesn't exist, reads the country data from 'datalake/countries.csv' and ingests it via
         the [config].[IngestCountryInfo] stored procedure.

    2. Fetching exchange rates for countries that appear in the [utils].[GetTerritoryCurrencies] view
       but have not yet been recorded in the exchange rate dimension.

    3. Using the Frankfurter API to fetch the exchange rate from each country's currency to EUR.
       - If the currency is already EUR, the exchange rate is set to 1.
       - If the API call fails or the currency is not supported, a rate of 0 is recorded and logged as a warning.

    4. Upserting the exchange rate data into [prod].[UpsertExchangeRate] via a stored procedure.

    All operations include logging at INFO, WARNING, and ERROR levels, and database operations are committed
    or rolled back appropriately in case of errors.

    Parameters:
        connection (pyodbc.Connection): An open connection to the SQL Server database.
        cursor (pyodbc.Cursor): A cursor object from the same connection used to execute SQL commands.
    """
    logger = logging.getLogger(__name__)

    # Check if table exists
    logger.info("Check if country information table ([config].[CountryInfo]) exists!")

    table_exists = check_table_exists(connection, cursor, 'config', 'CountryInfo')

    if table_exists:
        logger.info("[config].[CountryInfo] already exists. Skipping ingestion!")
    else:
        try:
            logger.info("Ingesting Country information into [config].[CountryInfo]!")

            # Read and preprocess CSV
            df = pd.read_csv('datalake/countries.csv', usecols=['name', 'currency', 'currency_symbol'])
            records = list(df.itertuples(index=False, name=None))

            sp_call = "{CALL [config].[IngestCountryInfo] (?, ?, ?)}"
            cursor.executemany(sp_call, records)
            connection.commit()

            logger.info("Ingestion completed into [config].[CountryInfo]!")
        except pyodbc.Error as db_err:
            logger.error(f"Database error during insertion: {db_err}!")
            connection.rollback()
        except Exception as ex:
            logger.error(f"Unexpected error occurred: {ex}!")
            connection.rollback()

    # Fetch exchange rates for those countries which have not appeared yet in the [prod].[TerritoriesDim] table
    logger.info("Fetch exchange rates for countries!")
    cursor.execute("SELECT Country, Currency FROM utils.GetTerritoryCurrencies")
    results = [row for row in cursor.fetchall()]

    exchange_rate_data = []

    for country, currency in results:
        try:
            if currency == "EUR":
                rate = 1
            else:
                response = requests.get(f"https://api.frankfurter.dev/v1/latest?base={currency}&symbols=EUR")
                response.raise_for_status()
                rate = response.json().get("rates", {}).get("EUR")
            rate = float(rate) if rate else 0
        except requests.RequestException as req_err:
            logger.warning(f"Failed to fetch user data from API: {req_err}!")
            rate = 0

        exchange_rate_data.append((country, currency, rate))

    logger.info("Upserting the [prod].[UpsertExchangeRate] table with the new values!")
    sp_call = "{CALL [prod].[UpsertExchangeRate] (?, ?, ?)}"
    cursor.executemany(sp_call, exchange_rate_data)
    connection.commit()
    logger.info("Exchange rates successfully upserted")
