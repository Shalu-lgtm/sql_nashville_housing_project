# sql_nashville_housing_project
Data Cleaning and Transformation
Table Renaming:

Renamed the table to nashville_housing.
Date Handling:

Added columns for month_name, year, and day to parse the SaleDate.
Converted SaleDate to a date_transformed column and dropped unnecessary columns.
Standardization:

Standardized PropertyAddress into Property_city, property_house_number, and property_area.
Corrected SoldAsVacant values and normalized various columns.
Feature Engineering:

Created total_rooms by summing Bedrooms, FullBath, and HalfBath.
Added land_area_category to categorize the Acreage into bins.
Data Cleanup:

Removed duplicate records using CTEs and row numbers.
Created a view new_nashville with cleaned data.
Analysis
Demand Analysis:

Analyzed the change in housing demand city-wise and land-use-wise over years.
Calculated percentage change in demand for each city and land-use category.
Land Use and Value Analysis:

Examined the relationship between land area categories, land use, and land values.
Created categorical ranges for LandValue and BuildingValue.
Spatial Analysis:

Explored city-wise and area-wise distribution of land values and building values.
Investigated the preference for different land use and value ranges across cities.
Time Series Analysis:

Analyzed yearly trends in housing demand and value changes.
Compared demand changes across different cities and land uses.
Observations:
Popular Cities: Madison, Old Hickory, and Goodsville have been frequently mentioned, indicating their significance in the housing market.
Land Use Preferences: Single-family homes dominate, followed by duplexes and zero-lot line properties. Preferences vary by city and land area category.
Value Analysis: The average total values differ by city, land area category, and land use, which helps in understanding market dynamics and trends.
Suggestions:
Refine Analysis:

Further break down categories where high variability is observed to understand market segments better.
Visualizations:

Create visualizations for better insights into the trends and distributions, such as heat maps or time series graphs.
Additional Analysis:

Consider incorporating external factors such as economic conditions or demographic changes to enhance the analysis.
