
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
              driverid AS originalid,
              driverref as password_login

       FROM driver
   LOOP
       INSERT INTO users (login, password, type, originalid)
       VALUES (rec.login, rec.password, rec.type, rec.originalid);

       -- Call create_db_user function with login and password parameters
       PERFORM create_db_user(rec.login, rec.password_login, rec.type);
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
                  constructorid AS originalid,
                  constructorref as password_login
         FROM constructors
    LOOP
         INSERT INTO users (login, password, type, originalid)
         VALUES (rec.login, rec.password, rec.type, rec.originalid);
    
         -- Call create_db_user function with login and password parameters
         PERFORM create_db_user(rec.login, rec.password_login, rec.type);
    END LOOP;
    RETURN;
    END;
$$ LANGUAGE plpgsql;

SELECT sync_constructor_users_from_constructor();

