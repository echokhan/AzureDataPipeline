# Azure Data Pipeline
## Weather Data

## 1- Overview
This project implements an end-to-end ETL pipeline to ingest, process, and store weather data from multiple sources (REST API and CSV file) into a cloud-based data warehouse, making it ready for visualization. This pipeline is designed to handle both real-time and batch processing, with orchestration and monitoring capabilities for robust, scalable data processing.

## Architecture
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

## Data Model
![image](https://github.com/user-attachments/assets/3c7c9538-5fa8-4f43-82b5-540e5039922a)

The data model for this ETL pipeline is designed with three primary layers to manage data processing and transformation, ensuring each layer serves a specific purpose in preparing data for analysis and reporting. The model progresses through raw, transformed, and semantic layers, each with its own tables and processes.
This layered data model ensures a clean, organized, and optimized approach to data processing. Each layer serves a specific function in the ETL pipeline:
- **Raw Layer**: Ingests and stores unprocessed data.
- **Dimensional Table**: Enriches data with city information.
- **Transformed Layer**: Cleanses and prepares data for reporting.
- **Semantic Layer**: Final reporting-ready data for visualization.

This structured approach makes the pipeline scalable, maintainable, and adaptable for new data sources or additional transformations in the future.
More detail in Data directory.

## Orchestration
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

## Logic App: Failure Notification
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







