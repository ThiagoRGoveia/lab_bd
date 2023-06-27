CREATE OR REPLACE FUNCTION createConstructor(_ConstructorRef VARCHAR, _Name VARCHAR, _Nationality VARCHAR, _URL VARCHAR)
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


CREATE OR REPLACE FUNCTION createDriver(_DriverRef VARCHAR, _Number INT, _Code VARCHAR, _Forename VARCHAR, _Surname VARCHAR, _DateOfBirth DATE, _Nationality VARCHAR)
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


CREATE OR REPLACE FUNCTION searchDriverByName(_Forename TEXT, _ConstructorRef VARCHAR)
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
