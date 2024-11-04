CREATE PROCEDURE uspBatchUpsertTransformedWeatherData
AS
BEGIN
    -- Step 1: Update records where city_name, date_only, and time_only all match
WITH SourceWithRowNumber AS (
    SELECT 
        CAST(CONVERT(DATETIME, LEFT(dt_iso, 19), 120) AS DATE) AS date_only,
        CONVERT(VARCHAR(8), CONVERT(DATETIME, LEFT(dt_iso, 19), 120), 108) AS time_only,
        city_name,
        lat AS latitude,
        lon AS longitude,
        temp AS temperature,
        visibility,
        dew_point,
        feels_like,
        temp_min,
        temp_max,
        pressure,
        humidity,
        wind_speed,
        wind_deg,
        clouds_all,
        weather_id,
        weather_main,
        weather_description,
		created_at as raw_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY city_name, dt, weather_id
            ORDER BY created_at DESC
        ) AS row_num
    FROM 
        [raw].[Batch_WeatherData]
)

MERGE INTO [transformed].[WeatherData] AS target
USING (
    SELECT * 
    FROM SourceWithRowNumber
    WHERE row_num = 1 -- Keeps only the latest record based on created_at for each unique combination
) AS source
    ON target.city_name = source.city_name
       AND target.date_only = source.date_only
       AND target.time_only = source.time_only
       AND target.weather_id = source.weather_id
    WHEN MATCHED THEN 
        UPDATE SET
            target.latitude = source.latitude,
            target.longitude = source.longitude,
            target.temperature = source.temperature,
            target.visibility = source.visibility,
            target.dew_point = source.dew_point,
            target.feels_like = source.feels_like,
            target.temp_min = source.temp_min,
            target.temp_max = source.temp_max,
            target.pressure = source.pressure,
            target.humidity = source.humidity,
            target.wind_speed = source.wind_speed,
            target.wind_deg = source.wind_deg,
            target.clouds_all = source.clouds_all,
            target.weather_main = source.weather_main,
            target.weather_description = source.weather_description,
			target.source = 'batch',
			target.raw_timestamp = source.raw_timestamp

    -- Step 2: Insert new records where any one of city_name, date_only, or time_only differs
    WHEN NOT MATCHED BY TARGET THEN
	INSERT (date_only, time_only, city_name, latitude, longitude, temperature, visibility, dew_point, feels_like, temp_min, temp_max, pressure, humidity, wind_speed, wind_deg, clouds_all, weather_id, weather_main, weather_description, source, raw_timestamp)
	VALUES (
        source.date_only,
        source.time_only,
        source.city_name,
        source.latitude,
        source.longitude,
        source.temperature,
        source.visibility,
        source.dew_point,
        source.feels_like,
        source.temp_min,
        source.temp_max,
        source.pressure,
        source.humidity,
        source.wind_speed,
        source.wind_deg,
        source.clouds_all,
        source.weather_id,
        source.weather_main,
        source.weather_description,
		'batch',
		source.raw_timestamp
    );
END;