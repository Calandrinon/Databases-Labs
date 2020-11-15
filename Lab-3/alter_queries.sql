CREATE OR ALTER PROCEDURE ChangeRecordsInStockType
AS
    ALTER TABLE Record
    ALTER COLUMN InStock SMALLINT
GO
CREATE OR ALTER PROCEDURE ReverseRecordsInStockType
AS
    ALTER TABLE Record
    ALTER COLUMN InStock INT
GO

EXEC ChangeRecordsInStockType
EXEC ReverseRecordsInStockType

GO
CREATE OR ALTER PROCEDURE AddVotesFieldToReviews
AS
    ALTER TABLE Review
    ADD UpvotesDownvotes INT
GO
CREATE OR ALTER PROCEDURE RemoveVotesFieldFromReviews
AS
    ALTER TABLE Review
    DROP COLUMN UpvotesDownvotes
GO
EXEC AddVotesFieldToReviews
EXEC RemoveVotesFieldFromReviews
GO
CREATE OR ALTER PROCEDURE AddDefaultNullValue
AS
    ALTER TABLE Record
    ADD CONSTRAINT NullDefaultValue
    DEFAULT 0 FOR InStock
GO
CREATE OR ALTER PROCEDURE RemoveDefaultNullValue
AS
    ALTER TABLE Record
    DROP CONSTRAINT NullDefaultValue
GO

EXEC AddDefaultNullValue
EXEC RemoveDefaultNullValue

GO

CREATE OR ALTER PROCEDURE AddReviewIdPK
AS
    ALTER TABLE Review
    ADD CONSTRAINT PK_ReviewId PRIMARY KEY (ReviewId)
GO

CREATE OR ALTER PROCEDURE RemoveReviewIdPK
AS
    ALTER TABLE Review
    DROP CONSTRAINT PK_ReviewId
GO

EXEC RemoveReviewIdPK
EXEC AddReviewIdPK

GO
CREATE OR ALTER PROCEDURE AddUsernameCandidateKey
AS
    ALTER TABLE ClientUser
    ADD CONSTRAINT UniqueUsername UNIQUE (Username)
GO

CREATE OR ALTER PROCEDURE RemoveUsernameCandidateKey
AS
    ALTER TABLE ClientUser
    DROP CONSTRAINT UniqueUsername
GO

EXEC RemoveUsernameCandidateKey
EXEC AddUsernameCandidateKey

GO

CREATE OR ALTER PROCEDURE AddUserIdRecordIdFKInTransaction
AS
    ALTER TABLE UserTransaction
    ADD CONSTRAINT FK_UserId_RecordId FOREIGN KEY (UserId, RecordId) REFERENCES Users_Records(UserId, RecordId)
GO

CREATE OR ALTER PROCEDURE RemoveUserIdRecordIdFKInTransaction
AS
    ALTER TABLE UserTransaction
    DROP CONSTRAINT FK_UserId_RecordId
GO

EXEC RemoveUserIdRecordIdFKInTransaction
EXEC AddUserIdRecordIdFKInTransaction

CREATE OR ALTER PROCEDURE CreateRecordLabelTable
AS
    CREATE TABLE RecordLabel
        (LabelId INT IDENTITY (1, 1),
         Name VARCHAR(50) UNIQUE,
         CONSTRAINT PK_LabelId PRIMARY KEY (LabelId))

    CREATE TABLE Artist_RecordLabel
        (ArtistId INT REFERENCES Artist(ArtistId),
         LabelId INT REFERENCES RecordLabel(LabelId))
GO

CREATE OR ALTER PROCEDURE DropRecordLabelTable
AS
    DROP TABLE Artist_RecordLabel
    DROP TABLE RecordLabel
GO

EXEC CreateRecordLabelTable
EXEC DropRecordLabelTable


