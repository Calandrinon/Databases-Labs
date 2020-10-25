-- Displays the albums of each band: warm-up exercise
SELECT Ar.Name, Al.Name, Al.AlbumId
FROM Artist Ar, Album Al, Artists_Albums AA
WHERE Al.AlbumId = AA.AlbumId AND Ar.ArtistId = AA.ArtistId;

SELECT A.Name
FROM Artist A
WHERE A.ArtistId IN
    (SELECT A.ArtistId
    FROM Artist A
    WHERE EstablishmentYear = 1968
    UNION
    SELECT A.ArtistId
    FROM Artist A, Album Al
    WHERE Al.AlbumId IN
        (SELECT AG.AlbumId 
        FROM Albums_Genres AG
        WHERE AG.GenreId = 1)) --Obtains all the artists established in 1968 or belonging to the "progressive rock" genre  


-- All transactions made in the last month and transactions with a cost greater than 200
SELECT T.TransactionId
FROM UserTransaction T
WHERE T.TransactionDateTime >= GETDATE() - 30
UNION
SELECT T.TransactionId
FROM UserTransaction T
WHERE T.RecordId IN
    (SELECT R.RecordId 
     FROM Record R
     WHERE R.Price >= 200
    )


-- Get users which bought more than 1 record and spent more than 200$
SELECT UT.UserId
FROM UserTransaction UT
GROUP BY UT.UserId
HAVING COUNT(UT.UserId) >= 2
INTERSECT
SELECT UR.UserId
FROM Users_Records UR
WHERE 200 <= (SELECT SUM(R.Price) FROM Record R WHERE R.RecordId = UR.RecordId)


-- Get users which wrote a negative review (score under 5) and whose accounts are older than a year 
SELECT R.UserId
FROM Review R
WHERE R.Rating < 5
INTERSECT
SELECT U.UserId
FROM ClientUser U
WHERE U.RegistrationDate < GETDATE() - 365;



-- Get users whose accounts are older than a year and wrote no negative reviews 
SELECT U.UserId, U.Username
FROM ClientUser U
WHERE U.UserId IN
    (SELECT U.UserId
    FROM ClientUser U
    WHERE U.RegistrationDate < GETDATE() - 365
    EXCEPT
    SELECT R.UserId
    FROM Review R
    WHERE R.Rating < 5)


-- Get bands belonging to the progressive rock genre but not to the psychedelic rock genre
SELECT A.Name 
FROM Artist A
WHERE A.ArtistId IN
    (SELECT DISTINCT A.ArtistId
    FROM Artist A, Album Al
    WHERE Al.AlbumId IN
        (SELECT AG.AlbumId 
        FROM Albums_Genres AG
        WHERE AG.GenreId = 1)   
    EXCEPT
    SELECT AA.ArtistId
    FROM Artists_Albums AA
    WHERE AA.AlbumId IN
        (SELECT AG.AlbumId 
        FROM Albums_Genres AG
        WHERE AG.GenreId = 2)) 