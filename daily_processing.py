import os
from utils.connect_to_database import connect_to_database
from user_processing.daily_user_processing import daily_user_processing
from exchange_rate_processing.daily_exchange_rate_processing import daily_exchange_rate_processing


def main():
    server, database = os.getenv('SQL_SERVER'), os.getenv('SQL_DATABASE')
    connection, cursor = connect_to_database(server, database)

    # # Start daily user processing
    # daily_user_processing(connection, cursor)

    # Start daily exchange rate processing
    daily_exchange_rate_processing(connection, cursor)

if __name__ == "__main__":
    main()