import os
import logging
import utils.logger_config
from utils.connect_to_database import connect_to_database
from user_processing.daily_user_processing import daily_user_processing
from exchange_rate_processing.daily_exchange_rate_processing import daily_exchange_rate_processing
from transaction_processing.daily_transaction_processing import daily_transaction_processing


def main():
    logger = logging.getLogger(__name__)

    server, database = os.getenv('SQL_SERVER'), os.getenv('SQL_DATABASE')
    connection, cursor = connect_to_database(server, database)

    # Start daily user processing
    logger.info("User processing has started!")
    daily_user_processing(connection, cursor)

    # Start daily exchange rate processing
    logger.info("Exchange rate processing has started!")
    daily_exchange_rate_processing(connection, cursor)

    # Start daily exchange rate processing
    logger.info("Transactions processing has started!")
    daily_transaction_processing(connection, cursor)

if __name__ == "__main__":
    main()