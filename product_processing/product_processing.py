import pyodbc
import random
import logging
import pandas as pd
from faker import Faker
import utils.logger_config
from datetime import datetime
from .ingest_and_process_products_db import ingest_and_process_products_db

def product_processing(
    connection: pyodbc.Connection,
    cursor: pyodbc.Cursor
) -> None:
    """
    Generates synthetic product data, stores it in the datalake, and processes it through the data warehouse pipeline.

    Steps performed:
    1. Generates 1,000 unique product records with attributes including name, description, color, brand, category, gender, and price.
    2. Ensures uniqueness of each product based on a combination of brand, category, color, and gender.
    3. Saves the generated products as a CSV file in the `datalake/raw_products.csv` path.
    4. Calls the `ingest_and_process_products_db` function to:
       - Truncate and ingest the raw product data.
       - Process it into the staging area.
       - Upsert the final version into the production `ProductsDim` table.

    Parameters:
        connection (pyodbc.Connection): Active database connection.
        cursor (pyodbc.Cursor): Database cursor used to execute SQL commands.

    Raises:
        Logs and handles any exceptions during product generation or pipeline execution.
    """
    try:
        logger = logging.getLogger(__name__)

        logger.info("Generating products!")
        fake = Faker()

        brands = ["Nike", "Adidas", "Zara", "H&M", "Uniqlo", "Puma", "Levi's", "Under Armour", "Gap", "Reebok"]
        categories = {
            "Men": ["T-Shirt", "Jeans", "Jacket", "Shoe", "Accessories"],
            "Women": ["Dress", "Blouse", "Skirt", "Shoe", "Handbag"],
            "Kids": ["T-Shirt", "Short", "Sneaker", "Hoodie", "Cap"]
        }
        colors = ["Black", "White", "Red", "Blue", "Green", "Yellow", "Pink", "Gray", "Beige", "Navy"]

        generated_products = list()
        unique_combinations = set()
        category_list = list(categories.keys())

        while len(generated_products) < 1000:
            gender = random.choice(category_list)
            category = random.choice(categories[gender])
            brand = random.choice(brands)
            color = random.choice(colors)

            product_key = (brand, category, color, gender)

            if product_key in unique_combinations:
                continue

            unique_combinations.add(product_key)

            name = f"{brand} {category} {color}"
            description = fake.sentence(nb_words=10)
            price = round(random.uniform(10.0, 300.0), 2)

            product = {
                "name": name,
                "description": description,
                "color": color,
                "brand": brand,
                "category": category,
                "gender": gender,
                "price": price
            }

            generated_products.append(product)

        logger.info("Products saved into datalake!")
        date_str = datetime.now().strftime("%Y%m%d")
        df = pd.DataFrame(generated_products)
        df.to_csv(f"datalake/raw_products_{date_str}.csv", index=False)

        ingest_and_process_products_db(connection, cursor, df)
    except Exception as e:
        logger.error(f"Error during product processing: {e}!")
