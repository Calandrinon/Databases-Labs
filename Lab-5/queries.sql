/**
CREATE TABLE Album 
    (AlbumId INT IDENTITY(1, 1) PRIMARY KEY,
		     Name VARCHAR(50) NOT NULL,
		     ReleaseDate DATE NOT NULL,
		     AlbumArtLink VARCHAR(200),
		     UNIQUE(Name, ReleaseDate))


CREATE TABLE Genre
    (GenreId INT IDENTITY(1, 1) PRIMARY KEY,
		     Title VARCHAR(30) NOT NULL UNIQUE)


CREATE TABLE Albums_Genres
    (AlbumId INT REFERENCES Album(AlbumId),
		     GenreId INT REFERENCES Genre(GenreId),
		     PRIMARY KEY (AlbumId, GenreId))

CREATE TABLE Song
    (SongId INT IDENTITY(1, 1) PRIMARY KEY,
     Title VARCHAR(50),
     Length TINYINT,
     ArtistId INT REFERENCES Artist(ArtistId))
**/

--a)
--  1)
        SELECT * FROM Album A
--  2)
        SELECT * FROM Album A WHERE A.AlbumId >= 100 AND A.AlbumId <= 200
--  3)
        SELECT GenreId, Title FROM Genre G
--  4)
        SELECT GenreId, Title FROM Genre G WHERE Title = 'Progressive Rock'

--b)
        SELECT * FROM Album A WHERE A.AlbumArtLink = '0FCC4CCE-B0A2-40BA-88E6-393ABE'
        CREATE NONCLUSTERED INDEX AlbumIndex
            ON Album(AlbumArtLink)
        DROP INDEX AlbumIndex ON Album
        SELECT * FROM sys.indexes WHERE name LIKE '%Album%'

--c)
        SELECT * FROM sys.indexes WHERE name LIKE '%Artist%'
        SELECT * FROM sys.indexes WHERE name LIKE '%Song%'

        CREATE OR ALTER VIEW GetArtistsAndTheirSongs
        AS
            SELECT A.ArtistId, S.Title
            FROM Artist A LEFT JOIN Song S ON A.ArtistId = S.ArtistId
        GO

        SELECT * FROM GetArtistsAndTheirSongs
        CREATE NONCLUSTERED INDEX SongLengthIndex ON Song(Length)
        DROP INDEX SongLengthIndex ON Song
