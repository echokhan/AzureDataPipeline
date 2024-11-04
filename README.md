# Azure Data Pipeline
## Weather Data

## 1- Overview
This project implements an end-to-end ETL pipeline to ingest, process, and store weather data from multiple sources (REST API and CSV file) into a cloud-based data warehouse, making it ready for visualization. This pipeline is designed to handle both real-time and batch processing, with orchestration and monitoring capabilities for robust, scalable data processing.

## Architecture
Images/WeatherETL Architecture.png

The pipeline follows a layered architecture:
1. **Data Sources**:
   - **OpenWeather API (Hourly)**: Provides real-time weather data through an API.
   - **Historical Weather Data CSV**: Stored in a cloud-based data lake for batch loading.
2. **Data Lake**: Used as a staging area for the CSV file before ingestion into the data warehouse.
3. **Data Warehouse**: Organized into three layers:
   - **Raw Layer**: Stores raw ingested data from both the API and batch sources.
   - **Transformed Layer**: Data is cleaned, normalized, and transformed here for analysis.
   - **Semantic/Gold Layer**: Final, processed data ready for visualization.
4. **Orchestration**: Schedules and coordinates data loads (hourly and batch).
5. **Monitoring**: Provides alerts and failure notifications to ensure the pipeline is running smoothly.
6. **Visualization**: Connects the final semantic layer to Power BI for live and historical reporting.
