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

/**
CREATE OR ALTER PROCEDURE AddUserPK
AS
    ALTER TABLE ClientUser
    ADD CONSTRAINT PK_UserId_Username PRIMARY KEY (UserId, Username)
GO

CREATE OR ALTER PROCEDURE RemoveUserCompositePK
AS
    ALTER TABLE ClientUser
    DROP CONSTRAINT PK_UserId_Username
    ALTER TABLE ClientUser
    ADD CONSTRAINT PK_UserId PRIMARY KEY (UserId)
GO

EXEC AddUserCompositePK
EXEC RemoveUserCompositePK

SELECT name, type, unique_index_id, is_system_named
FROM sys.key_constraints
WHERE type = 'PK';
**/