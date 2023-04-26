const fs = require("fs");

function parseCsvToSQL(csv, insertFunc) {
  csv.replace('"', "");
  const lines = csv.split("\n");
  const headers = lines[0].split(",");
  const insertStatements = [];

  for (let i = 1; i < lines.length; i++) {
    const values = lines[i].split(",");
    const mappedValues = {};

    for (let j = 0; j < headers.length; j++) {
      if (values[j] === "\\N") mappedValues[headers[j]] = null;
      if (values[j] === '""') mappedValues[headers[j]] = null;
      if (!values[j]) mappedValues[headers[j]] = null;
      else mappedValues[headers[j]] = values[j];
    }

    if (Object.keys(mappedValues).length === 0) return;
    const insertStatement = insertFunc(mappedValues);
    insertStatements.push(insertStatement);
  }

  return insertStatements;
}
const circuits = parseCsvToSQL(
  fs.readFileSync(
    "Formula1-2023-20230422T173824Z-001/Formula1-2023/circuits.csv",
    "utf8"
  ),
  (mappedValues) => {
    return `INSERT INTO Circuits (CircuitID, CircuitRef, Name, Location, Country, Lat, Lng, Alt, URL) VALUES (${mappedValues.circuitId}, '${mappedValues.circuitRef}', '${mappedValues.name}', '${mappedValues.location}', '${mappedValues.country}', ${mappedValues.lat}, ${mappedValues.lng}, ${mappedValues.alt}, '${mappedValues.url}');`;
  }
);

const constructors = parseCsvToSQL(
  fs.readFileSync(
    "Formula1-2023-20230422T173824Z-001/Formula1-2023/constructors.csv",
    "utf8"
  ),
  (mappedValues) => {
    return `INSERT INTO Constructors (ConstructorID, ConstructorRef, Name, Nationality, URL) VALUES (${mappedValues.constructorId}, '${mappedValues.constructorRef}', '${mappedValues.name}', '${mappedValues.nationality}', '${mappedValues.url}');`;
  }
);

const driverStandings = parseCsvToSQL(
  fs.readFileSync(
    "Formula1-2023-20230422T173824Z-001/Formula1-2023/driver_standings.csv",
    "utf8"
  ),
  (mappedValues) => {
    return `INSERT INTO DriverStandings (DriverStandingsID, RaceID, DriverID, Points, Position, PositionText, Wins) VALUES (${mappedValues.driverStandingsId}, ${mappedValues.raceId}, ${mappedValues.driverId}, ${mappedValues.points}, ${mappedValues.position}, '${mappedValues.positionText}', ${mappedValues.wins});`;
  }
);

const drivers = parseCsvToSQL(
  fs.readFileSync(
    "Formula1-2023-20230422T173824Z-001/Formula1-2023/drivers.csv",
    "utf8"
  ),
  (mappedValues) => {
    return `INSERT INTO Driver (DriverID, DriverRef, Number, Code, Forename, Surname, DateOfBirth, Nationality, URL) VALUES (${mappedValues.driverId}, '${mappedValues.driverRef}', ${mappedValues.number}, '${mappedValues.code}', '${mappedValues.forename}', '${mappedValues.surname}', '${mappedValues.dob}', '${mappedValues.nationality}', '${mappedValues.url}');`;
  }
);

const pitStops = parseCsvToSQL(
  fs.readFileSync(
    "Formula1-2023-20230422T173824Z-001/Formula1-2023/pit_stops.csv",
    "utf8"
  ),
  (mappedValues) => {
    return `INSERT INTO PitStops (RaceID, DriverID, Stop, Lap, Time, Duration, Milliseconds) VALUES (${mappedValues.raceId}, ${mappedValues.driverId}, ${mappedValues.stop}, ${mappedValues.lap}, '${mappedValues.time}', '${mappedValues.duration}', ${mappedValues.milliseconds});`;
  }
);

const qualifying = parseCsvToSQL(
  fs.readFileSync(
    "Formula1-2023-20230422T173824Z-001/Formula1-2023/qualifying.csv",
    "utf8"
  ),
  (mappedValues) => {
    return `INSERT INTO Qualifying (QualifyID, RaceID, DriverID, ConstructorID, Number, Position, Q1, Q2, Q3) VALUES (${mappedValues.qualifyId}, ${mappedValues.raceId}, ${mappedValues.driverId}, ${mappedValues.constructorId}, ${mappedValues.number}, ${mappedValues.position}, '${mappedValues.q1}', '${mappedValues.q2}', '${mappedValues.q3}');`;
  }
);

const races = parseCsvToSQL(
  fs.readFileSync(
    "Formula1-2023-20230422T173824Z-001/Formula1-2023/races.csv",
    "utf8"
  ),
  (mappedValues) => {
    return `INSERT INTO Races (RaceID, Year, Round, CircuitID, Name, Date, Time, URL) VALUES (${mappedValues.raceId}, ${mappedValues.year}, ${mappedValues.round}, ${mappedValues.circuitId}, '${mappedValues.name}', '${mappedValues.date}', '${mappedValues.time}', '${mappedValues.url}');`;
  }
);

