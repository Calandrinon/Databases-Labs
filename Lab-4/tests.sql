-- noinspection SqlResolveForFile @ routine/"sp_executesql"

/**
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

/**
CREATE OR ALTER TRIGGER AddTableTest
ON Tables
AFTER INSERT
AS
    INSERT INTO Tests (Name)
    VALUES ('Test'+(SELECT NAME FROM inserted)+'-100'),
           ('Test'+(SELECT NAME FROM inserted)+'-500'),
           ('Test'+(SELECT NAME FROM inserted)+'-1000'),
           ('Test'+(SELECT NAME FROM inserted)+'-5000'),
           ('Test'+(SELECT NAME FROM inserted)+'-10000')

CREATE OR ALTER TRIGGER AddTestInTestTables
ON Tests
AFTER INSERT
AS
    --SELECT TableID FROM Tables WHERE Name = (SELECT VALUE FROM STRING_SPLIT((SELECT Name FROM INSERTED), '-') ORDER BY VALUE ASC OFFSET 1 ROWS)
    INSERT INTO TestTables (TestID, TableID, NoOfRows, Position)
    VALUES ((SELECT MAX(TestID) FROM Tests),
            cast((SELECT TableID FROM Tables WHERE Name = (SELECT VALUE FROM STRING_SPLIT((SELECT Name FROM INSERTED), '-') ORDER BY VALUE ASC OFFSET 1 ROWS)) as INT),
            cast((SELECT TOP 1 VALUE FROM STRING_SPLIT((SELECT Name FROM INSERTED), '-') ORDER BY VALUE ASC) as INT),
            0)
**/
CREATE OR ALTER PROCEDURE TablesInsertion
AS
    BEGIN TRY DELETE FROM Tables END TRY BEGIN CATCH END CATCH
    DBCC CHECKIDENT (Tables, RESEED, 0)
    INSERT INTO Tables (Name) VALUES ('Artist')
    INSERT INTO Tables (Name) VALUES ('Album')
    INSERT INTO Tables (Name) VALUES ('Song');
    INSERT INTO Tables (Name) VALUES ('Albums_Songs')

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

    DECLARE @HasIdentityColumn INT = 0;
    EXEC HasIdentity @tablename = @TableName, @NumberOfIdentities=@HasIdentityColumn OUTPUT

    DECLARE @i INT;
    IF @HasIdentityColumn = 0
        BEGIN SET @i = 0 END
    ELSE
        BEGIN SET @i = 1 END
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
    BEGIN TRY
        EXEC sp_executesql @Action
    END TRY
    BEGIN CATCH
        PRINT 'The table does not have an identity column, so the reseed has not been executed.'
    END CATCH

    WHILE @i < @NumberOfColumns
    BEGIN
        IF @i != @HasIdentityColumn
        BEGIN
            SET @Columns = @Columns + ',';
        END

        SET @i = @i + 1;
        SET @ColumnName = cast((SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE @TableName AND ORDINAL_POSITION = @i) as NVARCHAR(50))
        SET @Datatype = cast((SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE @TableName AND ORDINAL_POSITION = @i) as NVARCHAR(50))
        INSERT INTO Datatypes (Id, Datatype) VALUES (@i, @Datatype)
        SET @Columns = @Columns + @ColumnName
    END
    SET @Columns = @Columns + ')'

    SET @i = 0;
    SET @startTime= GETDATE();
    SET @j = 0;
    SET @RowValues = '';

    WHILE @i < @INSERTIONS
    BEGIN
        --SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE 'Review'
        --SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE 'Song'
        SET @RowValues = '('
        IF @HasIdentityColumn = 0
        BEGIN SET @j = 0 END
        ELSE
        BEGIN SET @j = 1 END

        WHILE @j < @NumberOfColumns
        BEGIN
            IF @j != @HasIdentityColumn
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

            SET @RowValues = @RowValues + cast(@RandomValue as NVARCHAR(50))
        END
        SET @RowValues = @RowValues + ')'
        SET @Action = 'INSERT INTO ' + @TableName + @Columns + ' VALUES ' + @RowValues

        SET @startTime = GETDATE();
        EXEC sp_executesql @Action
        SET @endTime = GETDATE();
        SET @ElapsedMilliseconds = @ElapsedMilliseconds + (SELECT DATEDIFF(millisecond,@startTime,@endTime))
        SET @i = @i + 1;
    END

    PRINT 'Elapsed milliseconds: ' + cast(@ElapsedMilliseconds as VARCHAR(50))
    PRINT 'Elapsed seconds: ' + cast((cast(@ElapsedMilliseconds as REAL) / 1000) as VARCHAR(50))
GO

EXEC TablesInsertion

SELECT * FROM Tables
SELECT * FROM TestTables
SELECT * FROM Tests

SELECT * FROM Datatypes

SELECT * FROM Artist
SELECT * FROM Album
SELECT * FROM Song
SELECT * FROM Albums_Songs
DELETE FROM Artist
DELETE FROM Album
DELETE FROM Song
DELETE FROM Albums_Songs

