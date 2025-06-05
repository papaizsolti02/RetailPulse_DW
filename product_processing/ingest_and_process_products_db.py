import pyodbc
import pandas as pd

def ingest_and_process_products_db(
    connection: pyodbc.Connection,
    cursor: pyodbc.Cursor,
    data: pd.DataFrame
) -> None:
    try:
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

        print("Inserting raw products into [raw].[Products]")
        cursor.executemany(sp_call, final_products)
        connection.commit()
        print("Raw products inserted successfully")

        print("Processing raw products into [stage].[Products]")
        cursor.execute("EXEC [stage].[ProcessRawProducts]")
        connection.commit()
        print("Raw products processed successfully")

        print("Upserting staged products into [prod].[Products]")
        cursor.execute("EXEC [prod].[UpsertProductsDim]")
        connection.commit()
        print("Staged products upserted successfully")
    except Exception as e:
        print(f"Error during products ingestion: {e}")