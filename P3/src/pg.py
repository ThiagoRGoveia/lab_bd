import psycopg2
import os

class DatabaseConnection:
    def __init__(self, user, password):
        self.dbname = os.environ.get('DB_NAME')
        self.user = 'postgres'
        self.password = 'changeme'
        self.host = os.environ.get('DB_HOST')
        self.port = os.environ.get('DB_PORT')

    def open_connection(self):
        self.conn = psycopg2.connect(
            dbname=self.dbname,
            user=self.user.lower(),
            password=self.password,
            host=self.host,
            port=self.port
        )
        self.cur = self.conn.cursor()

    def set_user_id(self, userid):
        self.cur.execute("SET myvars.userid = %s", (userid,))

    def query(self, query, params=None):
        self.cur.execute(query, params)
        return self.cur.fetchall()

    def close_connection(self):
        self.conn.close()

# Usage:
# db = DatabaseConnection(dbname="your_database_name", user="your_username", password="your_password")
# db.open_connection()
# db.set_user_id(userid="your_user_id")
# rows = db.get_data(table_name="your_table")
# print(rows)
# db.close_connection()
