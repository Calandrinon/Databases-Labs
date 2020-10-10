DROP TABLE IF EXISTS Albums_Genres, Artists_Musicians, Artists_Albums, Albums_Songs, Genre, Review, Song, UserTransaction, Record, Album, Artist, Musician, ClientUser;

CREATE TABLE Artist 
    (ArtistId INT IDENTITY(1, 1) PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    EstablishmentYear SMALLINT NOT NULL)

-- An artist can be either an individual, or a band with multiple members.
-- Therefore, we can create a separate table for storing musicians, and an intermediary table
-- for storing the relationship of musicians associated with each so-called artist/band.

CREATE TABLE Musician
    (MusicianId INT IDENTITY(1, 1) PRIMARY KEY,
     Name VARCHAR(50) NOT NULL,
     Date_of_birth DATE NOT NULL)


CREATE TABLE Artists_Musicians
    (ArtistId INT REFERENCES Artist(ArtistId),
     MusicianId INT REFERENCES Musician(MusicianId),
     PRIMARY KEY (ArtistId, MusicianId))


CREATE TABLE Album 
    (AlbumId INT IDENTITY(1, 1) PRIMARY KEY,
     Name VARCHAR(50) NOT NULL,
     ReleaseDate DATE NOT NULL,
     AlbumArtLink VARCHAR(200))


CREATE TABLE Genre
    (GenreId INT IDENTITY(1, 1) PRIMARY KEY,
     Title VARCHAR(30) NOT NULL)


CREATE TABLE Albums_Genres
    (AlbumId INT REFERENCES Album(AlbumId),
     GenreId INT REFERENCES Genre(GenreId),
     PRIMARY KEY (AlbumId, GenreId))


CREATE TABLE Artists_Albums
    (ArtistId INT REFERENCES Artist(ArtistId),
     AlbumId INT REFERENCES Album(AlbumId),
     PRIMARY KEY (ArtistId, AlbumId))


CREATE TABLE Song
    (SongId BIGINT IDENTITY(1, 1) PRIMARY KEY,
     Title VARCHAR(50))


CREATE TABLE Albums_Songs
    (AlbumId INT REFERENCES Album(AlbumId),
     SongId BIGINT REFERENCES Song(SongId),
     PRIMARY KEY(AlbumId, SongId))


CREATE TABLE Record
    (RecordId INT IDENTITY(1, 1) PRIMARY KEY,
     AlbumId INT REFERENCES Album(AlbumId),
     Price REAL NOT NULL,
     InStock INT NOT NULL,
     RecordType VARCHAR(10) NOT NULL)


CREATE TABLE ClientUser
    (UserId INT IDENTITY(1, 1) PRIMARY KEY,
     Username VARCHAR(50) NOT NULL UNIQUE,
     Password VARCHAR(50) NOT NULL) 


CREATE TABLE UserTransaction
    (TransactionId INT IDENTITY(1, 1) PRIMARY KEY,
     UserId INT REFERENCES ClientUser(UserId),
     RecordId INT REFERENCES Record(RecordId),
     TransactionDateTime DATETIME NOT NULL)


CREATE TABLE Review
    (ReviewId INT IDENTITY(1, 1) PRIMARY KEY,
     UserId INT REFERENCES ClientUser(UserId),
     ReviewText TEXT NOT NULL,
     ReviewTime DATETIME NOT NULL)
