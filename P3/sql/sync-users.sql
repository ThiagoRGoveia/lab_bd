create trigger sync_constructor_users_trigger
    after insert or update
    on constructors
    for each row
execute procedure sync_constructor_users();


CREATE OR REPLACE FUNCTION sync_constructor_users()
RETURNS TRIGGER AS $$
BEGIN
IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
    INSERT INTO USERS(Login, Password, Type, OriginalId)
    VALUES (CONCAT(NEW.constructorref, '_c'), md5(NEW.constructorref), 'Constructor', NEW.constructorid);
    PERFORM create_db_user(CONCAT(NEW.constructorref, '_C'), NEW.constructorref, 'Constructor');
END IF;


RETURN NEW;
END;
$$ LANGUAGE plpgsql;


create trigger sync_driver_users_trigger
    after insert or update
    on driver
    for each row
execute procedure sync_driver_users();

CREATE OR REPLACE FUNCTION sync_driver_users() RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
BEGIN
  IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
    INSERT INTO USERS(Login, Password, Type, OriginalId)
    VALUES (CONCAT(NEW.driverref, '_d'), md5(NEW.driverref), 'Driver', NEW.driverid);
    PERFORM create_db_user(CONCAT(NEW.driverref, '_d'), NEW.driverref, 'Driver');
  END IF;
  RETURN NEW;
END;
$$;



CREATE OR REPLACE FUNCTION create_db_user(login varchar(255), password varchar(255), type varchar(255))
    RETURNS void AS $$
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

--         RAISE EXCEPTION 'This is a warning message with param1 = % and param2 = %', login, password;

-- Use EXECUTE to interpolate the username and password
EXECUTE format('CREATE USER %I WITH PASSWORD %L;', login, password);
EXECUTE format('GRANT %I TO %I;', user_role, login);


END;
$$ LANGUAGE plpgsql SECURITY DEFINER;