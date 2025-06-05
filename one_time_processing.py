import os
import logging
import utils.logger_config
from utils.connect_to_database import connect_to_database
from product_processing.product_processing import product_processing


def main():
    logger = logging.getLogger(__name__)

    server, database = os.getenv('SQL_SERVER'), os.getenv('SQL_DATABASE')
    connection, cursor = connect_to_database(server, database)

    logger.info("Product processing has started!")
    product_processing(connection, cursor)

if __name__ == "__main__":
    main()