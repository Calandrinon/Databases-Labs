CREATE OR ALTER FUNCTION GetArtistsOlderThanX (@Year SMALLINT)
RETURNS TABLE
    RETURN (SELECT *
            FROM Artist A
            WHERE A.EstablishmentYear < @Year)
GO

SELECT * FROM GetArtistsOlderThanX (1968)

