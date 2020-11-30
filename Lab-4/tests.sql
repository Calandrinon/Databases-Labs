-- noinspection SqlResolveForFile @ routine/"sp_executesql"

SELECT *
FROM sys.tables

CREATE VIEW GetRandomValue
AS
SELECT RAND() AS Value
GO

CREATE OR ALTER FUNCTION GenerateRandomString ()
RETURNS VARCHAR
AS
BEGIN
    RETURN left(NEWID(),30)
END
GO


CREATE OR ALTER FUNCTION GenerateRandomDate (@NewId UNIQUEIDENTIFIER)
RETURNS DATETIME
BEGIN
    RETURN DATEADD(DAY, ABS(CHECKSUM(@NewId) % (365 * 10) ), '2011-01-01')
END


DECLARE @Result DATETIME
SET @Result = (SELECT dbo.GenerateRandomDate(NEWID()))
PRINT @Result

SELECT left(NEWID(),30)

DECLARE @Result NVARCHAR(50)
SET @Result = (SELECT dbo.GenerateRandomString())
PRINT @Result

/**
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
            SET @randomName = (SELECT GenerateRandomString)
            EXEC GenerateRandomString @randomLink OUTPUT
            SET @randomDate = (SELECT dbo.GenerateRandomDate(NEWID()))
            PRINT 'Record: ' + @randomName + ' ' + @randomDate + ' ' + @randomLink
            INSERT INTO Album (Name, ReleaseDate, AlbumArtLink) VALUES (@randomName, @randomDate, @randomLink)
            SET @i = @i + 1;
        END

    SET @endTime= GETDATE();
    SELECT DATEDIFF(millisecond,@startTime,@endTime) AS elapsed_ms;
GO
**/

