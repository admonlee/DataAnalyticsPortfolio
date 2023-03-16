/*
In this project, we explore data on EV ownership in Florida.

EV registration data provided by Florida Power and Light https://www.atlasevhub.com/materials/state-ev-registration-data/
Alternative fuel stations data by US government https://catalog.data.gov/dataset/alternative-fueling-station-locations-422f2/resource/341957d8-daf6-4a38-ab1d-8ec1bc21cfb9
Data as of July 2021
*/

-- Data cleaning and initial manipulation
-- Check data after importing
SELECT * FROM PortfolioProject..alt_fuel_stations

SELECT * FROM PortfolioProject..fl_ev_registrations

-- Check for fuel station table for missing location data
SELECT * 
FROM PortfolioProject..alt_fuel_stations
WHERE Latitude IS NULL OR Longitude IS NULL OR State IS NULL

-- Check EV registration table for missing county or vehicle data
SELECT *
FROM PortfolioProject..fl_ev_registrations
WHERE County IS NULL OR [Vehicle Name] IS NULL

-- Check for duplicates in alt fuel table
SELECT ID, COUNT(*)
FROM PortfolioProject..alt_fuel_stations
GROUP BY ID
HAVING COUNT(*) > 1

-- Replace 'Saint' with 'St.' in the cities table
UPDATE PortfolioProject..fl_cities
SET [City Name] = REPLACE([City Name], 'Saint', 'St.')

-- Replace 'Fort' with 'Ft.' in the cities table
UPDATE PortfolioProject..fl_cities
SET [City Name] = REPLACE([City Name], 'Fort', 'Ft.')

-- Replace 'St ' with 'St. ' in alt fuels table
UPDATE PortfolioProject..alt_fuel_stations
SET City = REPLACE(City, 'St ', 'St. ')
WHERE State = 'FL'

-- Replace 'Ft ' with 'Ft. ' in alt fuels table
UPDATE PortfolioProject..alt_fuel_stations
SET City = REPLACE(City, 'Ft ', 'Ft. ')
WHERE State = 'FL'

-- Split vehicle name into make and model
ALTER TABLE PortfolioProject.dbo.fl_ev_registrations
ADD Make VARCHAR(255)

ALTER TABLE PortfolioProject.dbo.fl_ev_registrations
ADD Model VARCHAR(255)


UPDATE PortfolioProject..fl_ev_registrations
SET Make = LEFT([Vehicle Name], CHARINDEX(' ', [Vehicle Name]) - 1)

UPDATE PortfolioProject..fl_ev_registrations
SET Model = SUBSTRING([Vehicle Name] ,PATINDEX('% %',[Vehicle Name]), LEN([Vehicle Name]))

-- Add county name for cities in Florida
ALTER TABLE PortfolioProject..alt_fuel_stations
ADD County VARCHAR(255)

UPDATE PortfolioProject..alt_fuel_stations 
SET County = [County Name]
FROM PortfolioProject..alt_fuel_stations
JOIN PortfolioProject..fl_cities
ON City = [City Name]
WHERE State = 'FL'

-- Rename 'Dade' to 'Miami-Dade' in EV Registrations table
UPDATE PortfolioProject..fl_ev_registrations
SET County = 'Miami-Dade'
WHERE County = 'Dade'

-- Data Exploration
-- Select EV charging stations in Florida
SELECT [Fuel Type Code], [Station Name], City, County, State, ZIP, Latitude, Longitude
FROM PortfolioProject..alt_fuel_stations
WHERE [Fuel Type Code] = 'ELEC' AND State = 'FL'
ORDER BY County

-- Count total EV charging stations in Florida
SELECT COUNT(*) AS 'EV Stations'
FROM PortfolioProject..alt_fuel_stations
WHERE [Fuel Type Code] = 'ELEC' AND State = 'FL'

-- Count total EV charging stations in Florida by County
SELECT 'Florida' AS State, County, COUNT(*) AS 'EV Stations'
FROM PortfolioProject..alt_fuel_stations
WHERE [Fuel Type Code] = 'ELEC' AND State = 'FL'
GROUP BY County

-- Count total EV registrations in Florida
SELECT COUNT(*) AS 'EV Registrations'
FROM PortfolioProject..fl_ev_registrations

-- Count total EV registrations in Florida by County
SELECT 'Florida' AS State, County, COUNT(*) AS 'EV Registrations'
FROM PortfolioProject..fl_ev_registrations
GROUP BY County