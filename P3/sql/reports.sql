-- Relatorio 1

CREATE OR REPLACE FUNCTION get_status_COUNT() RETURNS TABLE ( status_name varchar, count bigint ) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY
    SELECT  s.status
        ,COUNT(r.statusid)
    FROM results r
    JOIN status s
    ON s.statusid = r.statusid
    GROUP BY  s.status
ORDER BY COUNT(r.statusid) DESC; 
END; 
$$;


-- Relatorio 2


CREATE INDEX idx_airports_type ON airports(type);
CREATE INDEX idx_cities_name ON geocities15k(name);
CREATE INDEX idx_airports_country ON airports(isocountry);


CREATE OR REPLACE FUNCTION get_airports_near_city(CITYNAME varchar)
RETURNS TABLE (
city_name varchar,
iatacode varchar,
airport_name varchar,
airport_city varchar,
distance double precision,
airport_type varchar
)
LANGUAGE plpgsql
AS $$
BEGIN

RETURN QUERY
    SELECT  c.name
        ,a.iatacode
        ,a.name
        ,a.city
        ,earth_distance(ll_to_earth(c.lat,c.long),ll_to_earth(a.latdeg,a.longdeg))
        ,a.type
    FROM airports a
    JOIN geocities15k c
    ON a.isocountry = c.country
    WHERE c.name = CITYNAME
    AND earth_distance(ll_to_earth(c.lat, c.long), ll_to_earth(a.latdeg, a.longdeg)) <= 100000
    AND a.type IN ('medium_airport', 'large_airport')
    AND c.country = 'BR'
    ORDER BY earth_distance(ll_to_earth(c.lat, c.long), ll_to_earth(a.latdeg, a.longdeg)); 
END; 
$$;

-- Relatorio 3

CREATE OR REPLACE FUNCTION get_driver_wins(CONSTRUCTOR_ID int) RETURNS TABLE ( driver_name text, wins bigint ) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY
    SELECT  d.forename || ' ' || d.surname AS full_name
        ,COUNT(r.raceid)
    FROM results r
    JOIN driver d
    ON d.driverid = r.driverid
    WHERE r.position = 1
    AND r.constructorid = CONSTRUCTOR_ID
    GROUP BY  d.forename
            ,d.surname
    ORDER BY COUNT(r.raceid) DESC; 
END; 
$$;

-- Relatorio 4


CREATE OR REPLACE FUNCTION get_constructor_status_COUNT(CONSTRUCTOR_ID int) RETURNS TABLE ( status varchar, count bigint ) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY
    SELECT  s.status
        ,COUNT(r.resultid)
    FROM results r
    JOIN status s
    ON s.statusid = r.statusid
    WHERE r.constructorid = CONSTRUCTOR_ID
    GROUP BY  s.status
    ORDER BY COUNT(r.resultid) DESC; 
    END; 
$$;


-- Relatorio 5


CREATE OR REPLACE FUNCTION get_driver_victories(DRIVER_ID int) RETURNS TABLE ( year int, race_name varchar, victories_count bigint ) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY
    SELECT  ra.year ,ra.name ,COUNT(*)
    FROM results res
    JOIN races ra
    ON res.raceid = ra.raceid
    JOIN driver d
    ON res.driverid = d.driverid
    JOIN status s
    ON res.statusid = s.statusid
    WHERE d.driverid = DRIVER_ID
    AND s.status = 'Finished'
    AND res.number = 1
    GROUP BY  ROLLUP(ra.year,ra.name)
    ORDER BY ra.year ,COUNT(*) DESC; 
END; 
$$;


-- Relatorio 6


CREATE OR REPLACE FUNCTION get_driver_status(DRIVER_ID int) RETURNS TABLE ( status varchar, status_count bigint ) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY
    SELECT  s.status
        ,COUNT(*)
    FROM results res
    JOIN status s
    ON res.statusid = s.statusid
    WHERE res.driverid = DRIVER_ID
    GROUP BY  s.status
ORDER BY COUNT(*) DESC; 
END; 
$$;
