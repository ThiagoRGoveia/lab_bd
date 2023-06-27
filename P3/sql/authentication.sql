-- Setup tables for row level security
ALTER TABLE qualifying ENABLE ROW LEVEL SECURITY;
ALTER TABLE results ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE constructors ENABLE ROW LEVEL SECURITY;
ALTER TABLE driver ENABLE ROW LEVEL SECURITY;


-- USER INSERTS
INSERT INTO users (login, password, type, originalid) VALUES ('admin', 'admin', 'Admin', null);
CREATE USER admin WITH PASSWORD 'admin';
GRANT admin_role TO admin;

-- INSERT DRIVES INTO USERS TABLE
CREATE OR REPLACE FUNCTION sync_driver_users_from_driver()
RETURNS void AS
$$
DECLARE
   rec RECORD;
BEGIN
   FOR rec IN
       SELECT LOWER(CONCAT(driverref, '_d')) AS login,
              md5(LOWER(driverref)) AS password,
              'Driver' AS type,
              driverid AS originalid
       FROM driver
   LOOP
       INSERT INTO users (login, password, type, originalid)
       VALUES (rec.login, rec.password, rec.type, rec.originalid);

       -- Call create_db_user function with login and password parameters
       PERFORM create_db_user(rec.login, rec.password, rec.type);
   END LOOP;
   RETURN;
END;
$$ LANGUAGE plpgsql;

SELECT  sync_driver_users_from_driver();




-- INSERT CONSTRUCTORS INTO USERS TABLE
CREATE OR REPLACE FUNCTION sync_constructor_users_from_constructor()
RETURNS void AS
$$
DECLARE
   rec RECORD;
BEGIN
    FOR rec IN
         SELECT LOWER(CONCAT(constructorref, '_c')) AS login,
                  md5(LOWER(constructorref)) AS password,
                  'Constructor' AS type,
                  constructorid AS originalid
         FROM constructors
    LOOP
         INSERT INTO users (login, password, type, originalid)
         VALUES (rec.login, rec.password, rec.type, rec.originalid);
    
         -- Call create_db_user function with login and password parameters
         PERFORM create_db_user(rec.login, rec.password, rec.type);
    END LOOP;
    RETURN;
    END;
$$ LANGUAGE plpgsql;

SELECT sync_constructor_users_from_constructor();


-- ADMIN ROLE
CREATE ROLE admin_role;

-- Grant privileges to the role
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin_role;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin_role;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO admin_role;

-- Grant usage privilege on the schema
GRANT USAGE, CREATE ON SCHEMA public TO admin_role;

-- Grant access to future tables, sequences, and functions
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT ALL PRIVILEGES ON TABLES TO admin_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT ALL PRIVILEGES ON SEQUENCES TO admin_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT ALL PRIVILEGES ON FUNCTIONS TO admin_role;


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
GRANT SELECT ON status TO driver_role;

DROP POLICY IF EXISTS constructor_users_policy ON users;
DROP POLICY IF EXISTS constructor_qualifying_policy ON qualifying;
DROP POLICY IF EXISTS constructor_results_policy ON results;
DROP POLICY IF EXISTS constructor_results_policy ON constructors;
DROP POLICY IF EXISTS constructor_driver_policy ON driver;

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

-- DRVER ROLE
CREATE ROLE driver_role;

-- Grant usage on schema
GRANT USAGE ON SCHEMA public TO driver_role;

GRANT SELECT ON users TO driver_role;
GRANT SELECT ON qualifying TO driver_role;
GRANT SELECT ON results TO driver_role;
GRANT SELECT ON driver TO driver_role;
GRANT SELECT ON races TO driver_role;


DROP POLICY IF EXISTS driver_qualifying_policy ON qualifying;
DROP POLICY IF EXISTS driver_results_policy ON results;
DROP POLICY IF EXISTS driver_driver_policy ON driver;
DROP POLICY IF EXISTS driver_races_policy ON races;

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