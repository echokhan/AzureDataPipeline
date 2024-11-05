# Azure Data Pipeline
## Weather Data

## 1- Overview
This project implements an end-to-end ETL pipeline to ingest, process, and store weather data from multiple sources (REST API and CSV file) into a cloud-based data warehouse, making it ready for visualization. This pipeline is designed to handle both real-time and batch processing, with orchestration and monitoring capabilities for robust, scalable data processing.
### Key Features:
* Event and Metadata Driven: Batch pipeline is triggered by file uploads, whereas hourly pipeline is scheduled and takes input from control table (dim.city)
* Idempotency: Upserts/merge are used to ensure that no duplication of any weather record occurs and all rows in transformed and semantic layers are unique for an hour, city and weather_id.
* Operational Montoring: Failure updates for any pipeline are configured for all activities, ensuring prompt measures.
* Holistic Visualization: Dashboard visualizes live and historical data, along with an attempt to forecast weather.
* Data Lineage: Audit columns such as raw_timestamp and source allow source and ingestion time tracking.
* Event Driven: Use of dim city as control table and scheduled triggers make the pipeline highly automated, requiring minimum intervention.
* Backfilling: Due to the nature of idempotency, backfilling is an embeded feature and old data can be updated or even inserted based on hour, city and weather_id.
* Robustness: Retry mechanisms are in place within the orchestration (e.g., if the API or file ingestion fails, the system should retry before sending failure notifications)