CREATE OR ALTER PROCEDURE TablesInsertion
AS
    BEGIN TRY DELETE FROM Tables END TRY BEGIN CATCH END CATCH
    INSERT INTO Tables (Name) VALUES ('Album')
    INSERT INTO Tables (Name) VALUES ('Artist')
    INSERT INTO Tables (Name) VALUES ('Song');

    BEGIN TRY DROP TABLE Datatypes END TRY BEGIN CATCH END CATCH
    BEGIN TRY
    CREATE TABLE Datatypes
        (Id INT PRIMARY KEY,
         Datatype VARCHAR(50))
    END TRY
    BEGIN CATCH END CATCH
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

    DECLARE @i INT = 1;
    DECLARE @NumberOfColumns INT = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE @TableName);
    DECLARE @Action NVARCHAR(200);
    DECLARE @Columns NVARCHAR(500) = '(';
    DECLARE @ColumnName NVARCHAR(50);
    DECLARE @Datatype NVARCHAR(50);
    DECLARE @j INT = 0;
    DECLARE @ColumnDatatype NVARCHAR(50);
    DECLARE @RandomValue NVARCHAR(50);
    DECLARE @RowValues NVARCHAR(500) = '';
    DECLARE @ElapsedMilliseconds BIGINT = 0;
    DELETE FROM Datatypes
    SET @Action = 'DELETE FROM ' + @TableName
    EXEC sp_executesql @Action
    SET @Action = 'DBCC CHECKIDENT (''' + @TableName + ''', RESEED, 0)'
    EXEC sp_executesql @Action


    WHILE @i < @NumberOfColumns
    BEGIN
        IF @i != 1
        BEGIN
            SET @Columns = @Columns + ',';
        END

        SET @i = @i + 1;
        PRINT '@i=' + cast(@i as VARCHAR(50))
        SET @ColumnName = cast((SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE @TableName AND ORDINAL_POSITION = @i) as NVARCHAR(50))
        SET @Datatype = cast((SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE @TableName AND ORDINAL_POSITION = @i) as NVARCHAR(50))
        INSERT INTO Datatypes (Id, Datatype) VALUES (@i, @Datatype)
        SET @Columns = @Columns + @ColumnName
    END
    SET @Columns = @Columns + ')'

    PRINT @Columns

    SET @i = 0;
    SET @startTime= GETDATE();
    SET @j = 1;
    SET @RowValues = '';

    WHILE @i < @INSERTIONS
    BEGIN
        --SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE 'Review'
        --SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE 'Song'
        SET @RowValues = '('
        SET @j = 1;
        WHILE @j < @NumberOfColumns
        BEGIN
            IF @j != 1
                SET @RowValues = @RowValues + ','

            SET @j = @j + 1;
            SET @ColumnDatatype = (SELECT Datatype FROM Datatypes WHERE Id = @j)

            SET @RandomValue = (
                CASE @ColumnDatatype
                    WHEN 'int' THEN cast(@i + 1 as NVARCHAR(50))
                    WHEN 'smallint' THEN cast(@i + 1 as NVARCHAR(50))
                    WHEN 'text' THEN '''' + left(NEWID(), 30) + ''''
                    WHEN 'varchar' THEN '''' + left(NEWID(), 30) + ''''
                    WHEN 'datetime' THEN '''' + cast(DATEADD(DAY, ABS(CHECKSUM(NEWID()) % (365 * 10) ), '2011-01-01') as NVARCHAR(50)) + ''''
                    WHEN 'date' then '''' + cast(DATEADD(DAY, (ABS(CHECKSUM(NEWID())) % 65530), 0) as NVARCHAR(50)) + ''''
                END)

            --SET @ColumnName = cast((SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE @TableName AND ORDINAL_POSITION = @j) as NVARCHAR(50))
            SET @RowValues = @RowValues + cast(@RandomValue as NVARCHAR(50))
        END
        SET @RowValues = @RowValues + ')'
        SET @Action = 'INSERT INTO ' + @TableName + @Columns + ' VALUES ' + @RowValues
        PRINT @Action

        SET @startTime = GETDATE();
        EXEC sp_executesql @Action
        SET @endTime = GETDATE();
        SET @ElapsedMilliseconds = @ElapsedMilliseconds + (SELECT DATEDIFF(millisecond,@startTime,@endTime))
        SET @i = @i + 1;
    END

    SET @endTime= GETDATE();
    PRINT 'Elapsed milliseconds: ' + cast(@ElapsedMilliseconds as VARCHAR(50))
    PRINT 'Elapsed seconds: ' + cast((cast(@ElapsedMilliseconds as REAL) / 1000) as VARCHAR(50))
GO

EXEC TablesInsertion

SELECT * FROM Tables

SELECT * FROM Datatypes
SELECT * FROM Song
SELECT * FROM Artist
DELETE FROM Artist
DELETE FROM Song
EXEC TestTableInsertionTime @TableId = 27, @INSERTIONS = 1000


SELECT
   KCU1.TABLE_NAME AS 'FK_TABLE_NAME'
   , KCU1.COLUMN_NAME AS 'FK_COLUMN_NAME'
   , KCU2.TABLE_NAME AS 'UQ_TABLE_NAME'
FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS RC
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KCU1
ON KCU1.CONSTRAINT_CATALOG = RC.CONSTRAINT_CATALOG
   AND KCU1.CONSTRAINT_SCHEMA = RC.CONSTRAINT_SCHEMA
   AND KCU1.CONSTRAINT_NAME = RC.CONSTRAINT_NAME
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KCU2
ON KCU2.CONSTRAINT_CATALOG =
RC.UNIQUE_CONSTRAINT_CATALOG
   AND KCU2.CONSTRAINT_SCHEMA =
RC.UNIQUE_CONSTRAINT_SCHEMA
   AND KCU2.CONSTRAINT_NAME =
RC.UNIQUE_CONSTRAINT_NAME
   AND KCU2.ORDINAL_POSITION = KCU1.ORDINAL_POSITION
WHERE KCU1.TABLE_NAME = 'Song'


DECLARE @k INT = 0;
WHILE @k < 10000
BEGIN
    PRINT NEWID()
    SET @k = @k + 1
END


