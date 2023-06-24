CREATE OR REPLACE FUNCTION overviewAdmin()
RETURNS TABLE ("Num Pilotos" BIGINT, "Num Escuderias" BIGINT, "Num Corridas" BIGINT, "Num Temporadas" BIGINT)
AS
$$
BEGIN
	RETURN QUERY SELECT
					(SELECT COUNT(DISTINCT driverid) FROM driver) AS "Num Pilotos",
					(SELECT COUNT(DISTINCT constructorid) FROM constructors) AS "Num Escuderias",
					(SELECT COUNT(DISTINCT raceid) FROM races) AS "Num Corridas",
					(SELECT COUNT(DISTINCT year) FROM seasons) AS "Num Temporadas";
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION overviewEscuderia(IDEscuderia INT)
RETURNS TABLE ("Nome" TEXT,"Num Vitórias" BIGINT, "Num Pilotos" BIGINT, "Primeiro Ano" INT, "Último Ano" INT)
AS
$$
BEGIN
	RETURN QUERY SELECT
		(SELECT c.name
		FROM constructors c
	   	WHERE c.constructorid = IDEscuderia),

	           (SELECT COUNT(re.position)
		FROM constructors c
		JOIN results re ON c.constructorid = re.constructorid
		WHERE c.constructorid = IDEscuderia AND
       		  re.position = 1) AS "Vitórias",

		(SELECT COUNT(DISTINCT re.driverid)
		FROM results re
		JOIN constructors c ON c.constructorid = re.constructorid
		WHERE c.constructorid = IDEscuderia) AS "Num Pilotos",

		(SELECT MIN(ra.year)
		FROM results re
		JOIN races ra ON re.raceid = ra.raceid
		JOIN constructors c ON re.constructorid = c.constructorid
		WHERE c.constructorid = IDEscuderia
		GROUP BY c.name) AS "Primeiro Ano",

		(SELECT MAX(ra.year)
		FROM results re
		JOIN races ra ON re.raceid = ra.raceid
		JOIN constructors c ON re.constructorid = c.constructorid
		WHERE c.constructorid = IDEscuderia
		GROUP BY c.name) AS "Último ano";
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION overviewPiloto(IDPiloto INT)
RETURNS TABLE ("Nome" TEXT, "Sobrenome" TEXT, "Número de Vitórias" BIGINT, "Ano de Estréia" INT, "Último ano" INT)
AS
$$
BEGIN
	RETURN QUERY SELECT
		(SELECT d.forename
		 FROM driver d
		 WHERE d.driverid = IDPiloto) AS "Nome",

		(SELECT d.surname
		 FROM driver d
		 WHERE d.driverid = IDPiloto) AS "Sobrenome",

		(SELECT COUNT(re.*)
		 FROM results re
		 JOIN driver d ON d.driverid = re.driverid
		 WHERE re.position = 1 AND
		       d.driverid = IDPiloto) AS "Número de Vitórias",

		(SELECT MIN(ra.year)
		 FROM results re
		 JOIN races ra ON re.raceid = ra.raceid
		 JOIN driver d ON re.driverid = d.driverid
		 WHERE d.driverid = IDPiloto
		 GROUP BY d.driverid) AS "Ano de Estréia",

		 (SELECT MAX(ra.year)
		 FROM results re
		 JOIN races ra ON re.raceid = ra.raceid
		 JOIN driver d ON re.driverid = d.driverid
		 WHERE d.driverid = IDPiloto
		 GROUP BY d.driverid) AS "Último ano";

END;
$$
LANGUAGE plpgsql



