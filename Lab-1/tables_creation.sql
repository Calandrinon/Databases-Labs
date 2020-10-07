DROP TABLE IF EXISTS Albums_Genres, Artists_Musicians, Artists_Albums, Albums_Songs, Genre, Review, Song, UserTransaction, Record, Album, Artist, Musician, ClientUser;

CREATE TABLE Artist 
    (ArtistId INT PRIMARY KEY,
    Name VARCHAR(50),
    EstablishmentYear SMALLINT)

-- An artist can be either an individual, or a band with multiple members.
-- Therefore, we can create a separate table for storing musicians, and an intermediary table
-- for storing the relationship of musicians associated with each so-called artist/band.

CREATE TABLE Musician
    (MusicianId INT PRIMARY KEY,
     Name VARCHAR(50),
     Date_of_birth DATE)


CREATE TABLE Artists_Musicians
    (ArtistId INT REFERENCES Artist(ArtistId),
     MusicianId INT REFERENCES Musician(MusicianId),
     PRIMARY KEY (ArtistId, MusicianId))


CREATE TABLE Album 
    (AlbumId INT PRIMARY KEY,
     Name VARCHAR(50),
     ReleaseDate DATE,
     AlbumArtLink VARCHAR(200))


CREATE TABLE Genre
    (GenreId INT PRIMARY KEY,
     Title VARCHAR(30))


CREATE TABLE Albums_Genres
    (AlbumId INT REFERENCES Album(AlbumId),
     GenreId INT REFERENCES Genre(GenreId),
     PRIMARY KEY (AlbumId, GenreId))


CREATE TABLE Artists_Albums
    (ArtistId INT REFERENCES Artist(ArtistId),
     AlbumId INT REFERENCES Album(AlbumId),
     PRIMARY KEY (ArtistId, AlbumId))


CREATE TABLE Song
    (SongId BIGINT PRIMARY KEY,
     Title VARCHAR(50))


CREATE TABLE Albums_Songs
    (AlbumId INT REFERENCES Album(AlbumId),
     SongId BIGINT REFERENCES Song(SongId),
     PRIMARY KEY(AlbumId, SongId))


CREATE TABLE Record
    (RecordId INT PRIMARY KEY,
     AlbumId INT REFERENCES Album(AlbumId),
     Price REAL,
     InStock INT,
     RecordType VARCHAR(10))


CREATE TABLE ClientUser
    (UserId INT PRIMARY KEY,
     Username VARCHAR(50)) 


CREATE TABLE UserTransaction
    (TransactionId INT PRIMARY KEY,
     UserId INT REFERENCES ClientUser(UserId),
     RecordId INT REFERENCES Record(RecordId),
     TransactionDateTime DATETIME)


CREATE TABLE Review
    (ReviewId INT PRIMARY KEY,
     UserId INT REFERENCES ClientUser(UserId),
     ReviewText TEXT,
     ReviewTime DATETIME)
