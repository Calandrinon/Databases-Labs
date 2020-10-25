UPDATE Record
SET InStock=300, Price=39.99
WHERE RecordId=5

UPDATE ClientUser
SET EncryptedPassword='oh8g73ybug98ubsnj09gh8ub3ihj9u'
WHERE UserId=3

UPDATE Review
SET ReviewTime='20201020 05:00:02 PM', ReviewText='I edited this review'
WHERE UserId=3

DELETE FROM UserTransaction
WHERE TransactionDateTime < '20050101 00:00:00 AM' AND TransactionDateTime >= '20030101 00:00:00 AM'

DELETE FROM Review
WHERE ReviewTime BETWEEN '20050101 00:00:00 AM' AND '20030101 00:00:00 AM'