const results = parseCsvToSQL(
  fs.readFileSync(
    "Formula1-2023-20230422T173824Z-001/Formula1-2023/results.csv",
    "utf8"
  ),
  (mappedValues) => {
    return `INSERT INTO Results (ResultID, RaceID, DriverID, ConstructorID, Number, Grid, Position, PositionText, PositionOrder, Points, Laps, Time, Milliseconds, FastestLap, Rank, FastestLapTime, FastestLapSpeed, StatusID) VALUES (${mappedValues.resultId}, ${mappedValues.raceId}, ${mappedValues.driverId}, ${mappedValues.constructorId}, ${mappedValues.number}, ${mappedValues.grid}, ${mappedValues.position}, '${mappedValues.positionText}', ${mappedValues.positionOrder}, ${mappedValues.points}, ${mappedValues.laps}, '${mappedValues.time}', ${mappedValues.milliseconds}, ${mappedValues.fastestLap}, ${mappedValues.rank}, '${mappedValues.fastestLapTime}', ${mappedValues.fastestLapSpeed}, ${mappedValues.statusId});`;
  }
);

const seasons = parseCsvToSQL(
  fs.readFileSync(
    "Formula1-2023-20230422T173824Z-001/Formula1-2023/seasons.csv",
    "utf8"
  ),
  (mappedValues) => {
    return `INSERT INTO Seasons (Year, URL) VALUES (${mappedValues.year}, '${mappedValues.url}');`;
  }
);

const status = parseCsvToSQL(
  fs.readFileSync(
    "Formula1-2023-20230422T173824Z-001/Formula1-2023/status.csv",
    "utf8"
  ),
  (mappedValues) => {
    return `INSERT INTO Status (StatusID, Status) VALUES (${mappedValues.statusId}, '${mappedValues.status}');`;
  }
);

const airports = parseCsvToSQL(
  fs.readFileSync(
    "Formula1-2023-20230422T173824Z-001/Formula1-2023/airports.csv",
    "utf8"
  ),
  (mappedValues) => {
    return `INSERT INTO Airports (Id, Ident, Type, Name, LatDeg, LongDeg, ElevFt, Continent, ISOCountry, ISORegion, City, Scheduled_service, GPSCode, IATACode, LocalCode, HomeLink, WikipediaLink, Keywords) VALUES (${mappedValues.id}, '${mappedValues.ident}', '${mappedValues.type}', '${mappedValues.name}', ${mappedValues.latitude_deg}, ${mappedValues.longitude_deg}, ${mappedValues.elevation_ft}, '${mappedValues.continent}', '${mappedValues.iso_country}', '${mappedValues.iso_region}', '${mappedValues.municipality}', '${mappedValues.scheduled_service}', '${mappedValues.gps_code}', '${mappedValues.iata_code}', '${mappedValues.local_code}', '${mappedValues.home_link}', '${mappedValues.wikipedia_link}', '${mappedValues.keywords}');`;
  }
);

const countries = parseCsvToSQL(
  fs.readFileSync(
    "Formula1-2023-20230422T173824Z-001/Formula1-2023/countries.csv",
    "utf8"
  ),
  (mappedValues) => {
    return `INSERT INTO Countries (Id, Code, Name, Continent, WikipediaLink, Keywords) VALUES (${mappedValues.id}, '${mappedValues.code}', '${mappedValues.name}', '${mappedValues.continent}', '${mappedValues.wikipedia_link}', '${mappedValues.keywords}');`;
  }
);

const geocities15K = parseCsvToSQL(
  fs.readFileSync(
    "Formula1-2023-20230422T173824Z-001/Formula1-2023/Cities15000.csv",
    "utf8"
  ),
  (mappedValues) => {
    return `INSERT INTO Geocities15K (GeonameID, Name, AsciiName, AlternateNames, Lat, Long, FeatureClass, FeatureCode, Country, CC2, Admin1Code, Admin2Code, Admin3Code, Admin4Code, Population, Elevation, Dem, TimeZone, Modification) VALUES (${mappedValues.GeonameID}, '${mappedValues.Name}', '${mappedValues.AsciiName}', '${mappedValues.AlternateNames}', ${mappedValues.Lat}, ${mappedValues.Long}, '${mappedValues.FeatureClass}', '${mappedValues.FeatureCode}', '${mappedValues.Country}', '${mappedValues.CC2}', '${mappedValues.Admin1Code}', '${mappedValues.Admin2Code}', '${mappedValues.Admin3Code}', '${mappedValues.Admin4Code}', ${mappedValues.Population}, ${mappedValues.Elevation}, ${mappedValues.Dem}, '${mappedValues.TimeZone}', '${mappedValues.Modification}');`;
  }
);

// Write circuits to circuits.sql
// fs.writeFileSync("circuits.sql", circuits.join("\n"));

// // Write constructors to constructors.sql
// fs.writeFileSync("constructors.sql", constructors.join("\n"));

// // Write driver standings to driver_standings.sql
// fs.writeFileSync("driver_standings.sql", driverStandings.join("\n"));

// // Write pit stops to pit_stops.sql
// fs.writeFileSync("pit_stops.sql", pitStops.join("\n"));

// // Write qualifying to qualifying.sql
// fs.writeFileSync("qualifying.sql", qualifying.join("\n"));

// // Write races to races.sql
// fs.writeFileSync("races.sql", races.join("\n"));

// // Write results to results.sql
// fs.writeFileSync("results.sql", results.join("\n"));

// // Write seasons to seasons.sql
// fs.writeFileSync("seasons.sql", seasons.join("\n"));

// // Write status to status.sql
// fs.writeFileSync("status.sql", status.join("\n"));

// // Write airports to airports.sql
// fs.writeFileSync("airports.sql", airports.join("\n"));

// // Write countries to countries.sql
// fs.writeFileSync("countries.sql", countries.join("\n"));

// // Write geocities15K to geocities15K.sql
fs.writeFileSync("geocities15K.sql", geocities15K.join("\n"));
// fs.writeFileSync("drivers.sql", drivers.join("\n"));
