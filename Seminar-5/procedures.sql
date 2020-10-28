CREATE OR ALTER PROCEDURE GetArtistsByYear(@Year SMALLINT)
AS
    SELECT * 
    FROM Artist A
    WHERE A.EstablishmentYear = @Year
GO

EXEC GetArtistsByYear @Year=1968

GO
CREATE OR ALTER PROCEDURE GetRecordsByPriceRange @Price REAL, @NumberOfRecords INT OUTPUT AS
    SELECT @NumberOfRecords = COUNT(*) 
    FROM Record R
    WHERE R.Price >= @Price
GO

DECLARE @NrRecords INT = 0
EXEC GetRecordsByPriceRange @Price=9.99, @NumberOfRecords=@NrRecords OUTPUT
PRINT @NrRecords

GO

SELECT @@VERSION, @@SERVERNAME
