-- Displays the albums of each band: warm-up exercise
SELECT Ar.Name AS ArtistName, Al.Name AS AlbumTitle, Al.AlbumId
FROM Artist Ar, Album Al, Artists_Albums AA
WHERE Al.AlbumId = AA.AlbumId AND Ar.ArtistId = AA.ArtistId;

-- UNION
-- Gets all the artists which belong to either the progressive rock genre or the psychedelic rock genre
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
               WHERE AG.GenreId = 2)))


-- All transactions made in the last 2 months UNION transactions with a cost greater than 30
SELECT *
FROM UserTransaction T
WHERE T.TransactionDateTime >= GETDATE() - 60 OR T.RecordId IN
    (SELECT R.RecordId 
     FROM Record R
     WHERE R.Price >= 30)
    ORDER BY T.TransactionDateTime DESC


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



-- Get the top 5 users whose accounts are older than a year and wrote no negative reviews
SELECT TOP(5) U.UserId, U.Username
FROM ClientUser U
WHERE U.UserId IN
    (SELECT U.UserId
    FROM ClientUser U
    WHERE U.RegistrationDate < GETDATE() - 365
    EXCEPT
    SELECT R.UserId
    FROM Review R
    WHERE R.Rating < 5)


-- Get bands which don't belong to the progressive rock genre
SELECT A.Name 
FROM Artist A
WHERE A.ArtistId NOT IN
    (SELECT AA.ArtistId
    FROM Artists_Albums AA
    WHERE AA.AlbumId IN
          (SELECT Al.AlbumId
           FROM Album Al
           WHERE AlbumId IN
                 (SELECT AG.AlbumId
                  FROM Albums_Genres AG
                  WHERE AG.GenreId = 1)))
    ORDER BY A.Name ASC


-- Get all users and their transactions made after the 1st of September, 2020 having a bad rating
SELECT * --C.Username, UT.RecordId, UT.TransactionDateTime, R.Rating
FROM ClientUser C
INNER JOIN UserTransaction UT ON (UT.UserId = C.UserId AND UT.TransactionDateTime >= '20200901 00:00:00 AM') 
INNER JOIN Review R ON (UT.UserId = C.UserId AND R.RecordId = UT.RecordId AND R.Rating < 5)


-- Check who made and who didn't make a transaction after the 1st of September, 2020
SELECT C.Username, UT.RecordId, UT.TransactionDateTime
FROM ClientUser C
LEFT JOIN UserTransaction UT ON (UT.UserId = C.UserId AND UT.TransactionDateTime >= '20200901 00:00:00 AM')


-- Get the musicians which participate at the concerts stored in the database
SELECT DISTINCT ConcertId, AM.ArtistId
FROM Concerts_Artists CA
RIGHT JOIN Artists_Musicians AM on CA.ArtistId = AM.ArtistId  -- 3NF


-- Get the IDs of the artists, their albums and the genres they belong to
SELECT *
FROM Artists_Albums AA
FULL JOIN Albums_Genres AG on AA.AlbumId = AG.AlbumId


-- Display all concerts if there are concerts with the number of available tickets greater than 150k
SELECT *
FROM Concert C 
WHERE EXISTS
    (SELECT *  
     FROM Concert C WHERE C.AvailableTickets >= 150000)


-- Display all concerts if there are concerts organized in Romania
SELECT C.Country, C.City, C.AvailableTickets
FROM Concert C
WHERE EXISTS
    (SELECT *
     FROM Concert C WHERE C.Country = 'Romania')


-- Subquery in the FROM clause: All records with a price greater than 30$ and with more than 200 samples in stock
SELECT *
FROM (SELECT *
      FROM Record R
      WHERE R.Price > 30) AS R
     WHERE R.InStock > 200


-- Subquery in the FROM clause: All users which registered their account after 1st of September, 2020
SELECT *
FROM (SELECT *
      FROM ClientUser C
      WHERE C.RegistrationDate >= '20200901 00:00:00 AM') AS C


-- Statement using GROUP BY: Records and the money spent in total by clients on them
SELECT UT.RecordId, SUM(R.Price) AS MoneySpent
FROM UserTransaction UT INNER JOIN Record R ON UT.RecordId = R.RecordId
GROUP BY UT.RecordId


-- GROUP BY statement: Artists which have more than 2 albums in the database
SELECT A.Name
FROM Artist A
WHERE A.ArtistId IN
    (SELECT AA.ArtistId
    FROM Artists_Albums AA
    GROUP BY AA.ArtistId
    HAVING COUNT(AA.ArtistId) >= 2)


-- GROUP BY statement with subquery in the HAVING clause: All users whose average expense is greater than
--                                                        the average expense of all users
SELECT UT.UserId
FROM (UserTransaction UT INNER JOIN Record R ON UT.RecordId = R.RecordId)
GROUP BY UT.UserId
HAVING AVG(R.Price) >= (SELECT AVG(R.Price)
                       FROM Record R)


-- Statement with an ANY clause
-- All albums which have corresponding cheap records in the database (price in the range between the minimum
-- price and the minimum+10)
SELECT Al.Name
FROM Album Al
WHERE Al.AlbumId IN
    (SELECT R.AlbumId
     FROM Record R
     WHERE R.Price = ANY
        (SELECT R.Price
        FROM Record R
        GROUP BY R.Price
        HAVING R.Price <= (SELECT MIN(R.Price)
                                    FROM Record R) + 10))
-- Rewritten with IN
SELECT Al.Name
FROM Album Al
WHERE Al.AlbumId IN
      (SELECT R.AlbumId
       FROM Record R
       WHERE R.Price IN
             (SELECT R.Price
              FROM Record R
              GROUP BY R.Price
              HAVING R.Price <= (SELECT MIN(R.Price)
                                 FROM Record R) + 10))


-- Statement with an ANY clause
-- Concerts with the number of available tickets over 150k
SELECT *
FROM Concert C
WHERE C.ConcertId = ANY (SELECT C.ConcertId FROM Concert C WHERE C.AvailableTickets >= 150000);
-- Rewritten with IN
SELECT *
FROM Concert C
WHERE C.ConcertId IN
    (SELECT C.ConcertId
     FROM Concert C
     WHERE C.AvailableTickets >= 150000);


-- Statement with an ALL clause
-- The albums with the most expensive corresponding records in the database
SELECT Al.Name
FROM Album Al
WHERE Al.AlbumId IN
    (SELECT R.AlbumId
    FROM Record R
    WHERE R.Price >= ALL (SELECT R.Price FROM Record R))
-- Rewritten with MAX
SELECT Al.Name
FROM Album Al
WHERE Al.AlbumId IN
      (SELECT R.AlbumId
       FROM Record R
       WHERE R.Price IN (SELECT MAX(R.Price) FROM Record R))


-- Statement with an ALL clause
-- Gets the IDs of the records with the most samples in stock
SELECT R.RecordId, R.InStock
FROM Record R
WHERE R.InStock >= ALL (SELECT R.InStock
                            FROM Record R)
-- Rewritten with MAX
SELECT R.RecordId, R.InStock
FROM Record R
WHERE R.InStock IN (SELECT MAX(R.InStock)
                        FROM Record R)



