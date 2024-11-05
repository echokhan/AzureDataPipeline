
# Dashboard Purpose

The purpose of this dashboard is to provide a comprehensive and user-friendly tool for monitoring weather data in real-time while allowing for comparisons with historical weather patterns. By integrating live hourly data from an API with historical data from a CSV bulk load source containing 9 years of weather data for 3 cities, the dashboard enables users to view current weather conditions and trends over time, supporting both situational awareness and data-driven decision-making. The inclusion of forecasting, trend analysis, and summary metrics provides users with actionable insights, whether they need to plan for upcoming weather events or analyze past weather impacts. This design prioritizes interactivity, flexibility, and clarity, making it an effective solution for users to easily interpret past, present, and future data.

# Data Model Enrichment

I started by working on the latest data. Since it was time series data, I enriched the model by extracting additional features such as `year`, `month_name`, `week_of_year`, and `name_of_day`. These features allow for more granular filtering and analysis over time.

# Real-Time Data Cards

For the live data or hourly weather view, I created cards to display the latest metrics, including temperature, humidity, and wind speed, each with the correct units. To ensure that these cards only display data from the latest available hour, I created a calculated column called `LatestTimestampFlag`. This column flags the record with the maximum `date_time` value as `1` and all others as `0`. By filtering the live weather data cards with `LatestTimestampFlag=1`, only the most recent data is displayed.

The `Date Time` column was a custom column created by merging `date_only` and `time_only`, allowing for the creation of a time series hierarchy. Additionally, I created another flag calculated column, `IsCurrentDay`, to identify the latest day's records. This flag was used to filter records for cards displaying maximum and minimum temperature for the current day.

# City Slicer

A slicer was implemented to filter the dashboard data based on the 3 cities available. This allows users to switch between cities and view the weather data specific to each location.

# Rolling Average

A measure for the 7-day rolling average was created to smooth out daily fluctuations in temperature, providing a clearer picture of overall temperature trends over the past week.

# Tabular Data View

Tabular data is displayed beneath the live weather cards, allowing users to view recent weather data in a tabular format for easier comparison and analysis.

# Historical Data and Time Series Filtering

For historical data, slicers based on time series features such as `year`, `month`, `day`, and `date` allow for comparison of temperature vs. feels-like measures, as well as wind speed, across different time periods. I was particularly interested in comparing today’s temperature with the same day from previous years. Using Power BI's drill-down feature, I can explore historical data across different time dimensions, such as quarter, week, and month.

# Interaction Customization

To ensure that historical slicers do not affect the live weather data cards, I used Power BI's "Edit Interactions" feature to control how each slicer affects different visuals on the dashboard.

# Forecasting

A forecasting attempt was made using Power BI's built-in forecasting tool. However, I recommend using more sophisticated tools, such as **XGBoost** or **FbProphet**, which could be integrated into this dashboard for more accurate forecasting.

# Map Visualization

A map visualization was added to compare average temperatures between cities, giving users a geographical overview of temperature variations.

# Reset Button with Bookmark Action

I discovered an interesting feature that allows the addition of a button with a bookmark action. This button returns all visualizations to their original state after any changes, providing a quick reset option for users.
