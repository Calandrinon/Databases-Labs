DECLARE @ArtistName VARCHAR(50), @ArtistYear SMALLINT 
DECLARE ArtistCursor CURSOR FOR
    SELECT A.Name, A.EstablishmentYear
    FROM Artist A
OPEN ArtistCursor
FETCH NEXT FROM ArtistCursor INTO @ArtistName, @ArtistYear
WHILE @@FETCH_STATUS = 0 
    BEGIN
        PRINT @ArtistName + ',' + cast(@ArtistYear as VARCHAR(4))
        FETCH NEXT FROM ArtistCursor INTO @ArtistName, @ArtistYear
    END
CLOSE ArtistCursor
DEALLOCATE ArtistCursor