-- Displays the albums of each band: warm-up exercise
SELECT Ar.Name AS ArtistName, Al.Name AS AlbumTitle, Al.AlbumId
FROM Artist Ar, Album Al, Artists_Albums AA
WHERE Al.AlbumId = AA.AlbumId AND Ar.ArtistId = AA.ArtistId;

SELECT A.Name
FROM Artist A
WHERE A.ArtistId IN
    (SELECT AA.ArtistId
    FROM Artists_Albums AA
    WHERE AA.AlbumId IN
        (SELECT Al.AlbumId
        FROM Album Al
        WHERE AlbumId IN
            (SELECT AG.AlbumId
             FROM Albums_Genres AG
             WHERE AG.GenreId = 1)
        UNION
        SELECT Al.AlbumId
        FROM Album Al
        WHERE AlbumId IN
              (SELECT AG.AlbumId
               FROM Albums_Genres AG
               WHERE AG.GenreId = 2))) -- Gets all the artists which belong to either the progressive rock genre or the psychedelic rock genre


-- All transactions made in the last 2 months and transactions with a cost greater than 200
SELECT T.TransactionId
FROM UserTransaction T
WHERE T.TransactionDateTime >= GETDATE() - 60 OR T.RecordId IN
    (SELECT R.RecordId 
     FROM Record R
     WHERE R.Price >= 200)


-- Get users which bought more than 2 records and bought after 1st of October, 2020
SELECT U.Username
FROM ClientUser U
WHERE U.UserId IN
      (SELECT UT.UserId
       FROM UserTransaction UT
       GROUP BY UT.UserId
       HAVING COUNT(UT.UserId) > 2
       INTERSECT
       SELECT UT.UserId
       FROM UserTransaction UT
       WHERE UT.TransactionDateTime > '20201001 00:00:00 AM'
      )


-- Get users which wrote a negative review (score under 5) and whose accounts are older than a year
SELECT U.Username
FROM ClientUser U
WHERE U.UserId IN
    (SELECT R.UserId
    FROM Review R
    WHERE R.Rating < 5
    INTERSECT
    SELECT U.UserId
    FROM ClientUser U
    WHERE U.RegistrationDate < GETDATE() - 365)



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
    (SELECT AA.ArtistId
    FROM Artists_Albums AA
    WHERE AA.AlbumId IN
          (SELECT Al.AlbumId
           FROM Album Al
           WHERE AlbumId IN
                 (SELECT AG.AlbumId
                  FROM Albums_Genres AG
                  WHERE AG.GenreId = 1))
    EXCEPT
     SELECT AA.ArtistId
     FROM Artists_Albums AA
     WHERE AA.AlbumId IN
           (SELECT Al.AlbumId
            FROM Album Al
            WHERE AlbumId IN
                  (SELECT AG.AlbumId
                   FROM Albums_Genres AG
                   WHERE AG.GenreId = 2)))


-- Get all users and their transactions made after the 1st of September, 2020 having a bad rating
SELECT C.Username, UT.RecordId, UT.TransactionDateTime, R.Rating
FROM ClientUser C
INNER JOIN UserTransaction UT ON (UT.UserId = C.UserId AND UT.TransactionDateTime >= '20200901 00:00:00 AM') 
INNER JOIN Review R ON (R.RecordId = UT.RecordId AND R.Rating < 5)


-- Check who made and who didn't make a transaction after the 1st of September, 2020
SELECT DISTINCT C.Username, UT.RecordId, UT.TransactionDateTime 
FROM ClientUser C
LEFT JOIN UserTransaction UT ON (UT.UserId = C.UserId AND UT.TransactionDateTime >= '20200901 00:00:00 AM') 


SELECT C.Country, C.City, C.AvailableTickets
FROM Concert C 
WHERE EXISTS
    (SELECT *  
     FROM Concert C WHERE C.AvailableTickets >= 150000)
