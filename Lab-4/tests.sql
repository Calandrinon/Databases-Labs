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

    WHILE @i < @NumberOfColumns
    BEGIN
        IF @i != 1
        BEGIN
            SET @Columns = @Columns + ',';
        END

        SET @i = @i + 1;
        SET @ColumnName = cast((SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE @TableName AND ORDINAL_POSITION = @i) as NVARCHAR(50))
        SET @Datatype = cast((SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE @TableName AND ORDINAL_POSITION = @i) as NVARCHAR(50))
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
            SET @ColumnDatatype = cast((SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE @TableName AND ORDINAL_POSITION = @j) as NVARCHAR(50))

            SET @RandomValue = (
                CASE @ColumnDatatype
                    WHEN 'int' THEN cast(@i as NVARCHAR(50))
                    WHEN 'text' THEN '''' + left(NEWID(), 30) + ''''
                    WHEN 'varchar' THEN '''' + left(NEWID(), 30) + ''''
                    WHEN 'datetime' THEN '''' + cast(DATEADD(DAY, ABS(CHECKSUM(NEWID()) % (365 * 10) ), '2011-01-01') as NVARCHAR(50)) + ''''
                    WHEN 'date' then '''' + cast(DATEADD(DAY, (ABS(CHECKSUM(NEWID())) % 65530), 0) as NVARCHAR(50)) + ''''
                END)

            SET @ColumnName = cast((SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME LIKE @TableName AND ORDINAL_POSITION = @j) as NVARCHAR(50))
            SET @RowValues = @RowValues + cast(@RandomValue as NVARCHAR(50))
        END
        SET @RowValues = @RowValues + ')'
        SET @Action = 'INSERT INTO ' + @TableName + @Columns + ' VALUES ' + @RowValues
        PRINT @Action
        EXEC sp_executesql @Action
        SET @i = @i + 1;
    END

    SET @endTime= GETDATE();
    SELECT DATEDIFF(millisecond,@startTime,@endTime) AS elapsed_ms;
GO

EXEC TablesInsertion
SELECT * FROM Tables

SELECT * FROM Album
EXEC TestTableInsertionTime @TableId = 11, @INSERTIONS = 100

