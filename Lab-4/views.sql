CREATE OR ALTER VIEW GetArtistsEstablishedInThe1960s
AS
    SELECT * FROM Artist A WHERE A.EstablishmentYear BETWEEN 1960 AND 1969
GO

CREATE OR ALTER VIEW GetAlbumsReleasedInThe1970s
AS
    SELECT * FROM Album A WHERE A.ReleaseDate BETWEEN '01-01-1970' AND '01-01-1980'
GO

CREATE OR ALTER VIEW GetSongsReleasedInThe1980s
AS
    SELECT S.SongId, S.Title FROM Song S
    WHERE S.SongId IN
        (SELECT AlS.SongId
        FROM Albums_Songs AlS
        WHERE AlbumId IN
              (SELECT A.AlbumId FROM Album A WHERE A.ReleaseDate BETWEEN '01-01-1980' AND '01-01-1990'))
GO

CREATE OR ALTER VIEW GetArtWithTheirLongestSongHavingMoreThan15M
AS
    SELECT A.ArtistId FROM Artist A INNER JOIN Song S ON A.ArtistId = S.ArtistId GROUP BY A.ArtistId HAVING MAX(S.Length) > 15
GO


SELECT * FROM GetArtistsEstablishedInThe1960s
SELECT * FROM GetAlbumsReleasedInThe1970s
SELECT * FROM GetSongsReleasedInThe1980s
SELECT * FROM GetArtWithTheirLongestSongHavingMoreThan15M