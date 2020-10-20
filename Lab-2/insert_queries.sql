--DELETE FROM Album;
--DELETE FROM Artist;
--DELETE FROM Musician;

INSERT INTO Album(Name, ReleaseDate, AlbumArtLink) VALUES ('Dark Side Of The Moon', '03-24-1973', 'https://img.discogs.com/fiE-V96-T7zh1p_hY5PWHCQ0m1k=/fit-in/300x300/filters:strip_icc():format(jpeg):mode_rgb():quality(40)/discogs-images/R-3417275-1329604382.jpeg.jpg')
INSERT INTO Album(Name, ReleaseDate, AlbumArtLink) VALUES ('Yes', '07-25-1969', 'https://upload.wikimedia.org/wikipedia/en/3/37/Yes_-_Yes.jpg')
INSERT INTO Album(Name, ReleaseDate, AlbumArtLink) VALUES ('Hemispheres', '10-29-1978', 'https://upload.wikimedia.org/wikipedia/en/6/6c/Rush_Hemispheres.jpg')

INSERT INTO Artist(Name, EstablishmentYear) VALUES ('Pink Floyd', 1965)
INSERT INTO Artist(Name, EstablishmentYear) VALUES ('Yes', 1968)
INSERT INTO Artist(Name, EstablishmentYear) VALUES ('Rush', 1968)

INSERT INTO Musician(Name, Date_of_birth) VALUES ('Syd Barrett', '01-06-1946')
INSERT INTO Musician(Name, Date_of_birth) VALUES ('Roger Waters', '09-06-1943')
INSERT INTO Musician(Name, Date_of_birth) VALUES ('David Gilmour', '03-06-1946')
INSERT INTO Musician(Name, Date_of_birth) VALUES ('Richard Wright', '07-28-1943')
INSERT INTO Musician(Name, Date_of_birth) VALUES ('Nick Mason', '01-27-1944')
INSERT INTO Musician(Name, Date_of_birth) VALUES (NULL, '01-22-1521')
INSERT INTO Musician(Name, Date_of_birth) VALUES ('John Anderson', '10-25-1944')
INSERT INTO Musician(Name, Date_of_birth) VALUES ('Chris Squire', '03-04-1948')
INSERT INTO Musician(Name, Date_of_birth) VALUES ('Peter Banks', '07-15-1947')
INSERT INTO Musician(Name, Date_of_birth) VALUES ('Tony Kaye', '01-11-1945')
INSERT INTO Musician(Name, Date_of_birth) VALUES ('Bill Bruford', '05-17-1949')
INSERT INTO Musician(Name, Date_of_birth) VALUES ('Geddy Lee', '07-29-1953')
INSERT INTO Musician(Name, Date_of_birth) VALUES ('Alex Lifeson', '08-27-1953')
INSERT INTO Musician(Name, Date_of_birth) VALUES ('Neil Peart', '09-12-1952')

INSERT INTO Genre(Title) VALUES ('Progressive Rock')

INSERT INTO Record(AlbumId, Price, InStock, RecordType) VALUES (1, 49.99, 250, 'Vinyl') 
INSERT INTO Record(AlbumId, Price, InStock, RecordType) VALUES (1, 10.99, 500, 'CD') 
INSERT INTO Record(AlbumId, Price, InStock, RecordType) VALUES (2, 35.59, 145, 'Vinyl') 
INSERT INTO Record(AlbumId, Price, InStock, RecordType) VALUES (2, 9.99, 200, 'CD') 
INSERT INTO Record(AlbumId, Price, InStock, RecordType) VALUES (3, 45.99, 250, 'Vinyl') 
INSERT INTO Record(AlbumId, Price, InStock, RecordType) VALUES (3, 25.99, 250, 'CD') 
INSERT INTO Record(AlbumId, Price, InStock, RecordType) VALUES (999, 999.99, 250, 'CD') 

INSERT INTO ClientUser(Username, EncryptedPassword) VALUES ('User123', '8gh8hg;koghj38kjhgys893ol;kmn')
INSERT INTO ClientUser(Username, EncryptedPassword) VALUES ('User456', '82ygbjgi87tgh3u76rdcvdghuytgb')
INSERT INTO ClientUser(Username, EncryptedPassword) VALUES ('User789', 'nhgtf673ukj9gh84ijgo049hno4gj')

INSERT INTO Users_Records(UserId, RecordId) VALUES (2, 3)
INSERT INTO Users_Records(UserId, RecordId) VALUES (2, 5)
INSERT INTO Users_Records(UserId, RecordId) VALUES (1, 2)
INSERT INTO Users_Records(UserId, RecordId) VALUES (3, 5)
INSERT INTO Users_Records(UserId, RecordId) VALUES (3, 5)
INSERT INTO Users_Records(UserId, RecordId) VALUES (3, 1)

DELETE FROM UserTransaction;
INSERT INTO UserTransaction(UserId, RecordId, TransactionDateTime) VALUES (1, 2, '20200618 10:34:09 AM')
INSERT INTO UserTransaction(UserId, RecordId, TransactionDateTime) VALUES (1, 2, '20200712 11:22:42 PM')
INSERT INTO UserTransaction(UserId, RecordId, TransactionDateTime) VALUES (2, 5, '20200618 05:22:42 PM')
INSERT INTO UserTransaction(UserId, RecordId, TransactionDateTime) VALUES (2, 3, '20200530 09:22:42 AM')
INSERT INTO UserTransaction(UserId, RecordId, TransactionDateTime) VALUES (3, 1, '20200527 12:15:03 PM')
INSERT INTO UserTransaction(UserId, RecordId, TransactionDateTime) VALUES (3, 5, '20201002 10:10:10 AM')
INSERT INTO UserTransaction(UserId, RecordId, TransactionDateTime) VALUES (3, 5, '20191225 09:20:25 PM')
INSERT INTO UserTransaction(UserId, RecordId, TransactionDateTime) VALUES (3, 5, '20200902 11:11:25 AM')
INSERT INTO UserTransaction(UserId, RecordId, TransactionDateTime) VALUES (3, 200, '20200902 11:11:25 AM')


SELECT * FROM Album;
SELECT * FROM Artist;
SELECT * FROM Musician;
SELECT * FROM Genre;
SELECT * FROM Record;
SELECT * FROM ClientUser;
SELECT * FROM Users_Records;
SELECT * FROM UserTransaction;