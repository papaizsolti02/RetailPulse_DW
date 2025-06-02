import pyodbc
import requests
import pandas as pd


def daily_exchange_rate_processing(
    connection: pyodbc.Connection,
    cursor: pyodbc.Cursor
):
    # Check if table exists
    check_table_sql = """
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_SCHEMA = 'config' AND TABLE_NAME = 'CountryInfo';
    """
    cursor.execute(check_table_sql)
    table_exists = cursor.fetchone()

    if table_exists:
        print("[config.CountryInfo] already exists. Skipping ingestion.")
    else:
        try:
            print("Ingesting Country information into [config.CountryInfo]")

            # Read and preprocess CSV
            df = pd.read_csv('datalake/countries.csv', usecols=['name', 'currency', 'currency_symbol'])
            records = list(df.itertuples(index=False, name=None))

            sp_call = "{CALL [config].[IngestCountryInfo] (?, ?, ?)}"
            cursor.executemany(sp_call, records)
            connection.commit()

            print("Ingestion complete.")
        except Exception as e:
            print("Failed to ingest country info:", e)
            connection.rollback()

    # Fetch exchange rates for those countries which have not appeared yet in the [prod].[TerritoriesDim] table
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

            rate = float(rate) if rate else 0.0
        except Exception as e:
            print(f"Failed to get rate for {currency}: {e}")
            rate = 0.0

        exchange_rate_data.append((country, currency, rate))
    sp_call = "{CALL [prod].[UpsertExchangeRate] (?, ?, ?)}"
    cursor.executemany(sp_call, exchange_rate_data)
    connection.commit()
