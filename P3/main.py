import streamlit as st
from user import User  # Assume this user module exists with all necessary classes & methods

# Global User object
user = None

# Create a session state object
state = SessionState.get(user=None, page="Login") # TODO: adapt this https://docs.streamlit.io/library/api-reference/session-state

def main():
    global user
    st.sidebar.title("Navigation")
    selection = st.sidebar.radio("Go to", ["Login", "Overview", "Reports"])

    if selection == "Login":
        user = login()
    elif selection == "Overview":
        if user is not None:
            overview(user)
        else:
            st.error("Please login first!")
    else:
        if user is not None:
            reports(user)
        else:
            st.error("Please login first!")

# Screen 1: Login Screen
def login():
    st.title("Login Screen")
    username = st.text_input("Username")
    password = st.text_input("Password", type="password")

    if st.button("Login"):
        # This function will verify the user credentials from the database
        user = User.login(username, password)
        if user:
            st.success("Logged in successfully")
            state.page = "Overview"  # change page state
            return user
        else:
            st.error("Invalid Username/Password")

# Screen 2: Overview Screen
def overview(user):
    st.title("Overview Screen")
    
    # The name of the logged-in user, depending on their type
    st.write(f"Hello, {user.get_fullname()}")

    # Overview information according to the user's type
    if user.user_type == 'admin':
        st.write("Admin Overview Info")
    elif user.user_type == 'builder':
        st.write("Builder Overview Info")
    elif user.user_type == 'pilot':
        st.write("Pilot Overview Info")

    # Path (button or link) to Screen 3
    if st.button("Go to Reports"):
        reports(user)

# Screen 3: Reports Screen
def reports(user):
    st.title("Reports Screen")

    if user.user_type == 'admin':
        if st.button("Admin Report"):
            # This function will return the admin report
            report = user.get_admin_report()
            st.write(report)
    elif user.user_type == 'builder':
        if st.button("Builder Report"):
            # This function will return the builder report
            report = user.get_builder_report()
            st.write(report)
    elif user.user_type == 'pilot':
        if st.button("Pilot Report"):
            # This function will return the pilot report
            report = user.get_pilot_report()
            st.write(report)

if __name__ == "__main__":
    main()
