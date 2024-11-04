CREATE TABLE raw.hourly_weatherdata (
    id INT IDENTITY(1,1) PRIMARY KEY,  -- Auto-increment column
    dt BIGINT,
    lat FLOAT,
    lon FLOAT,
    temp FLOAT,
    visibility INT,
    dew_point FLOAT,
    feels_like FLOAT,
    temp_min FLOAT,
    temp_max FLOAT,
    pressure INT,
    humidity INT,
    wind_speed FLOAT,
    wind_deg INT,
    clouds_all INT,
    weather_id INT,
    weather_main NVARCHAR(50),
    weather_description NVARCHAR(50),
    created_at DATETIME DEFAULT (GETUTCDATE())  -- Timestamp column with default UTC value
);