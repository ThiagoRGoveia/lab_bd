-- Setup tables for row level security
ALTER TABLE qualifying ENABLE ROW LEVEL SECURITY;
ALTER TABLE results ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE constructors ENABLE ROW LEVEL SECURITY;
ALTER TABLE driver ENABLE ROW LEVEL SECURITY;


-- USER INSERTS
INSERT INTO users (login, password, type, originalid) VALUES ('admin', md5('admin'), 'Admin', null);
CREATE USER admin WITH PASSWORD 'admin';
ALTER USER admin WITH SUPERUSER;

-- This function creates a new postgres user and assigns roles
CREATE OR REPLACE function create_db_user(login character varying, password character varying, type character varying) returns void
    security definer
    language plpgsql
as
$$
    DECLARE
        user_role NAME;
    BEGIN
        IF type = 'Constructor' THEN
            user_role := 'constructor_role';
        ELSIF type = 'Driver' THEN
            user_role := 'driver_role';
        ELSE
            RAISE EXCEPTION 'Unknown user type: %', type;
        END IF;


-- Use EXECUTE to interpolate the username and password
EXECUTE format('CREATE USER %I WITH PASSWORD %L;', login, password);
EXECUTE format('GRANT %I TO %I;', user_role, login);


END;
$$;

CREATE OR REPLACE FUNCTION authenticate_user(p_login character varying, p_password character varying)
    returns TABLE(usertype character varying, originalid integer)
    security definer
    language plpgsql
as
$$
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
$$;


-- CONSTRUCTOR ROLE
CREATE ROLE constructor_role;
-- Grant usage on schema
GRANT USAGE ON SCHEMA public TO constructor_role;


-- Assuming the constructors need to access and manipulate data in the tables 'qualifying' and 'results'
-- Grant permissions on 'qualifying' table
GRANT SELECT ON users TO constructor_role;
GRANT SELECT ON constructors TO constructor_role;
GRANT SELECT ON qualifying TO constructor_role;
GRANT SELECT ON results TO constructor_role;
GRANT SELECT ON driver TO constructor_role;
GRANT SELECT ON races TO constructor_role;
GRANT SELECT ON status TO constructor_role;

DROP POLICY IF EXISTS constructor_users_policy ON users;
DROP POLICY IF EXISTS constructor_qualifying_policy ON qualifying;
DROP POLICY IF EXISTS constructor_results_policy ON results;
DROP POLICY IF EXISTS constructor_results_policy ON constructors;

-- Apply policies
-- Policy to allow select on users table only to the user that created the row
CREATE POLICY constructor_users_policy ON users
    FOR SELECT
    TO constructor_role
    USING (login = current_user);


CREATE POLICY constructor_qualifying_policy ON qualifying
    FOR SELECT
    TO constructor_role
    USING (EXISTS (SELECT 1 FROM users WHERE login = current_user and originalid = constructorid limit 1));

CREATE POLICY constructor_results_policy ON results
FOR SELECT
    TO constructor_role
    USING (EXISTS (SELECT 1 FROM users WHERE login = current_user and originalid = constructorid limit 1));

CREATE POLICY constructor_results_policy ON constructors
FOR SELECT
    TO constructor_role
    USING (EXISTS (SELECT 1 FROM users WHERE login = current_user and originalid = constructorid limit 1));

CREATE POLICY constructor_driver_policy ON driver
FOR SELECT
    TO constructor_role
    USING (EXISTS (SELECT 1 FROM results WHERE constructorid in (SELECT constructorid FROM users WHERE login = current_user)
                     and driver.driverid = results.driverid
    LIMIT 1));

CREATE POLICY constructor_races_policy
ON races FOR
    SELECT  TO constructor_role USING (EXISTS (
    SELECT  1
    FROM results
    WHERE constructorid IN ( SELECT originalid FROM users WHERE login = current_user)
    AND results.raceid = races.raceid
LIMIT 1));

-- DRVER ROLE
CREATE ROLE driver_role;

-- Grant usage on schema
GRANT USAGE ON SCHEMA public TO driver_role;

GRANT SELECT ON users TO driver_role;
GRANT SELECT ON qualifying TO driver_role;
GRANT SELECT ON results TO driver_role;
GRANT SELECT ON driver TO driver_role;
GRANT SELECT ON races TO driver_role;
GRANT SELECT ON status TO driver_role;


DROP POLICY IF EXISTS driver_qualifying_policy ON qualifying;
DROP POLICY IF EXISTS driver_results_policy ON results;
DROP POLICY IF EXISTS driver_driver_policy ON driver;
DROP POLICY IF EXISTS driver_races_policy ON races;

CREATE POLICY driver_users_policy ON users
    FOR SELECT
    TO driver_role
    USING (login = current_user);

CREATE POLICY driver_qualifying_policy ON qualifying
    FOR SELECT
    TO driver_role
    USING (EXISTS (SELECT 1 FROM users WHERE login = current_user and originalid = driverid limit 1));

CREATE POLICY driver_results_policy ON results
FOR SELECT
    TO driver_role
    USING (EXISTS (SELECT 1 FROM users WHERE login = current_user and originalid = driverid limit 1));


CREATE POLICY driver_driver_policy ON driver
FOR SELECT
    TO driver_role
    USING (EXISTS (SELECT 1 FROM users WHERE login = current_user and originalid = driverid LIMIT 1));


CREATE POLICY driver_races_policy
ON races FOR
SELECT  TO driver_role USING (EXISTS (
SELECT  1
FROM results
WHERE driverid IN ( SELECT originalid FROM users WHERE login = current_user)
AND results.raceid = races.raceid
LIMIT 1));


