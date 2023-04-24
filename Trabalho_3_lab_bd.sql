CREATE TABLE Circuits (
    CircuitID INT PRIMARY KEY,
    CircuitRef VARCHAR(255),
    Name VARCHAR(255),
    Location VARCHAR(255),
    Country VARCHAR(255),
    Lat FLOAT,
    Lng FLOAT,
    Alt INT,
    URL VARCHAR(2083)
);

CREATE TABLE Constructors (
    ConstructorID INT PRIMARY KEY,
    ConstructorRef VARCHAR(255),
    Name VARCHAR(255),
    Nationality VARCHAR(255),
    URL VARCHAR(2083)
);

CREATE TABLE DriverStandings (
    DriverStandingsID INT PRIMARY KEY,
    RaceID INT,
    DriverID INT,
    Points INT,
    Position INT,
    PositionText VARCHAR(255),
    Wins INT,
    -- FOREIGN KEY (RaceID) REFERENCES Races(RaceID),
    -- FOREIGN KEY (DriverID) REFERENCES Driver(DriverID)
);

CREATE TABLE Driver (
    DriverID INT PRIMARY KEY,
    DriverRef VARCHAR(255),
    Number INT,
    Code VARCHAR(3),
    Forename VARCHAR(255),
    Surname VARCHAR(255),
    DateOfBirth DATE,
    Nationality VARCHAR(255),
    URL VARCHAR(2083)
);

CREATE TABLE LapTimes (
    RaceID INT,
    DriverID INT,
    Lap INT,
    Position INT,
    Time VARCHAR(255),
    Milliseconds INT,
    PRIMARY KEY (RaceID, DriverID, Lap),
    -- FOREIGN KEY (RaceID) REFERENCES Races(RaceID),
    -- FOREIGN KEY (DriverID) REFERENCES Driver(DriverID)
);

CREATE TABLE PitStops (
    RaceID INT,
    DriverID INT,
    Stop INT,
    Lap INT,
    Time VARCHAR(255),
    Duration VARCHAR(255),
    Milliseconds INT,
    PRIMARY KEY (RaceID, DriverID, Stop),
    -- FOREIGN KEY (RaceID) REFERENCES Races(RaceID),
    -- FOREIGN KEY (DriverID) REFERENCES Driver(DriverID)
);

CREATE TABLE Qualifying (
    QualifyID INT PRIMARY KEY,
    RaceID INT,
    DriverID INT,
    ConstructorID INT,
    Number INT,
    Position INT,
    Q1 VARCHAR(255),
    Q2 VARCHAR(255),
    Q3 VARCHAR(255),
    -- FOREIGN KEY (RaceID) REFERENCES Races(RaceID),
    -- FOREIGN KEY (DriverID) REFERENCES Driver(DriverID),
    -- FOREIGN KEY (ConstructorID) REFERENCES Constructors(ConstructorID)
);

CREATE TABLE Races (
    RaceID INT PRIMARY KEY,
    Year INT,
    Round INT,
    CircuitID INT,
    Name VARCHAR(255),
    Date DATE,
    Time TIME,
    URL VARCHAR(2083),
    -- FOREIGN KEY (CircuitID) REFERENCES Circuits(CircuitID)
);

CREATE TABLE Results (
    ResultID INT PRIMARY KEY,
    RaceID INT,
    DriverID INT,
    ConstructorID INT,
    Number INT,
    Grid INT,
    Position INT,
    PositionText VARCHAR(255),
    PositionOrder INT,
    Points FLOAT,
    Laps INT,
    Time VARCHAR(255),
    Milliseconds INT,
    FastestLap INT,
    Rank INT,
    FastestLapTime VARCHAR(255),
    FastestLapSpeed FLOAT,
    StatusID INT,
    -- FOREIGN KEY (RaceID) REFERENCES Races(RaceID),
    -- FOREIGN KEY (DriverID) REFERENCES Driver(DriverID),
    -- FOREIGN KEY (ConstructorID) REFERENCES Constructors(ConstructorID),
    -- FOREIGN KEY (StatusID) REFERENCES Status(StatusID)
);

CREATE TABLE Seasons (Year INT PRIMARY KEY, URL VARCHAR(2083));

CREATE TABLE Status (StatusID INT PRIMARY KEY, Status VARCHAR(255));

CREATE TABLE Airports (
    Id INT PRIMARY KEY,
    Ident VARCHAR(255),
    Type VARCHAR(255),
    Name VARCHAR(255),
    LatDeg FLOAT,
    LongDeg FLOAT,
    ElevFt INT,
    Continent VARCHAR(2),
    ISOCountry VARCHAR(2),
    ISORegion VARCHAR(5),
    City VARCHAR(255),
    Scheduled_service VARCHAR(3),
    GPSCode VARCHAR(4),
    IATACode VARCHAR(3),
    LocalCode VARCHAR(4),
    HomeLink VARCHAR(2083),
    WikipediaLink VARCHAR(2083),
    Keywords VARCHAR(255)
);

CREATE TABLE Countries (
    Id INT PRIMARY KEY,
    Code VARCHAR(2),
    Name VARCHAR(255),
    Continent VARCHAR(2),
    WikipediaLink VARCHAR(2083),
    Keywords VARCHAR(255)
);

CREATE TABLE Geocities15K (
    GeonameID INT PRIMARY KEY,
    Name VARCHAR(200),
    AsciiName VARCHAR(200),
    AlternateNames VARCHAR(2083),
    Lat FLOAT,
    Long FLOAT,
    FeatureClass CHAR(1),
    FeatureCode VARCHAR(10),
    Country VARCHAR(2),
    CC2 VARCHAR(60),
    Admin1Code VARCHAR(20),
    Admin2Code VARCHAR(80),
    Admin3Code VARCHAR(20),
    Admin4Code VARCHAR(20),
    Population INT,
    Elevation INT,
    Dem INT,
    TimeZone VARCHAR(40),
    Modification DATE
);