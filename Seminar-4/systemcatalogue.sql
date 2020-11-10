SELECT m.definition, o.name, o.type, o.type_desc
FROM sys.sql_modules m INNER JOIN sys.objects o ON m.object_id = o.object_id
WHERE o.type IN ('FN', 'IF', 'TF', 'P', 'V')