CREATE OR ALTER PROCEDURE CreateDatabaseVersionTable
AS
    DROP TABLE IF EXISTS DatabaseVersion
    CREATE TABLE DatabaseVersion
        (VersionId INT IDENTITY (1,1) PRIMARY KEY,
         LastProcedureName VARCHAR(50),
         ReverseProcedureName VARCHAR(50),
         IsVersionSelected BIT
        )

    BEGIN TRY EXEC DropRecordLabelTable END TRY BEGIN CATCH END CATCH
    BEGIN TRY EXEC RemoveUserIdRecordIdFKInTransaction END TRY BEGIN CATCH END CATCH
    BEGIN TRY EXEC RemoveUsernameCandidateKey END TRY BEGIN CATCH END CATCH
    BEGIN TRY EXEC RemoveReviewIdPK END TRY BEGIN CATCH END CATCH
    BEGIN TRY EXEC RemoveDefaultNullValue END TRY BEGIN CATCH END CATCH
    BEGIN TRY EXEC RemoveVotesFieldFromReviews END TRY BEGIN CATCH END CATCH
    BEGIN TRY EXEC ReverseRecordsInStockType END TRY BEGIN CATCH END CATCH

    INSERT INTO DatabaseVersion(LastProcedureName, ReverseProcedureName, IsVersionSelected) VALUES ('ChangeRecordsInStockType', 'ReverseRecordsInStockType', 1)
    INSERT INTO DatabaseVersion(LastProcedureName, ReverseProcedureName, IsVersionSelected) VALUES ('AddVotesFieldToReviews', 'RemoveVotesFieldFromReviews', 1)
    INSERT INTO DatabaseVersion(LastProcedureName, ReverseProcedureName, IsVersionSelected) VALUES ('AddDefaultNullValue', 'RemoveDefaultNullValue', 1)
    INSERT INTO DatabaseVersion(LastProcedureName, ReverseProcedureName, IsVersionSelected) VALUES ('AddReviewIdPK', 'RemoveReviewIdPK', 1)
    INSERT INTO DatabaseVersion(LastProcedureName, ReverseProcedureName, IsVersionSelected) VALUES ('AddUsernameCandidateKey', 'RemoveUsernameCandidateKey', 1)
    INSERT INTO DatabaseVersion(LastProcedureName, ReverseProcedureName, IsVersionSelected) VALUES ('AddUserIdRecordIdFKInTransaction', 'RemoveUserIdRecordIdFKInTransaction', 1)
    INSERT INTO DatabaseVersion(LastProcedureName, ReverseProcedureName, IsVersionSelected) VALUES ('CreateRecordLabelTable', 'DropRecordLabelTable', 1)

    DECLARE @TableSize INT = (SELECT COUNT(*) FROM DatabaseVersion)
    DECLARE @Action NVARCHAR(100)
    DECLARE @IT INT = 1
    WHILE @IT <= @TableSize
    BEGIN
        SET @Action = 'EXEC ' + CAST((SELECT DV.LastProcedureName FROM DatabaseVersion DV WHERE DV.VersionId = @IT) AS NVARCHAR(50))
        PRINT 'Action: ' + @Action
        EXEC sp_executesql @Action
        SET @IT = @IT + 1
    END
GO

EXEC CreateDatabaseVersionTable

CREATE OR ALTER PROCEDURE SelectDatabaseVersion (@VersionNumber INT)
AS
    DECLARE @NumberOfVersions INT = (SELECT COUNT(*) FROM DatabaseVersion)
    IF @VersionNumber >= 1 AND @VersionNumber <= @NumberOfVersions
    BEGIN
        DECLARE @SelectedVersion INT = (SELECT MAX(DV.VersionId) FROM DatabaseVersion DV WHERE DV.IsVersionSelected = 1)
        IF @VersionNumber = @SelectedVersion
        BEGIN
            PRINT 'Version ' + cast(@SelectedVersion as VARCHAR(4)) + ' has been already selected.'
            RETURN
        END

        DECLARE @IncrementorValue INT = IIF(@SelectedVersion > @VersionNumber, -1, 1)
        DECLARE @Action NVARCHAR(100)

        WHILE @SelectedVersion != @VersionNumber
        BEGIN
            IF @IncrementorValue = -1
                SET @Action = 'EXEC ' + CAST((SELECT DV.ReverseProcedureName FROM DatabaseVersion DV WHERE DV.VersionId = @SelectedVersion) AS NVARCHAR(50))
            ELSE
                SET @Action = 'EXEC ' + CAST((SELECT DV.LastProcedureName FROM DatabaseVersion DV WHERE DV.VersionId = @SelectedVersion + 1) AS NVARCHAR(50))

            EXEC sp_executesql @Action
            PRINT 'VERSION ' + CAST(@SelectedVersion AS VARCHAR(5)) + 'OPERATION: ' + @Action


            UPDATE DatabaseVersion
            SET IsVersionSelected = IIF(@IncrementorValue = 1, 1, 0)
            WHERE VersionId = @SelectedVersion + IIF(@IncrementorValue = 1, 1, 0)

            SET @SelectedVersion = @SelectedVersion + @IncrementorValue
            PRINT 'VERSION ' + CAST(@SelectedVersion AS VARCHAR(5))
        END
    END
    ELSE
    BEGIN
        PRINT 'The version number should be between 1 and ' + cast(@NumberOfVersions as VARCHAR(4))
    END
GO

EXEC SelectDatabaseVersion @VersionNumber = 7
SELECT * FROM DatabaseVersion

GO

/**
SELECT name, type, unique_index_id, is_system_named
FROM sys.key_constraints
WHERE type = 'PK';
 */