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
GO
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

/**
SELECT name, type, unique_index_id, is_system_named
FROM sys.key_constraints
WHERE type = 'PK';
 */