### 1. Raw Layer
- **Tables**:
  - `raw.hourly_weatherdata`: This table stores data ingested directly from the OpenWeather API on an hourly basis. Key fields include `id`, `dt` (timestamp), `lat` (latitude), `lon` (longitude), and `temp` (temperature), along with other weather metrics collected from the API.
  - `raw.batch_weatherdata`: This table stores historical weather data ingested from a CSV file in batch mode. It includes similar fields to `raw.hourly_weatherdata` but also has `city_name` for easy identification and mapping to the `dim.city` table.
- **Purpose**: The raw layer preserves the original data as it is ingested from external sources, ensuring data fidelity. It serves as the source of truth for any future re-processing or auditing.

### 2. Dimensional Table (`dim.city`)
- **Table**:
  - `dim.city`: This is a reference table containing metadata about cities, specifically `city_name`, `lat`, and `lon`. This table is populated with unique city records from the `raw.batch_weatherdata` table via an upsert operation (`uspUpsertDimCity`).
- **Purpose**: The `dim.city` table enriches the raw data by associating each weather record with a specific city. This enables joins with hourly raw data in the transformation layer, allowing for city-based data encrichment for live/hourly data.

### 3. Transformed Layer
- **Table**:
  - `transformed.weatherdata`: This table stores the cleansed, enriched, and normalized data ready for further processing. It contains fields like `date_only`, `time_only`, `city_name`, `latitude`, `longitude`, `temp`, and other weather metrics. The table is populated by merging data from `raw.hourly_weatherdata` and `raw.batch_weatherdata` with city information from `dim.city`.
- **Transformation Process**:
  - Upsert operations (`uspBatchUpsertTransformedWeatherData` and `uspHourlyUpsertTransformedWeatherData`) integrate data from raw tables with `dim.city`. Data transformations include extracting date and time components, normalizing temperature units if necessary, and handling missing values.
- **Purpose**: This layer standardizes data and enriches it with city metadata. It also acts as an intermediary stage, preparing data for the semantic layer by ensuring consistency and data quality.

### 4. Semantic Layer
- **Table**:
  - `semantic.weatherdata`: This is the final, reporting-ready table. Key fields include `date_only`, `time_only`, `city_name`, `latitude`, `longitude`, `temperature_celsius`, and other weather metrics.
- **Transformation Process**:
  - A truncate-insert operation (`uspTruncateInsertSemanticWeatherData`) is performed to populate this table from `transformed.weatherdata`, ensuring only the latest processed data is available for reporting.
- **Purpose**: The semantic layer holds clean, finalized data optimized for analysis and reporting. This table is connected to Power BI, enabling stakeholders to visualize key metrics, trends, and insights without querying the underlying tables directly.

### Stored Procedures Used in Data Flow
- **uspUpsertDimCity**: Used to populate and update records in `dim.city` based on unique city names and coordinates in `raw.batch_weatherdata`.
- **uspBatchUpsertTransformedWeatherData**: Integrates data from `raw.hourly_weatherdata` and `raw.batch_weatherdata` into `transformed.weatherdata` after cleaning and enrichment.
- **uspTruncateInsertSemanticWeatherData**: Truncates and reloads the data in `semantic.weatherdata` to ensure the reporting layer contains only the latest processed data from the transformed layer.

### Data Model Flow
1. **Raw Data Ingestion**: Data is loaded into `raw.hourly_weatherdata` from the API and into `raw.batch_weatherdata` from the historical CSV file.
2. **City Dimension Enrichment**: Cities are uniquely identified and stored in `dim.city`, providing a clean reference table for city-related information.
3. **Transformation and Cleansing**: Data from the raw layer is joined with `dim.city` and processed to populate `transformed.weatherdata`, ensuring consistency in structure and values.
4. **Final Reporting Layer**: The semantic layer’s `semantic.weatherdata` table is populated, ready for use in Power BI dashboards for real-time and historical reporting.

