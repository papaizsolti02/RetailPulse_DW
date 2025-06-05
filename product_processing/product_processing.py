import pyodbc
import random
import pandas as pd
from faker import Faker
from .ingest_and_process_products_db import ingest_and_process_products_db

def product_processing(
    connection: pyodbc.Connection,
    cursor: pyodbc.Cursor
) -> None:
    try:
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

        df = pd.DataFrame(generated_products)
        df.to_csv("datalake/raw_products.csv", index=False)

        ingest_and_process_products_db(connection, cursor, df)
    except Exception as e:
        print(f"Error during product processing: {e}")