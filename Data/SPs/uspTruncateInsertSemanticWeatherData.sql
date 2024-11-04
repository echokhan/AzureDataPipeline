CREATE PROCEDURE uspTruncateInsertSemanticWeatherData
AS
BEGIN
    -- Truncate the table to remove old data if performing a full refresh
    TRUNCATE TABLE semantic.WeatherData;

    -- Insert transformed data from transformed.weatherdata into semantic.WeatherData
    INSERT INTO semantic.WeatherData (date_only, time_only, city_name, latitude, longitude, temperature_celsius, visibility,
        dew_point_celsius, feels_like_celsius, min_temperature_celsius, max_temperature_celsius, pressure, humidity, humidity_level,
		wind_speed, wind_speed_category, wind_deg, clouds_all, weather_id, weather_main, weather_description, source, raw_timestamp
    )
    SELECT
        date_only,
        time_only,
        city_name,
        latitude,
        longitude,
        temperature - 273.15 AS temperature_celsius,
        visibility,
        dew_point - 273.15 AS dew_point_celsius,
        feels_like - 273.15 AS feels_like_celsius,
        temp_min - 273.15 AS min_temperature_celsius,
        temp_max - 273.15 AS max_temperature_celsius,
        pressure,
        humidity,
        CASE 
            WHEN humidity < 30 THEN 'Low'
            WHEN humidity BETWEEN 30 AND 60 THEN 'Moderate'
            ELSE 'High'
        END AS humidity_level,
        wind_speed,
        CASE 
            WHEN wind_speed < 1 THEN 'Calm'
            WHEN wind_speed BETWEEN 1 AND 5 THEN 'Light Breeze'
            WHEN wind_speed BETWEEN 5 AND 10 THEN 'Moderate Breeze'
            WHEN wind_speed BETWEEN 10 AND 20 THEN 'Strong Breeze'
            ELSE 'High Wind'
        END AS wind_speed_category,
        wind_deg,
        clouds_all,
        weather_id,
        weather_main, 
        weather_description,
        source,
        raw_timestamp
    FROM transformed.weatherdata;
END;