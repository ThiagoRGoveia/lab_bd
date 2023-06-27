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