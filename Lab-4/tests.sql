-- noinspection SqlResolveForFile @ routine/"sp_executesql"

SELECT *
FROM sys.tables

CREATE OR ALTER PROCEDURE GenerateRandomString (@Output VARCHAR(50) OUTPUT)
AS
    DECLARE @Length INT = RAND() * 5 + 8;
    DECLARE @CharPool VARCHAR(72) =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNPQRSTUVWXYZ123456789.,-_!$@#%^&*'
    DECLARE @PoolLength INT = Len(@CharPool)
    DECLARE @LoopCount INT = 0
    DECLARE @RandomString VARCHAR(50) = ''

    WHILE (@LoopCount < @Length) BEGIN
        SELECT @RandomString = @RandomString +
            SUBSTRING(@Charpool, CONVERT(int, RAND() * @PoolLength), 1)
        SELECT @LoopCount = @LoopCount + 1
    END

    SELECT @Output = @RandomString
GO

CREATE OR ALTER FUNCTION GenerateRandomDate (@NewId UNIQUEIDENTIFIER)
RETURNS DATETIME
BEGIN
    RETURN DATEADD(DAY, ABS(CHECKSUM(@NewId) % (365 * 10) ), '2011-01-01')
END


DECLARE @Result DATETIME
SET @Result = (SELECT dbo.GenerateRandomDate(NEWID()))
PRINT @Result


DECLARE @Result VARCHAR(50)
EXEC GenerateRandomString @Result OUTPUT
PRINT @Result


CREATE OR ALTER PROCEDURE TestAlbumTableInsertionTime (@INSERTIONS INT)
AS
    DECLARE @startTime DATETIME;
    DECLARE @endTime DATETIME;

    BEGIN TRY DELETE FROM Albums_Genres END TRY BEGIN CATCH END CATCH
    BEGIN TRY DELETE FROM Review END TRY BEGIN CATCH END CATCH
    BEGIN TRY DELETE FROM Concerts_Artists END TRY BEGIN CATCH END CATCH
    BEGIN TRY DELETE FROM Artists_Albums END TRY BEGIN CATCH END CATCH
    BEGIN TRY DELETE FROM Album END TRY BEGIN CATCH END CATCH

    DECLARE @i INT = 0;
    DECLARE @randomName VARCHAR(50);
    DECLARE @randomDate VARCHAR(50);
    DECLARE @randomLink VARCHAR(50);

    SET @startTime= GETDATE();
    WHILE @i < @INSERTIONS
        BEGIN
            EXEC GenerateRandomString @randomName OUTPUT
            EXEC GenerateRandomString @randomLink OUTPUT
            SET @randomDate = (SELECT dbo.GenerateRandomDate(NEWID()))
            PRINT 'Record: ' + @randomName + ' ' + @randomDate + ' ' + @randomLink
            INSERT INTO Album (Name, ReleaseDate, AlbumArtLink) VALUES (@randomName, @randomDate, @randomLink)
            SET @i = @i + 1;
        END

    SET @endTime= GETDATE();
    SELECT DATEDIFF(millisecond,@startTime,@endTime) AS elapsed_ms;
GO


CREATE OR ALTER PROCEDURE TablesInsertion
AS
    BEGIN TRY DELETE FROM Tables END TRY BEGIN CATCH END CATCH
    INSERT INTO Tables (Name) VALUES ('Album')
    INSERT INTO Tables (Name) VALUES ('Song')
GO

CREATE OR ALTER PROCEDURE TestTableInsertionTime (@TableId INT, @INSERTIONS INT)
AS
    DECLARE @TableName VARCHAR(50) = (SELECT T.Name FROM Tables T WHERE T.TableID = @TableId)
    PRINT @TableName
    IF (@TableName IS NULL)
    BEGIN
        THROW 123456, 'The table could not be found in [Tables]', 255
    END

    DECLARE @startTime DATETIME;
    DECLARE @endTime DATETIME;

    DECLARE @i INT = 0;
    DECLARE @NumberOfColumns INT = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE @TableName);
    DECLARE @Action NVARCHAR(50);
    WHILE @i < @NumberOfColumns
    BEGIN
        SET @i = @i + 1;
        SET @Action = 'DECLARE @Random' +
        cast((SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE @TableName AND ORDINAL_POSITION = @i) as NVARCHAR(50)) +
        ' ' +
        cast((SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE @TableName AND ORDINAL_POSITION = @i) as NVARCHAR(50))
        PRINT 'EXEC ' + @Action
        EXEC sp_executesql @Action
    END

    /**
    SET @i = 0;
    SET @startTime= GETDATE();
    DECLARE @j INT = 0;

    WHILE @i < @INSERTIONS
        BEGIN

            EXEC GenerateRandomString @randomName OUTPUT
            EXEC GenerateRandomString @randomLink OUTPUT
            SET @randomDate = (SELECT dbo.GenerateRandomDate(NEWID()))
            PRINT 'Record: ' + @randomName + ' ' + @randomDate + ' ' + @randomLink
            INSERT INTO Album (Name, ReleaseDate, AlbumArtLink) VALUES (@randomName, @randomDate, @randomLink)
            SET @i = @i + 1;
        END

    SET @endTime= GETDATE();
    SELECT DATEDIFF(millisecond,@startTime,@endTime) AS elapsed_ms;
    **/
GO

EXEC TablesInsertion
SELECT * FROM Tables

EXEC TestTableInsertionTime @TableId = 8, @INSERTIONS = 1000

