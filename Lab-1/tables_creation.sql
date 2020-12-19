DROP TABLE IF EXISTS Concert, Concerts_Artists, Users_Records, Record_UserTransaction, Albums_Genres, Artists_Musicians, Artists_Albums, Albums_Songs, Genre, Review, Song, UserTransaction, Record, Album, Artist, Musician, ClientUser;

CREATE TABLE Artist 
    (ArtistId INT IDENTITY(1, 1) PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    EstablishmentYear SMALLINT,
    UNIQUE (Name, EstablishmentYear))

-- An artist can be either an individual, or a band with multiple members.
-- Therefore, we can create a separate table for storing musicians, and an intermediary table
-- for storing the relationship of musicians associated with each so-called artist/band.

CREATE TABLE Musician
    (MusicianId INT IDENTITY(1, 1) PRIMARY KEY,
     Name VARCHAR(50) NOT NULL,
     Date_of_birth DATE NOT NULL,
     UNIQUE (Name, Date_of_birth))


CREATE TABLE Artists_Musicians
    (ArtistId INT REFERENCES Artist(ArtistId),
     MusicianId INT REFERENCES Musician(MusicianId),
     PRIMARY KEY (ArtistId, MusicianId))


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


CREATE TABLE Artists_Albums
    (ArtistId INT REFERENCES Artist(ArtistId),
     AlbumId INT REFERENCES Album(AlbumId),
     PRIMARY KEY (ArtistId, AlbumId))


CREATE TABLE Song
    (SongId INT IDENTITY(1, 1) PRIMARY KEY,
     Title VARCHAR(50),
     Length TINYINT,
     ArtistId INT REFERENCES Artist(ArtistId))


CREATE TABLE Albums_Songs
    (AlbumId INT REFERENCES Album(AlbumId) ON DELETE CASCADE,
     SongId INT REFERENCES Song(SongId) ON DELETE CASCADE,
     PRIMARY KEY(AlbumId, SongId))


CREATE TABLE Record
    (RecordId INT IDENTITY(1, 1) PRIMARY KEY,
     AlbumId INT REFERENCES Album(AlbumId) ON DELETE CASCADE,
     Price REAL NOT NULL,
     InStock INT NOT NULL,
     RecordType VARCHAR(10) NOT NULL,
     UNIQUE (AlbumId, RecordType))


CREATE TABLE ClientUser
    (UserId INT IDENTITY(1, 1),
     Username VARCHAR(50) NOT NULL,
     EncryptedPassword VARCHAR(50) NOT NULL,
     RegistrationDate DATETIME NOT NULL,
     CONSTRAINT PK_UserId PRIMARY KEY (UserId))


CREATE TABLE Users_Records
    (UserId INT REFERENCES ClientUser(UserId),
     RecordId INT REFERENCES Record(RecordId) ON DELETE CASCADE,
     PRIMARY KEY (UserId, RecordId))


CREATE TABLE UserTransaction
    (TransactionId INT IDENTITY(1, 1) PRIMARY KEY,
     UserId INT REFERENCES ClientUser(UserId) ON DELETE CASCADE,
     RecordId INT REFERENCES Record(RecordId) ON DELETE CASCADE,
     TransactionDateTime DATETIME NOT NULL,
     CONSTRAINT FK_UserId_RecordId FOREIGN KEY (UserId, RecordId) REFERENCES Users_Records(UserId, RecordId))


CREATE TABLE Review
    (ReviewId INT IDENTITY(1, 1),
     UserId INT REFERENCES ClientUser(UserId) ON DELETE CASCADE,
     ReviewText TEXT NOT NULL,
     ReviewTime DATETIME NOT NULL,
     Rating INT CHECK (Rating >= 1 AND Rating <= 10),
     RecordId INT REFERENCES Record(RecordId),
     CONSTRAINT PK_ReviewId PRIMARY KEY (ReviewId),
     CONSTRAINT FK_Review_UserId FOREIGN KEY (UserId, RecordId) REFERENCES Users_Records(UserId, RecordId))


CREATE TABLE Concert
    (ConcertId INT IDENTITY(1, 1) PRIMARY KEY,
     Country VARCHAR(30),
     City VARCHAR(30),
     Place VARCHAR(50),
     ConcertTime DATETIME,
     AvailableTickets INT,
     UNIQUE (Place, ConcertTime))


CREATE TABLE Concerts_Artists
    (ConcertId INT REFERENCES Concert(ConcertId),
     ArtistId INT REFERENCES Artist(ArtistId),
     PRIMARY KEY (ConcertId, ArtistId))

