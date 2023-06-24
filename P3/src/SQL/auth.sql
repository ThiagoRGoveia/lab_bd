-- Tables and functions for user authentication
--
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
