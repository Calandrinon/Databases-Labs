/**
CREATE TABLE Album 
    (AlbumId INT IDENTITY(1, 1) PRIMARY KEY,
		     Name VARCHAR(50) NOT NULL,
		     ReleaseDate DATE NOT NULL,
		     AlbumArtLink VARCHAR(200),
		     UNIQUE(Name, ReleaseDate, AlbumArtLink))


CREATE TABLE Genre
    (GenreId INT IDENTITY(1, 1) PRIMARY KEY,
		     Title VARCHAR(30) NOT NULL UNIQUE)


CREATE TABLE Albums_Genres
    (AlbumId INT REFERENCES Album(AlbumId),
		     GenreId INT REFERENCES Genre(GenreId),
		     PRIMARY KEY (AlbumId, GenreId))
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
--  1)
        SELECT * FROM Album A WHERE A.ReleaseDate < '2000-12-30'
