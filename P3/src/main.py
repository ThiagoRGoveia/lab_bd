import settings
import streamlit as st
from user import User

# Create a session state object
if "user" not in st.session_state:
    st.session_state.user = None
if "page" not in st.session_state:
    st.session_state.page = "Login"

def main():
    st.sidebar.title("Navigation")
    selection = st.sidebar.radio("Go to", ["Login", "Overview", "Reports", "Register Team", "Register Driver", "Search by Forename"])

    if selection == "Login":
        st.session_state.user = login()
    elif selection == "Overview":
        if st.session_state.user is not None:
            overview(st.session_state.user)
        else:
            st.error("Please login first!")
    elif selection == "Reports":
        if st.session_state.user is not None:
            reports(st.session_state.user)
        else:
            st.error("Please login first!")
    elif selection == "Register Team":
        if st.session_state.user is not None and st.session_state.user.user_type == 'Admin':
            register_team()
        else:
            st.error("Only Admins can register teams!")
    elif selection == "Register Driver":
        if st.session_state.user is not None and st.session_state.user.user_type == 'Admin':
            register_driver()
        else:
            st.error("Only Admins can register drivers!")
    elif selection == "Search by Forename":
        if st.session_state.user is not None and st.session_state.user.user_type == 'builder':
            search_by_forename()
        else:
            st.error("Only constructors can search by forename!")

# Screen 1: Login Screen
def login():
    st.title("Login Screen")
    username = st.text_input("Username")
    password = st.text_input("Password", type="password")

    if st.button("Login"):
        # This function will verify the user credentials from the database
        auth = User.login(username, password)
        if auth:
            print('AUTH', auth[0], auth[1])
            st.success("Logged in successfully")
            st.session_state.page = "Overview"  # change page state
            overview(st.session_state.user)
            return User(username, password, auth[0], auth[1])
        else:
            st.error("Invalid Username/Password")

# Screen 2: Overview Screen
def overview(user):
    st.title("Overview Screen")
    
    # The name of the logged-in user, depending on their type
    st.write(f"Hello, {user.get_fullname()}")

    # Overview information according to the user's type
    if user.user_type == 'Admin':
        st.write("Admin Overview Info")
    elif user.user_type == 'builder':
        st.write("Constructor Overview Info")
    elif user.user_type == 'pilot':
        st.write("Pilot Overview Info")

    # Path (button or link) to Screen 3
    if st.button("Go to Reports"):
        reports(user)

# Screen 3: Reports Screen
def reports(user):
    st.title("Reports Screen")

    if user.user_type == 'Admin':
        if st.button("Admin Report"):
            # This function will return the Admin report
            report = user.get_Admin_report()
            st.write(report)
    elif user.user_type == 'builder':
        if st.button("Constructor Report"):
            # This function will return the builder report
            report = user.get_builder_report()
            st.write(report)
    elif user.user_type == 'pilot':
        if st.button("Pilot Report"):
            # This function will return the pilot report
            report = user.get_pilot_report()
            st.write(report)


def register_team():
    st.title("Register Team")
    ConstructorRef = st.text_input("Constructor Reference")
    Name = st.text_input("Name")
    Nationality = st.text_input("Nationality")
    URL = st.text_input("URL")

    if st.button("Register Team"):
        # This function will add the team to the CONSTRUCTORS table in the database
        # Also, a trigger should be set on this table to add the user to the USERS table
        # The logic to do this is not included in this code
        st.success("Team registered successfully")


def register_driver():
    st.title("Register Driver")
    DriverRef = st.text_input("Driver Reference")
    Number = st.text_input("Number")
    Code = st.text_input("Code")
    Forename = st.text_input("Forename")
    Surname = st.text_input("Surname")
    Date_of_Birth = st.date_input("Date of Birth")
    Nationality = st.text_input("Nationality")

    if st.button("Register Driver"):
        # This function will add the driver to the DRIVERS table in the database
        # Also, a trigger should be set on this table to add the user to the USERS table
        # The logic to do this is not included in this code
        st.success("Driver registered successfully")


def search_by_forename():
    st.title("Search by Forename")
    Forename = st.text_input("Forename")

    if st.button("Search"):
        # This function will search the DRIVERS table for drivers with the input forename
        # Then, it will cross-reference these drivers with the RESULTS table to find drivers who have raced for the logged-in team
        # The logic to do this is not included in this code
        st.success("Search complete")


if __name__ == "__main__":
    main()
