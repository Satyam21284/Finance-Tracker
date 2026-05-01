from expense_tracker.core.config import Config
from expense_tracker.core.db_conn import get_db_connection

def db_conn_test():

    config_details = Config.get_db_config()
    db_conn = get_db_connection()
    print(f'Connection Successful: {db_conn.is_connected()}')
    db_conn.close()


if __name__ == '__main__':
    db_conn_test()
