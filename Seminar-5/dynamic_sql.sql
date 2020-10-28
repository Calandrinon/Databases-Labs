DECLARE @MaxArtistYear SMALLINT = 1970, @SQLStatement NVARCHAR(200)
SET @SQLStatement = 'SELECT * FROM Artist WHERE EstablishmentYear <= ' + CAST(@MaxArtistYear as VARCHAR(5))

EXECUTE sp_executesql @SQLStatement

PRINT @SQLStatement