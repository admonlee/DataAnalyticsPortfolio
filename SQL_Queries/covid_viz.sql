-- Check tables after importing
SELECT * FROM PortfolioProject..CovidDeaths

SELECT * FROM PortfolioProject..CovidVaccinations

-- Show infection rate for countries
SELECT location, MAX(CAST(total_cases AS BIGINT)) as total_cases, MAX(CAST(total_cases AS BIGINT)*1.0)/AVG(population)*100 as infection_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location

-- Show total case numbers for continents
SELECT continent, SUM(CAST(new_cases AS INT))
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent

-- Calculate rolling death rate
SELECT location, date, total_deaths, total_cases, total_deaths/total_cases*100 AS death_rate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date

-- Get rolling new case count
SELECT location, date, CAST(new_cases AS BIGINT) as new_cases
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date

-- Calculate rolling infection rate
SELECT location, date, CAST(new_cases AS BIGINT)*1.0/CAST(population AS BIGINT)*1000000 AS daily_cases_per_mill
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date

-- Calculate worldwide death rate
SELECT SUM(a.country_cases) AS total_cases, SUM(a.country_deaths) AS total_deaths, SUM(a.country_deaths*1.0)/SUM(a.country_cases)*100 AS death_rate
FROM (SELECT location, MAX(CAST(total_deaths AS BIGINT)) AS country_deaths, MAX(CAST(total_cases AS BIGINT)) AS country_cases
		FROM PortfolioProject..CovidDeaths
		WHERE continent IS NOT NULL
		GROUP BY location) AS a