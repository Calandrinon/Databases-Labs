CREATE OR ALTER TRIGGER BlockArtistDeletion
    ON Artist
    INSTEAD OF DELETE
AS
    PRINT 'Deleting artists is not allowed.'

DELETE FROM Artist
WHERE EstablishmentYear > 2000

DROP TRIGGER BlockArtistDeletion