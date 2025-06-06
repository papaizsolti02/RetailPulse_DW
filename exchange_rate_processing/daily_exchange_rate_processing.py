import pyodbc
import logging
import requests
import pandas as pd
import utils.logger_config


def daily_exchange_rate_processing(
    connection: pyodbc.Connection,
    cursor: pyodbc.Cursor
) -> None:
    logger = logging.getLogger(__name__)

    # Check if table exists
    logger.info("Check if country information table ([config].[CountryInfo]) exists!")
    check_table_sql = """
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_SCHEMA = 'config' AND TABLE_NAME = 'CountryInfo';
    """
    cursor.execute(check_table_sql)
    table_exists = cursor.fetchone()

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
                try:
                    response = requests.get(f"https://api.frankfurter.dev/v1/latest?base={currency}&symbols=EUR")
                    response.raise_for_status()
                    rate = response.json().get("rates", {}).get("EUR")
                except requests.RequestException as req_err:
                    logger.error(f"Failed to fetch user data from API: {req_err}!")

            rate = float(rate) if rate else 0
        except Exception as e:
            logger.warning(f"Failed to get rate for {currency}: {e}!")
            rate = 0

        exchange_rate_data.append((country, currency, rate))

    logger.info("Upserting the [prod].[UpsertExchangeRate] table with the new values!")
    sp_call = "{CALL [prod].[UpsertExchangeRate] (?, ?, ?)}"
    cursor.executemany(sp_call, exchange_rate_data)
    connection.commit()
    logger.info("Exchange rates successfully upserted")