CREATE OR REPLACE FUNCTION get_status_count()
RETURNS TABLE (
    status_name varchar,
    count bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT s.status, COUNT(r.statusid)
    FROM results r
    JOIN status s ON s.statusid = r.statusid
    GROUP BY s.status
    ORDER BY COUNT(r.statusid) DESC;
END;
$$;


SELECT * FROM get_status_count();


-- Relatorio 2


CREATE INDEX idx_airports_type ON airports(type);
CREATE INDEX idx_cities_name ON geocities15k(name);
CREATE INDEX idx_airports_country ON airports(isocountry);


CREATE OR REPLACE FUNCTION get_airports_near_city(CITYNAME text)
RETURNS TABLE (
    city_name varchar,
    iatacode varchar,
    airport_name varchar,
    airport_city varchar,
    distance double precision,
    airport_type varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT c.name,
           a.iatacode,
           a.name,
           a.city,
           earth_distance(ll_to_earth(c.lat, c.long), ll_to_earth(a.latdeg, a.longdeg)),
           a.type
    FROM airports a
    JOIN geocities15k c ON a.isocountry = c.country
    WHERE c.name = CITYNAME
          AND earth_distance(ll_to_earth(c.lat, c.long), ll_to_earth(a.latdeg, a.longdeg)) <= 1000
          AND a.type IN ('medium_airport', 'large_airport')
          AND c.country = 'BR'
    ORDER BY earth_distance(ll_to_earth(c.lat, c.long), ll_to_earth(a.latdeg, a.longdeg));
END;
$$;


DROP FUNCTION get_airports_near_city(text);


SELECT * FROM get_airports_near_city('Rio de Janeiro');


-- SELECT * FROM airports where airports.isocountry = 'BR' and airports.type IN ('medium_airport', 'large_airport')


-- select * from geocities15k where geocities15k.country = 'BR'
--
--
-- select * from geocities15k
--
--
-- select * from geocities15k where geocities15k.name = 'Rio de Janeiro'


SELECT earth_distance(
    ll_to_earth(40.7128, -74.0060),  -- Coordenadas de Nova Iorque (lat, long)
    ll_to_earth(34.0522, -118.2437)  -- Coordenadas de Los Angeles (lat, long)
) AS distance_in_meters;


-- Relatorio 3


CREATE OR REPLACE FUNCTION get_driver_wins(CONSTRUCTOR_ID int)
RETURNS TABLE (
    driver_name text,
    wins bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT d.forename || ' ' || d.surname AS full_name, COUNT(r.raceid)
    FROM results r
    JOIN driver d ON d.driverid = r.driverid
    WHERE r.position = 1 AND r.constructorid = CONSTRUCTOR_ID
    GROUP BY d.forename, d.surname
    ORDER BY COUNT(r.raceid) DESC;
END;
$$;


DROP FUNCTION get_driver_wins(integer);


SELECT * FROM get_driver_wins(1);


-- Relatorio 4


CREATE OR REPLACE FUNCTION get_constructor_status_count(CONSTRUCTOR_ID int)
RETURNS TABLE (
    status varchar,
    count bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT s.status, COUNT(r.resultid)
    FROM results r
    JOIN status s ON s.statusid = r.statusid
    WHERE r.constructorid = CONSTRUCTOR_ID
    GROUP BY s.status
    ORDER BY COUNT(r.resultid) DESC;
END;
$$;


SELECT * FROM get_constructor_status_count(1);


-- Relatorio 5




CREATE OR REPLACE FUNCTION get_driver_victories(DRIVER_ID int)
RETURNS TABLE (
    year int,
    race_name varchar,
    victories_count bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT ra.year, ra.name, COUNT(*)
    FROM results res
    JOIN races ra ON res.raceid = ra.raceid
    JOIN driver d ON res.driverid = d.driverid
    JOIN status s ON res.statusid = s.statusid
    WHERE d.driverid = DRIVER_ID AND s.status = 'Finished' AND res.number = 1
    GROUP BY ROLLUP(ra.year, ra.name)
    ORDER BY ra.year, COUNT(*) DESC;
END;
$$;


drop function get_driver_victories(driver_id integer)


-- Relatorio 6


CREATE OR REPLACE FUNCTION get_driver_status(DRIVER_ID int)
RETURNS TABLE (
    status varchar,
    status_count bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT s.status, COUNT(*)
    FROM results res
    JOIN status s ON res.statusid = s.statusid
    WHERE res.driverid = DRIVER_ID
    GROUP BY s.status
    ORDER BY COUNT(*) DESC;
END;
$$;


SELECT * FROM get_driver_status(2);



-- Admin
-- Para adicionar nova escuderia
CREATE OR REPLACE FUNCTION cadastrarEscuderia(_ConstructorRef VARCHAR, _Name VARCHAR, _Nationality VARCHAR, _URL VARCHAR)
RETURNS VOID AS $$
DECLARE
   _constructorid INT;
BEGIN
   SELECT COALESCE(MAX(constructorid), 0) + 1 INTO _constructorid FROM CONSTRUCTORS;
   INSERT INTO CONSTRUCTORS (constructorid, ConstructorRef, Name, nationality, URL)
   VALUES (_constructorid, _ConstructorRef, _Name, _Nationality, _URL);
EXCEPTION
   WHEN unique_violation THEN
       RAISE EXCEPTION 'Construtor já existe.';
END;
$$ LANGUAGE plpgsql;




-- Para adicionar novo piloto
CREATE OR REPLACE FUNCTION cadastrarPiloto(_DriverRef VARCHAR, _Number INT, _Code VARCHAR, _Forename VARCHAR, _Surname VARCHAR, _DateOfBirth DATE, _Nationality VARCHAR)
RETURNS VOID AS $$
DECLARE
   _DriverID INT;
BEGIN
   SELECT COALESCE(MAX(driverid), 0) + 1 INTO _DriverID FROM DRIVER;
   INSERT INTO DRIVER (driverid, driverref, number, code, forename, surname, dateofbirth, nationality)
   VALUES (_DriverID, _DriverRef, _Number, _Code, _Forename, _Surname, _DateOfBirth, _Nationality);
EXCEPTION
   WHEN unique_violation THEN
       RAISE EXCEPTION 'Piloto já existe.';
END;
$$ LANGUAGE plpgsql;




--Escuderia
-- Consulta o piloto por nome
CREATE OR REPLACE FUNCTION consultarPilotoPorNome(_Forename TEXT, _ConstructorRef VARCHAR)
RETURNS TABLE(FullName TEXT, DateOfBirth DATE, Nationality VARCHAR) AS $$
BEGIN
   RETURN QUERY
   SELECT d.Forename || ' ' || d.Surname, d.dateofbirth, d.Nationality
   FROM DRIVER d
   JOIN RESULTS r ON d.driverid = r.driverid
   JOIN CONSTRUCTORS c ON r.constructorid = c.constructorid
   WHERE d.Forename = _Forename AND c.ConstructorRef = _ConstructorRef;
END;
$$ LANGUAGE plpgsql;




-- Admin
-- Para adicionar nova escuderia
CREATE OR REPLACE FUNCTION cadastrarEscuderia(_ConstructorRef VARCHAR, _Name VARCHAR, _Nationality VARCHAR, _URL VARCHAR)
RETURNS VOID AS $$
DECLARE
    _constructorid INT;
BEGIN
    SELECT COALESCE(MAX(constructorid), 0) + 1 INTO _constructorid FROM CONSTRUCTORS;
    INSERT INTO CONSTRUCTORS (constructorid, ConstructorRef, Name, nationality, URL)
    VALUES (_constructorid, _ConstructorRef, _Name, _Nationality, _URL);
EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Construtor já existe.';
END;
$$ LANGUAGE plpgsql;


-- Para adicionar novo piloto
CREATE OR REPLACE FUNCTION cadastrarPiloto(_DriverRef VARCHAR, _Number INT, _Code VARCHAR, _Forename VARCHAR, _Surname VARCHAR, _DateOfBirth DATE, _Nationality VARCHAR)
RETURNS VOID AS $$
DECLARE
    _DriverID INT;
BEGIN
    SELECT COALESCE(MAX(driverid), 0) + 1 INTO _DriverID FROM DRIVER;
    INSERT INTO DRIVER (driverid, driverref, number, code, forename, surname, dateofbirth, nationality)
    VALUES (_DriverID, _DriverRef, _Number, _Code, _Forename, _Surname, _DateOfBirth, _Nationality);
EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Piloto já existe.';
END;
$$ LANGUAGE plpgsql;


--Escuderia
-- Consulta o piloto por nome
CREATE OR REPLACE FUNCTION consultarPilotoPorNome(_Forename TEXT, _ConstructorRef VARCHAR)
RETURNS TABLE(FullName TEXT, DateOfBirth DATE, Nationality VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT d.Forename || ' ' || d.Surname, d.dateofbirth, d.Nationality
    FROM DRIVER d
    JOIN RESULTS r ON d.driverid = r.driverid
    JOIN CONSTRUCTORS c ON r.constructorid = c.constructorid
    WHERE d.Forename = _Forename AND c.ConstructorRef = _ConstructorRef;
END;
$$ LANGUAGE plpgsql;


-- Description: SQL script to create tables and functions for authentication
CREATE TABLE users (
  Userid SERIAL PRIMARY KEY,
  Login VARCHAR(255) NOT NULL UNIQUE,
  Password VARCHAR(255) NOT NULL,
  Type VARCHAR(255) CHECK(Type IN ('Admin', 'Constructor', 'Driver')),
  OriginalId INT
);

INSERT into users (Userid, Login, Password, Type, OriginalId) values (1, 'TEST', md5('TEST'), 'Admin', 1);

CREATE TABLE logs (
  LogId SERIAL PRIMARY KEY,
  Userid INT REFERENCES users(Userid),
  Date DATE NOT NULL DEFAULT CURRENT_DATE,
  LoginTime TIME NOT NULL DEFAULT CURRENT_TIME
);




-- Authentication function
CREATE OR REPLACE FUNCTION authenticate_user(p_login VARCHAR(255), p_password VARCHAR(255))
RETURNS TABLE (UserType VARCHAR, OriginalId INT) AS $$
DECLARE
    v_password VARCHAR(255);
    v_user_id INT;
    v_type VARCHAR(255);
    v_original_id INT;
BEGIN
    SELECT u.UserId, u.Password, u.Type, u.OriginalId INTO v_user_id, v_password, v_type, v_original_id
    FROM USERS u
    WHERE Login = p_login;

    IF v_password IS NULL THEN
        RAISE EXCEPTION 'User does not exist';
    ELSIF v_password = md5(p_password) THEN
        INSERT INTO logs (UserId, Date, LoginTime) VALUES (v_user_id, CURRENT_DATE, CURRENT_TIME); -- TODO: isso não está funcionando
        RETURN QUERY SELECT v_type, v_original_id;
    ELSE
        RAISE EXCEPTION 'Invalid password';
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- Create limited user that only runs the authenticate_user function
CREATE USER limited_user WITH PASSWORD 'limited123';
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON TABLES FROM limited_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON SEQUENCES FROM limited_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE ALL ON FUNCTIONS FROM limited_user;
GRANT EXECUTE ON FUNCTION authenticate_user(VARCHAR(255), VARCHAR(255)) TO limited_user;


-- Trigger to sync users with drivers and teams
CREATE OR REPLACE FUNCTION sync_driver_users()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
    INSERT INTO USERS(Login, Password, Type, OriginalId)
    VALUES (NEW.driverref || ' d', md5(NEW.driverref), 'Driver', NEW.driverid)
    ON CONFLICT (OriginalId) DO UPDATE
    SET Login = NEW.driverref || ' d', Password = md5(NEW.driverref);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER sync_driver_users_trigger
AFTER INSERT OR UPDATE
ON driver
FOR EACH ROW
EXECUTE PROCEDURE sync_driver_users();

CREATE OR REPLACE FUNCTION sync_team_users()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
    INSERT INTO USERS(Login, Password, Type, OriginalId)
    VALUES (NEW.constructorref || ' c', md5(NEW.constructorref), 'Team', NEW.constructorid)
    ON CONFLICT (OriginalId) DO UPDATE
    SET Login = NEW.constructorref || ' c', Password = md5(NEW.constructorref);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER sync_team_users_trigger
AFTER INSERT OR UPDATE
ON constructors
FOR EACH ROW
EXECUTE PROCEDURE sync_team_users();





-- CREATE USER
-- Create a function that creates a new user and assigns roles
CREATE OR REPLACE FUNCTION create_db_user()
RETURNS TRIGGER AS $$
DECLARE
    user_role NAME;
BEGIN
    IF NEW.type = 'Admin' THEN
        user_role := 'admin_role';
    ELSIF NEW.type = 'Team' THEN
        user_role := 'team_role';
    ELSIF NEW.type = 'Driver' THEN
        user_role := 'driver_role';
    ELSE
        RAISE EXCEPTION 'Unknown user type: %', NEW.type;
    END IF;

    -- Use EXECUTE to interpolate the username and password
    EXECUTE format('CREATE USER %I WITH PASSWORD %L;', NEW.login, NEW.password);
    EXECUTE format('GRANT %I TO %I;', user_role, NEW.login);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a trigger that calls the function when a new row is inserted
CREATE TRIGGER user_insertion AFTER INSERT ON USERS
FOR EACH ROW EXECUTE PROCEDURE create_db_user();



-- ROLE MANAGEMENT
CREATE ROLE admin_role;
CREATE ROLE team_role;
CREATE ROLE driver_role;


-- Admin has free access
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin_role;

-- Team can access constructors and drivers
GRANT SELECT, UPDATE, INSERT, DELETE ON constructors, driver TO team_role;

-- Driver can access results
GRANT SELECT, UPDATE, INSERT, DELETE ON results TO driver_role;


-- Enable row level security
ALTER TABLE constructors ENABLE ROW LEVEL SECURITY;
ALTER TABLE driver ENABLE ROW LEVEL SECURITY;

-- For team, they can only access rows that belong to them
CREATE POLICY team_constructors_policy ON constructors
  USING (ConstructorId = current_setting('env.userid')::int);

CREATE POLICY team_drivers_policy ON results
  USING (ConstructorId = current_setting('env.constructorid')::int);


-- Enable row level security
ALTER TABLE results ENABLE ROW LEVEL SECURITY;

-- For drivers, they can only access rows that belong to them
CREATE POLICY driver_results_policy ON results
  USING (DriverId = current_setting('env.userid')::int);