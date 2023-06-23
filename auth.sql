-- Description: SQL script to create tables and functions for authentication
CREATE TABLE USERS (
  Userid SERIAL PRIMARY KEY,
  Login VARCHAR(255) NOT NULL UNIQUE,
  Password VARCHAR(255) NOT NULL,
  Type VARCHAR(255) CHECK(Type IN ('Admin', 'Team', 'Driver')),
  OriginalId INT
);

CREATE TABLE LOG_TABLE (
  LogId SERIAL PRIMARY KEY,
  Userid INT REFERENCES USERS(Userid),
  Date DATE NOT NULL DEFAULT CURRENT_DATE,
  LoginTime TIME NOT NULL DEFAULT CURRENT_TIME
);

CREATE TABLE AUTH_TOKENS (
    Token VARCHAR(255) PRIMARY KEY,
    Userid INT REFERENCES USERS(Userid),
    Role VARCHAR(255),
    Expiry TIMESTAMP NOT NULL
);

CREATE OR REPLACE FUNCTION authenticate_user(p_login VARCHAR(255), p_password VARCHAR(255))
RETURNS BOOLEAN AS $$
DECLARE
    v_password VARCHAR(255);
BEGIN
    SELECT Password INTO v_password
    FROM USERS
    WHERE Login = p_login;

    IF v_password IS NULL THEN
        RAISE EXCEPTION 'User does not exist';
    ELSIF v_password = md5(p_password) THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;


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



