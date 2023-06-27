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