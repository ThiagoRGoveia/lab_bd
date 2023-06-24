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