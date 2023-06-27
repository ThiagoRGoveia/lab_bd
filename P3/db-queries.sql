

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


CREATE OR REPLACE FUNCTION overviewConstructor(IDConstructor INT)
RETURNS TABLE ("Nome" TEXT,"Num Vitórias" BIGINT, "Num Drivers" BIGINT, "Primeiro Ano" INT, "Último Ano" INT)
AS
$$
BEGIN
RETURN QUERY SELECT
(SELECT c.name
FROM constructors c
WHERE c.constructorid = IDConstructor),


(SELECT COUNT(re.position)
FROM constructors c
JOIN results re ON c.constructorid = re.constructorid
WHERE c.constructorid = IDConstructor AND
re.position = 1) AS "Vitórias",


(SELECT COUNT(DISTINCT re.driverid)
FROM results re
JOIN constructors c ON c.constructorid = re.constructorid
WHERE c.constructorid = IDConstructor) AS "Num Drivers",


(SELECT MIN(ra.year)
FROM results re
JOIN races ra ON re.raceid = ra.raceid
JOIN constructors c ON re.constructorid = c.constructorid
WHERE c.constructorid = IDConstructor
GROUP BY c.name) AS "Primeiro Ano",


(SELECT MAX(ra.year)
FROM results re
JOIN races ra ON re.raceid = ra.raceid
JOIN constructors c ON re.constructorid = c.constructorid
WHERE c.constructorid = IDConstructor
GROUP BY c.name) AS "Último ano";
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION overviewDriver(IDDriver INT)
RETURNS TABLE ("Nome" TEXT, "Sobrenome" TEXT, "Número de Vitórias" BIGINT, "Ano de Estréia" INT, "Último ano" INT)
AS
$$
BEGIN
RETURN QUERY SELECT
(SELECT d.forename
FROM driver d
WHERE d.driverid = IDDriver) AS "Nome",


(SELECT d.surname
FROM driver d
WHERE d.driverid = IDDriver) AS "Sobrenome",


(SELECT COUNT(re.*)
FROM results re
JOIN driver d ON d.driverid = re.driverid
WHERE re.position = 1 AND
d.driverid = IDDriver) AS "Número de Vitórias",


(SELECT MIN(ra.year)
FROM results re
JOIN races ra ON re.raceid = ra.raceid
JOIN driver d ON re.driverid = d.driverid
WHERE d.driverid = IDDriver
GROUP BY d.driverid) AS "Ano de Estréia",


(SELECT MAX(ra.year)
FROM results re
JOIN races ra ON re.raceid = ra.raceid
JOIN driver d ON re.driverid = d.driverid
WHERE d.driverid = IDDriver
GROUP BY d.driverid) AS "Último ano";


END;
$$
LANGUAGE plpgsql;




-- Relatorio 1


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


CREATE OR REPLACE FUNCTION get_airports_near_city(CITYNAME varchar)
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
-- Exception 2: Invalid City Name Exception
IF NOT EXISTS (SELECT 1 FROM geocities15k WHERE name = CITYNAME) THEN
RAISE EXCEPTION 'Invalid city name: %', CITYNAME;
END IF;


-- Exception 1: No Airports Found Exception
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
AND earth_distance(ll_to_earth(c.lat, c.long), ll_to_earth(a.latdeg, a.longdeg)) <= 100000
AND a.type IN ('medium_airport', 'large_airport')
AND c.country = 'BR'
ORDER BY earth_distance(ll_to_earth(c.lat, c.long), ll_to_earth(a.latdeg, a.longdeg));


IF NOT FOUND THEN
RAISE EXCEPTION 'No airports found within the specified distance.';
END IF;


EXCEPTION
-- Exception 3: Database Error Exception
WHEN OTHERS THEN
RAISE EXCEPTION 'Database error: %', SQLERRM;
END;
$$;


SELECT * FROM get_airports_near_city('Rio de Janeiro');
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


DROP FUNCTION get_driver_wins(integer)


SELECT * FROM get_driver_wins(1);
SELECT * FROM airports


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


select * from status


select * from results


SELECT * FROM get_driver_victories(1);


select * from driver
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




--
CREATE TABLE users (
Userid SERIAL PRIMARY KEY,
Login VARCHAR(255) NOT NULL UNIQUE,
Password VARCHAR(255) NOT NULL,
Type VARCHAR(255) CHECK(Type IN ('Admin', 'Constructor', 'Driver')),
OriginalId INT
);




INSERT into users (Userid, Login, Password, Type, OriginalId) values (1, 'TEST', ('TEST'), 'Admin', 1);


INSERT into users (Userid, Login, Password, Type, OriginalId) values (4, 'CONSTRUCTOR', ('CONSTRUCTOR'), 'Constructor', 4);


INSERT into users (Userid, Login, Password, Type, OriginalId) values (3, 'DRIVER', ('DRIVER'), 'Driver', 3);


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
ELSIF v_password = p_password THEN
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




-- Trigger to sync users with drivers and constructors
CREATE OR REPLACE FUNCTION sync_driver_users()
RETURNS TRIGGER AS $$
BEGIN
IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
INSERT INTO USERS(Login, Password, Type, OriginalId)
VALUES (NEW.driverref || '_d', (NEW.driverref), 'Driver', NEW.driverid)
ON CONFLICT (OriginalId) DO UPDATE
SET Login = NEW.driverref || '_d', Password = (NEW.driverref);
END IF;


RETURN NEW;
END;
$$ LANGUAGE plpgsql;




CREATE TRIGGER sync_driver_users_trigger
AFTER INSERT OR UPDATE
ON driver
FOR EACH ROW
EXECUTE PROCEDURE sync_driver_users();


CREATE OR REPLACE FUNCTION sync_constructor_users()
RETURNS TRIGGER AS $$
BEGIN
IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
INSERT INTO USERS(Login, Password, Type, OriginalId)
VALUES (NEW.constructorref || '_c', (NEW.constructorref), 'constructor', NEW.constructorid)
ON CONFLICT (OriginalId) DO UPDATE
SET Login = NEW.constructorref || '_c', Password = (NEW.constructorref);
END IF;


RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER sync_constructor_users_trigger
AFTER INSERT OR UPDATE
ON constructors
FOR EACH ROW
EXECUTE PROCEDURE sync_constructor_users();


-- CREATE USER
-- Create a function that creates a new user and assigns roles
CREATE OR REPLACE FUNCTION create_db_user()
RETURNS TRIGGER AS $$
DECLARE
user_role NAME;
BEGIN
IF NEW.type = 'Admin' THEN
user_role := 'admin_role';
ELSIF NEW.type = 'Constructor' THEN
user_role := 'constructor_role';
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







