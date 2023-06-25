from pg import DatabaseConnection
import os

class User:
    def __init__(self, username, password, user_type, user_id = None):
        self.username = username
        self.password = password
        self.user_type = user_type
        self.user_id = user_id
        self.db = DatabaseConnection(username, password)
        print('USER', username, password, user_type, user_id)
        self.db.open_connection()

    @classmethod
    def login(cls, username, password):
        try:
            db = DatabaseConnection(os.environ.get('AUTH_DB_USER'), os.environ.get('AUTH_DB_PASSWORD'))
            db.open_connection()
            auth =db.query("SELECT * from authenticate_user(%s,%s)", (username, password))
            db.close_connection()

            print('AUTH', auth)

            if (auth[0][0] == 'Admin'):
                return Admin(username, password, auth[0][0], auth[0][1])
            elif (auth[0][0] == 'Constructor'):
                return Constructor(username, password, auth[0][0], auth[0][1])
            elif (auth[0][0] == 'Pilot'):
                return Driver(username, password, auth[0][0], auth[0][1])

        except Exception as e:
            print(e)
            return False
        pass

    
    def create_constructor(self):
        raise Exception("This user is not allowed to create a team")

    def create_driver(self):
        raise Exception("This user is not allowed to create a driver")





class Admin(User):
    def __init__(self, username, password, user_type, user_id = None):
        super().__init__(username, password, user_type, user_id)

    def get_overview(self):
        """
        This method should return the full name of the user
        """
        pass

    def get_report(self):
        """
        This method should return a report for an admin user
        """
        pass
    
    def create_constructor(self):
        """
        This method should create a team
        """
        pass

    def create_driver(self):
        """
        This method should create a driver
        """
        pass
    

class Constructor(User):
    def __init__(self, username, password, user_type, user_id = None):
        super().__init__(username, password, user_type, user_id)

    def get_overview(self):
        """
        This method should return the full name of the user
        """
        pass

    def get_report(self):
        """
        This method should return a report for a constructor user
        """
        pass

    def search_pilot(self):
        """
        This method should search a pilot
        """
        pass


class Driver(User):
    def __init__(self, username, password, user_type, user_id = None):
        super().__init__(username, password, user_type, user_id)

    def get_overview(self):
        """
        This method should return the full name of the user
        """
        pass

    def get_report(self):
        """
        This method should return a report for a pilot user
        """
        pass
