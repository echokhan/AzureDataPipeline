CREATE PROCEDURE uspUpsertDimCity
AS
BEGIN
MERGE INTO [dim].[city] AS TARGET
USING (
SELECT city_name, lat, lon
FROM 
[raw].[Batch_WeatherData]
GROUP BY city_name, lat, lon
) AS SOURCE
ON TARGET.city_name = SOURCE.city_name
-- For Inserts
WHEN NOT MATCHED BY TARGET THEN 
INSERT VALUES (
	SOURCE.city_name,
	SOURCE.lat,
	SOURCE.lon)
-- For Updates
WHEN MATCHED THEN UPDATE SET
    TARGET.lat= SOURCE.lat,
    TARGET.lon = SOURCE.lon;
END;