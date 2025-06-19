import json
import pyodbc
import logging
import pandas as pd
from faker import Faker
import random
import datetime
import utils.logger_config
from typing import List
from utils.truncate_table import truncate_table
from utils.generate_subset_users import generate_subset_users
from utils.generate_subset_products import generate_subset_products

def generate_cart(products, max_items):
        cart_size = random.randint(1, max_items)
        chosen_products = random.sample(products, cart_size)
        cart = [{prod[1]: float(prod[2])} for prod in chosen_products]
        return cart

def generate_fake_purchase(users, products):
    user_email, country = random.choice(users)
    cart = generate_cart(products, max_items=5)
    date = datetime.datetime.now().strftime('%Y-%m-%d')
    purchase = {
        "UserEmail": user_email,
        "Country": country,
        "Cart": cart,
        "Date": date
    }
    return purchase

def daily_transaction_processing(
    connection: pyodbc.Connection,
    cursor: pyodbc.Cursor
) -> None:
    try:
        logger = logging.getLogger(__name__)

        subset_of_users = generate_subset_users(connection, cursor)
        subset_of_products = generate_subset_products(connection, cursor)

        logger.info("Generating transactions!")
        num_purchases = random.randint(10, 50)
        transaction_list = []
        for _ in range(num_purchases):
            transaction = generate_fake_purchase(subset_of_users, subset_of_products)
            transaction_list.append(transaction)

        transaction_list: List[str] = [
            (json.dumps(transaction),) for transaction in transaction_list
        ]

        truncate_table(connection, cursor, 'raw', 'Transactions')

        sp_call = "{CALL [raw].[IngestRawTransactions] (?)}"

        logger.info("Inserting raw transactions data into the database!")
        cursor.executemany(sp_call, transaction_list)
        connection.commit()
        logger.info("Raw transactions inserted successfully!")

        logger.info("Processing raw transactions into [stage].[Transactions]!")
        cursor.execute("EXEC [stage].[ProcessRawTransactions]")
        connection.commit()
        logger.info("Raw transactions processed successfully!")

        logger.info("Processing stage transactions into [prod].[TransactionsFact]!")
        cursor.execute("EXEC [prod].[InsertTransactionsFact]")
        connection.commit()
        logger.info("Stage transactions processed successfully!")
    except Exception as e:
        logger.error(f"Error during transaction processing: {e}!")