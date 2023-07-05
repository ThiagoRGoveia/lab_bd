import settings
import streamlit as st
import pandas as pd 
from user import User, Admin, Constructor, Driver

# Create a session state object
if "user" not in st.session_state:
    st.session_state.user = None
if "page" not in st.session_state:
    st.session_state.page = "Login"

def main():
    st.sidebar.title("Navigation")
    if 'page' not in st.session_state:
        st.session_state['page'] = 'Login'

    pages = {
        'Login': login,
        'Overview': lambda: overview(st.session_state.user),
        'Reports': lambda: reports(st.session_state.user),
        'Register Constructor': lambda: register_constructor(st.session_state.user),
        'Register Driver': lambda: register_driver(st.session_state.user),
        'Search by Forename': lambda: search_by_forename(st.session_state.user)
    }

    st.session_state.page = st.sidebar.radio("Go to", list(pages.keys()))

    # Call the correct function based on the session_state
    pages[st.session_state.page]()


def update_page_state():
    st.session_state.page = st.sidebar.radio("Go to", ['Login', 'Overview', 'Reports', 'Register Team', 'Register Driver', 'Search by Forename'])

# Screen 1: Login Screen
def login():
    st.title("Login Screen")
    username = st.text_input("Username")
    password = st.text_input("Password", type="password")

    if st.button("Login"):
        # This function will verify the user credentials from the database
        auth = User.login(username, password)
        if auth:
            st.session_state.user = auth
            st.success("Logged in successfully")
            st.session_state.page = "Overview"  # change page state
        else:
            st.error("Invalid Username/Password")

# Screen 2: Overview Screen
def overview(user):
    st.title("Overview Screen")
    
    # The name of the logged-in user, depending on their type
    # Overview information according to the user's type
    data = user.get_overview()  # get the overview data
    if user.user_type == 'Admin':
        st.write("Admin Overview Info")
        df = pd.DataFrame(data, columns=["Número de pilotos", "Número de Escuderias", "Número de Corridas", "Número de Temporadas"])
        st.dataframe(df,hide_index=True)
    elif user.user_type == 'Constructor':
        st.write("Constructor Overview Info")
        df = pd.DataFrame(data, columns=["Nome", "Num Vitórias", "Num Drivers", "Primeiro Ano", "Último Ano"])
        st.dataframe(df, hide_index=True)
    elif user.user_type == 'Driver':
        st.write("Driver Overview Info")
        df = pd.DataFrame(data, columns=["Nome", "Sobrenome", "Número de Vitórias", "Ano de Estréia", "Último Ano"])
        st.dataframe(df, hide_index=True)

    # Path (button or link) to Screen 3
    # if st.button("Go to Reports"):
    #     reports(st.session_state.user)

# Screen 3: Reports Screen
def reports(user):
    st.title("Reports Screen")
    if user.user_type == 'Admin':
        reports = {
            'Relatório - Status dos Pilotos': lambda: show_status_count_report(user),
            'Relatório - Aeroportos próximos à cidade': lambda: show_airports_near_city_report(user)
        }
        st.session_state.page = st.radio("Escolha", list(reports.keys()))
        reports[st.session_state.page]()

    elif user.user_type == 'Constructor':
        reports = {
            'Relatório - Vitórias da Escuderia': lambda: show_constructor_wins_report(user),
            'Relatório - Status da Escuderia': lambda: show_constructor_status_report(user)
        }
        st.session_state.page = st.radio("Escolha", list(reports.keys()))
        reports[st.session_state.page]()
           
    elif user.user_type == 'Driver':
        reports = {
            'Relatório - Vitorias do Piloto': lambda: show_driver_wins_report(user),
            'Relatório - Status do Piloto': lambda: show_driver_status_report(user)
        }
        st.session_state.page = st.radio("Escolha", list(reports.keys()))
        reports[st.session_state.page]()
            

def show_status_count_report(user):
    st.title("Status Count Report")
    # This function will return the Admin report
    report = user.get_status_count_report()
    df = pd.DataFrame(report, columns=["Status", "Contagem"])
    st.dataframe(df,hide_index=True)

def show_airports_near_city_report(user):
    st.title("Airports Near City Report")
    city = st.text_input("Cidade")
    if st.button("Buscar"):
        st.write("Aeroportos próximos a: ", city)
        report = user.get_airports_near_city_report(city)
        df = pd.DataFrame(report, columns=["Cidade Busca", "Sigla", "Nome", "Cidade Aeroporto", "Distancia (m)", "Tipo Aeroporto" ])
        st.dataframe(df,hide_index=True)

def register_constructor(user):
    if (user.user_type) != 'Admin':
        st.write("Access not allowed! Go back.")
    else:
        st.title("Register Constructor")
        ConstructorRef = st.text_input("Constructor Reference")
        Name = st.text_input("Name")
        Nationality = st.text_input("Nationality")
        url = st.text_input("URL")
        if st.button("Register Constructor"):
            try:
                create = user.create_constructor(ConstructorRef, Name, Nationality, url)
                st.success("Constructor registered successfully")
            except Exception as e:
                st.error("Constructor registration failed, error: " + str(e))


def register_driver(user):

    if (user.user_type) != 'Admin':
        st.write("Access not allowed! Go back.")
    else:
        st.title("Register Driver")
        DriverRef = st.text_input("Driver Reference")
        Number = st.text_input("Number")
        Code = st.text_input("Code")
        Forename = st.text_input("Forename")
        Surname = st.text_input("Surname")
        Date_of_Birth = st.date_input("Date of Birth")
        Nationality = st.text_input("Nationality")
        URL = st.text_input("URL")

        if st.button("Register Driver"):
            try: 
                user.create_driver(DriverRef, Number, Code, Forename, Surname, Date_of_Birth, Nationality,URL)
                st.success("Driver registered successfully")
            except Exception as e:
                st.error("Driver registration failed, error: " + str(e))
        


def search_by_forename(user):

    if (user.user_type) != 'Constructor':
        st.write("Access not allowed! Go back.")
    else:
        st.title("Search by Forename")
        Forename = st.text_input("Forename")
        if st.button("Search"):
            try:
                result = user.search_driver_by_forename(Forename)
                # Displaying the result of the search to the user
                for row in result:
                    st.write(f"Full Name: {row[0]}, Date of Birth: {row[1]}, Nationality: {row[2]}")
                    st.success("Search complete")   

            except Exception as e:
                st.error("Search failed, error: " + str(e))


def show_constructor_wins_report(user):
    st.title("Team Wins Report")
    report = user.get_constructor_wins_report()
    df = pd.DataFrame(report, columns=["Nome", "Num Vitórias"])
    st.dataframe(df,hide_index=True)

def show_constructor_status_report(user):
    st.title("Team Status Report")
    report = user.get_constructor_status_report()
    df = pd.DataFrame(report, columns=["Status", "Numero"])
    st.dataframe(df,hide_index=True)


def show_driver_wins_report(user): 
    st.title("Driver Wins Report")
    report = user.get_driver_wins_report()
    df = pd.DataFrame(report, columns=["Ano", "Corrida", "Nome", "Num Vitórias"])
    st.dataframe(df,hide_index=True)

def show_driver_status_report(user):
    st.title("Driver Status Report")
    report = user.get_driver_status_report()
    df = pd.DataFrame(report, columns=["Status", "Numero"])
    st.dataframe(df,hide_index=True)


if __name__ == "__main__":
    main()