## 2- Architecture
![WeatherETL](https://github.com/user-attachments/assets/a5236f4a-a206-405b-bde5-d447da5a29b3)

The pipeline follows a layered architecture:
1. **Data Sources**:
   - **OpenWeather API (Hourly)**: Provides real-time (hourly) weather data through an API.
   - **Historical Weather Data CSV**: Stored in a cloud-based data lake for batch loading.
2. **Data Lake**: Used as a landing area for the CSV file before ingestion into the data warehouse.
3. **Data Warehouse**: Organized into three layers:
   - **Raw Layer**: Stores raw ingested data from both the API and batch sources.
   - **Transformed Layer**: Data is cleaned, normalized, and transformed here for analysis.
   - **Semantic/Gold Layer**: Final, processed data ready for visualization.
4. **Orchestration**: Schedules and coordinates data loads (hourly and batch).
5. **Monitoring**: Provides alerts and failure notifications to ensure the pipeline is running smoothly.
6. **Visualization**: Connects the final semantic layer to Power BI for live and historical reporting.

## 3- Schema
![image](https://github.com/user-attachments/assets/3c7c9538-5fa8-4f43-82b5-540e5039922a)

The data model for this ETL pipeline is designed with three primary layers to manage data processing and transformation, ensuring each layer serves a specific purpose in preparing data for analysis and reporting. The model progresses through raw, transformed, and semantic layers, each with its own tables and processes.
This layered data model ensures a clean, organized, and optimized approach to data processing. Each layer serves a specific function in the ETL pipeline:
- **Raw Layer**: Ingests and stores unprocessed data.
- **Dimensional Table**: Enriches data with city information.
- **Transformed Layer**: Cleanses and prepares data for reporting.
- **Semantic Layer**: Final reporting-ready data for visualization.

This structured approach makes the pipeline scalable, maintainable, and adaptable for new data sources or additional transformations in the future.
More detail in Data directory.

## 4- Orchestration
Batch Load Pipeline
![image](https://github.com/user-attachments/assets/34e43cae-3125-4318-bd71-f7fa3b0b5d2b)
### Batch Data Load Pipeline

This pipeline automates the batch data ingestion and processing for weather data stored in blob storage, performing a sequence of ETL steps and handling notifications for errors. Here’s a breakdown of each step:
1. **Copy Data - Blob to Raw Batch Load**:
   - This step copies data from the blob storage (data lake) into the `raw.batch_weatherdata` table in the data warehouse. It initiates the batch load process.
2. **Stored Procedure - `uspUpsertDimCity`**:
   - This procedure upserts city information into the `dim.city` table, ensuring that city metadata is available for data enrichment in subsequent steps.
3. **Stored Procedure - `uspBatchUpsertTransformedWeatherData`**:
   - This procedure merges and transforms raw data with city information, populating the `transformed.weatherdata` table.
   - The upsert is based on unique columns such as city_name, dt and weather_id
4. **Stored Procedure - `uspTruncateInsertSemanticWeatherData`**:
   - This step truncates and inserts data into the `semantic.weatherdata` table, which is optimized for reporting and visualization.
5. **Archive Bulk Load**:
   - After successfully loading and processing data, this step archives the batch data from the landing directory to a specified archival directory in blob storage, preserving historical data for future reference.
6. **Delete Landing Bulk Load**:
   - Finally, the pipeline deletes the original batch data from the landing directory, freeing up storage space and maintaining data lake hygiene.

#### Error Handling
- **Failure Notification Emails**:
   - If any of the critical stored procedures fail, a notification email is sent to alert the team, allowing for prompt troubleshooting and resolution.


### Hourly Load Pipeline
![image](https://github.com/user-attachments/assets/0dbf8b88-a692-4b4d-95c2-e0fc7f64e52a)

This pipeline ingests and processes real-time weather data from the OpenWeather API on an hourly basis. It iterates over each city, fetching the latest weather data and updating the data warehouse. Here’s a breakdown of each step in this process:

1. **Lookup - List Cities**:
   - This initial step retrieves a list of cities from the `dim.city` table. The list is used to iterate over each city in the subsequent steps.
2. **ForEach - ForEachCity**:
   - This loop iterates through each city obtained from the lookup step. For each city, the following activities are performed:
   - **API to Raw Hourly Load**:
     - Loads the hourly weather data from the OpenWeather API into the `raw.hourly_weatherdata` table, storing it as raw data for auditing and historical reference.
   - **Stored Procedure - `uspHourlyUpsertTransformedWeatherData`**:
     - This stored procedure transforms and upserts data into the `transformed.weatherdata` table. It processes the raw data, applies any necessary transformations, and enriches it by joining with city information.
   - **Stored Procedure - `uspTruncateInsertSemanticWeatherData`**:
     - This step further processes the data by truncating and inserting it into the `semantic.weatherdata` table, which is optimized for reporting. It ensures that only the most current data is available for analysis and visualization.
   - **Failure Notification**:
     - If any part of the pipeline fails, a failure notification is triggered, sending an email to alert the team. This allows for immediate troubleshooting and ensures that issues are promptly addressed.

## 5- Logic App: Failure Notification
<img width="245" alt="image" src="https://github.com/user-attachments/assets/644618f0-ffb4-4c5b-8ba8-63d616bfaf86">

This Logic App is designed to handle failure notifications by sending an automated email when triggered by an HTTP request. Here’s how it works:

1. **When an HTTP Request is Received**:
   - This trigger listens for an incoming HTTP request, which can be sent from the data pipeline or other workflows in case of an error or failure event.
   - When the HTTP request is received, it initiates the process to send an email notification.

2. **Send an Email (V2)**:
   - After the HTTP request is triggered, this step automatically sends an email to a predefined recipient(s).
   - The email includes details about the failure, allowing the team to quickly respond to issues within the pipeline.
And example:
![image](https://github.com/user-attachments/assets/32041443-7bbe-454c-8237-94ced489a570)

## 6- Power BI Dashboard: Hourly Weather & Trends
![image](https://github.com/user-attachments/assets/76edf0b2-f8b9-4fba-aac8-853bd1608d1b)
### Purpose
The Power BI dashboard provides a comprehensive view of current and historical weather data, offering insights into real-time conditions and trends over time. It is designed to help users track weather patterns, monitor current conditions, and analyze trends based on historical data.

#### Features
1. **Latest Weather**:
   - Displays the most recent hourly weather data, including temperature, feels-like temperature, wind speed, humidity, and weather conditions.
   - Key metrics such as the 7-day rolling average temperature, today’s maximum and minimum temperatures are highlighted for quick insights.
2. **City Selector**:
   - Allows users to filter data by city (e.g., Bristol, Cardiff, London), enabling a focused view of weather data specific to each location.
3. **Historic Trends**:
   - Provides interactive filters for year, month, day, and date, allowing users to explore historical weather data and trends.
   - Graphs show the **Average Temperature** (actual vs. feels-like) and **Average Wind** speed over the day.
4. **Forecast**:
   - Visualizes projected average temperatures for the coming years, providing a forecasted trend line with confidence intervals.
5. **Summary Statistics**:
   - Displays important aggregated metrics such as average temperature, maximum/minimum temperature, maximum humidity, and maximum wind speed, giving users a snapshot of weather extremes and averages.
6. **Geographical Map**:
   - Shows the average temperature distribution across selected cities, providing a spatial overview of temperature variations.
### Summary
This dashboard combines real-time data, historical trends, and forecasted weather to give users a complete overview of weather patterns. With interactive filtering options, users can customize their view to explore specific time frames, cities, or weather metrics, making it a powerful tool for analyzing and understanding weather data trends.


## 7- Future Work
* Schema Validation: Get Metadata activity in ADF can be used to validate schema of API and bulk CSV.
* Optimization: Possible use of lakehouse for partitioning. This will result in cost reduction for storage and compute resulting in scalability. Optimization of joins and queries by indexing key columns.