EXEC TestTableInsertionTime @TableId = 1, @INSERTIONS = 1000
EXEC TestTableInsertionTime @TableId = 2, @INSERTIONS = 1000
EXEC TestTableInsertionTime @TableId = 3, @INSERTIONS = 1000
EXEC TestTableInsertionTime @TableId = 4, @INSERTIONS = 1000


CREATE OR ALTER PROCEDURE HasIdentity
@TableName nvarchar(128), @NumberOfIdentities INT OUTPUT
AS
BEGIN
    SELECT @NumberOfIdentities = COUNT(*)
    FROM     sys.identity_columns
    WHERE OBJECT_NAME(OBJECT_ID) = @TableName
END


CREATE OR ALTER PROCEDURE TestTablesPreparation
AS
    INSERT INTO Tests (Name) VALUES ('TableTest1000')
    DECLARE @TestID INT = (SELECT MAX(TestID) FROM Tests)
    INSERT INTO TestTables (TestID, TableID, NoOfRows, Position) VALUES (@TestID, 1, 1000, 3)
    INSERT INTO TestTables (TestID, TableID, NoOfRows, Position) VALUES (@TestID, 2, 1000, 2)
    INSERT INTO TestTables (TestID, TableID, NoOfRows, Position) VALUES (@TestID, 3, 1000, 1)
    INSERT INTO TestTables (TestID, TableID, NoOfRows, Position) VALUES (@TestID, 4, 1000, 0)
    EXEC TablesInsertion
GO
EXEC TestTablesPreparation

SELECT * FROM Tests
SELECT * FROM TestTables

CREATE OR ALTER PROCEDURE StartTests
AS
    CREATE TABLE CurrentTestsSortedByPosition
    (ID INT IDENTITY (1,1) PRIMARY KEY,
     TableID INT,
     Position INT,
     NoOfRows INT)
    DECLARE @NumberOfTests INT = (SELECT COUNT(*) FROM Tests)
    DECLARE @i INT = 0;
    DECLARE @j INT = 0;
    DECLARE @TestID INT = 0;
    DECLARE @TableID INT = 0;
    DECLARE @NumberOfTables INT = 0;
    DECLARE @TestName NVARCHAR(50);
    DECLARE @TableName NVARCHAR(50);
    DECLARE @Action NVARCHAR(200);
    DECLARE @NumberOfInsertions INT;

    WHILE @i < @NumberOfTests
    BEGIN
        SET @i = @i + 1;
        SET @TestID = (SELECT TestID FROM (SELECT ROW_NUMBER() OVER (ORDER BY TestID) AS 'ROW', * FROM Tests) AS T WHERE ROW=@i)
        SET @TestName = (SELECT Name FROM Tests WHERE TestID = @TestID)
        PRINT 'Running ' + @TestName + '; ID: ' + cast(@TestID as NVARCHAR(50))

        SET @j = 0;
        SET @NumberOfTables = (SELECT COUNT(*) FROM TestTables WHERE TestID = @TestID)
        SELECT * INTO #CurrentTests FROM TestTables WHERE TestID = @TestID
        INSERT INTO CurrentTestsSortedByPosition (TableID, Position, NoOfRows) SELECT TableID, Position, NoOfRows FROM TestTables WHERE TestID = @TestID ORDER BY Position ASC

        WHILE @j < @NumberOfTables
        BEGIN
            SET @j = @j + 1
            SET @TableID = (SELECT TableID FROM (SELECT ROW_NUMBER() OVER (ORDER BY Position) AS 'ROW', * FROM CurrentTestsSortedByPosition) AS T WHERE ROW=@j)
            SET @TableName = (SELECT Name FROM Tables WHERE TableID = @TableID)
            SET @Action = 'DELETE FROM ' + @TableName
            EXEC sp_executesql @Action
            PRINT @TableName
        END

        SET @j = 0;
        WHILE @j < @NumberOfTables
        BEGIN
            SET @j = @j + 1
            SET @TableID = (SELECT TableID FROM (SELECT ROW_NUMBER() OVER (ORDER BY TestID) AS 'ROW', * FROM #CurrentTests) AS T WHERE ROW=@j)
            SET @TableName = (SELECT Name FROM Tables WHERE TableID = @TableID)
            SET @NumberOfInsertions = (SELECT NoOfRows FROM TestTables WHERE TestID = @TestID AND TableID = @TableID)
            SET @Action = 'EXEC TestTableInsertionTime @TableId = ' + cast(@TableID as NVARCHAR(50)) + ', @INSERTIONS = ' + cast(@NumberOfInsertions as NVARCHAR(50))
            PRINT @Action
            EXEC sp_executesql @Action
            PRINT @TableName
        END

        DROP TABLE #CurrentTests
        DELETE FROM CurrentTestsSortedByPosition
    END

    DROP TABLE CurrentTestsSortedByPosition
GO

SELECT * FROM Albums_Songs
SELECT * FROM Song
SELECT * FROM Album
SELECT * FROM Artist
EXEC StartTests

