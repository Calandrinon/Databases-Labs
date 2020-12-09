DROP TABLE Stations_Routes
DROP TABLE Stations
DROP TABLE Routes
DROP TABLE Trains
DROP TABLE TrainTypes

GO
CREATE TABLE TrainTypes
    (TrainTypeId INT PRIMARY KEY,
    TTName VARCHAR(60),
    TTDescription VARCHAR(400) )

CREATE TABLE Trains
    (TrainId INT PRIMARY KEY,
    TName VARCHAR(60),
    TrainTypeId INT REFERENCES  TrainTypes(TrainTypeId))


CREATE TABLE Routes
(RouteId INT PRIMARY KEY,
 RName VARCHAR(60) UNIQUE,
 TrainId INT REFERENCES  Trains(TrainId))
CREATE TABLE Stations
(StationId INT PRIMARY KEY,
 SName VARCHAR(60) UNIQUE,
 )

CREATE TABLE Stations_Routes
(StationId INT REFERENCES Stations(StationId),
 RouteId INT REFERENCES Routes(RouteId),
 Arrival TIME,
 Departure TIME,
 PRIMARY KEY (StationId, RouteId)
)

GO


CREATE OR ALTER PROCEDURE uspUpdateRoute (@SName VARCHAR(60), @RName VARCHAR(60), @Arrival TIME, @Departure TIME)
AS
    DECLARE @RID INT, @SID INT
    IF NOT EXISTS(SELECT * FROM Routes WHERE RName = @RName)
    BEGIN
        RAISERROR ('Route name not valid. Try again.', 16, 1)
        RETURN
    END

    IF NOT EXISTS(SELECT * FROM Stations WHERE SName = @SName)
    BEGIN
        RAISERROR ('Station name not valid. Try again.', 16, 1)
        RETURN
    END

    SELECT @RID = (SELECT RouteId FROM Routes WHERE RName = @RName),
           @SID = (SELECT StationId FROM Stations WHERE SName = @SName)

    IF EXISTS(SELECT * FROM Stations_Routes WHERE StationId = @SID AND RouteId = @RID)
    BEGIN
        UPDATE Stations_Routes
        SET Arrival = @Arrival, Departure = @Departure
        WHERE StationId = @SID AND RouteId = @RID
    END
    ELSE
    BEGIN
        INSERT Stations_Routes (StationId, RouteId, Arrival, Departure)
        VALUES (@SID, @RID, @Arrival, @Departure)
    END


INSERT TrainTypes VALUES (1, 'type1', 'description1')
INSERT Trains VALUES (1, 't1', 1), (2, 't2', 1), (3, 't3', 1)
INSERT Routes VALUES (1, 'r1', 1), (2, 'r2', 2), (3, 'r3', 3)
INSERT Stations VALUES (1, 's1'), (2, 's2'), (3, 's3')

SELECT * FROM TrainTypes
SELECT * FROM Trains
SELECT * FROM Routes
SELECT * FROM Stations
SELECT * FROM Stations_Routes
ORDER BY RouteId

EXEC uspUpdateRoute @RName = 'r1', @SName = 's1', @Arrival = '4:20', @Departure = '4:30'
EXEC uspUpdateRoute @RName = 'r1', @SName = 's2', @Arrival = '5:20', @Departure = '5:30'
EXEC uspUpdateRoute @RName = 'r1', @SName = 's3', @Arrival = '6:20', @Departure = '6:30'


EXEC uspUpdateRoute @RName = 'r2', @SName = 's1', @Arrival = '4:20', @Departure = '4:30'
EXEC uspUpdateRoute @RName = 'r2', @SName = 's2', @Arrival = '5:20', @Departure = '5:30'
EXEC uspUpdateRoute @RName = 'r2', @SName = 's3', @Arrival = '6:20', @Departure = '6:30'

EXEC uspUpdateRoute @RName = 'r3', @SName = 's1', @Arrival = '6:20', @Departure = '6:30'


SELECT StationId
FROM Stations
EXCEPT
SELECT StationId
FROM Stations_Routes
WHERE RouteId = 1

SELECT StationId
FROM Stations
EXCEPT
SELECT StationId
FROM Stations_Routes
WHERE RouteId = 3


CREATE OR ALTER VIEW vRoutesWithAllTheStations
AS
    SELECT *
    FROM Routes R
    WHERE NOT EXISTS
        (
            SELECT StationId
            FROM Stations
                EXCEPT
            SELECT StationId
            FROM Stations_Routes
            WHERE RouteId = r.RouteId
        )
GO

SELECT * FROM vRoutesWithAllTheStations



CREATE OR ALTER FUNCTION ufFilterStationsByNumberOfRoutes (@R INT)
RETURNS TABLE
    RETURN  SELECT S.SName
            FROM Stations S
            WHERE S.StationId IN
                (SELECT SR.StationId
                FROM Stations_Routes SR
                GROUP BY SR.StationId
                HAVING COUNT(*) > @R)

SELECT * FROM ufFilterStationsByNumberOfRoutes(2)
