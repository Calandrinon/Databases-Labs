CREATE OR ALTER VIEW ArtistsWithMoreThan2Albums
AS
    SELECT A.Name
    FROM Artist A
    WHERE A.ArtistId IN
          (SELECT AA.ArtistId
           FROM Artists_Albums AA
           GROUP BY AA.ArtistId
           HAVING COUNT(AA.ArtistId) >= 2)

SELECT * FROM ArtistsWithMoreThan2Albums