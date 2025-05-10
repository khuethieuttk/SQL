use portfolio;

SELECT *
FROM covid_death
ORDER BY 3,4;

-- Data that will be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_death
ORDER BY 1,2;

-- Total cases vs total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS death_percentage
FROM covid_death
ORDER BY 1,2;

	-- In US
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS death_percentage
FROM covid_death
WHERE location LIKE '%States%'
ORDER BY 1,2;

-- Total cases vs population

SELECT location, date, total_cases, population, (total_cases / population)*100 AS case_percentage
FROM covid_death
ORDER BY 1,2;

	-- In US
SELECT location, date, total_cases, population, (total_cases / population)*100 AS case_percentage
FROM covid_death
WHERE location LIKE '%States%'
ORDER BY 1,2;

-- Countries with highest infection rate compared to population

SELECT location, date, MAX(total_cases) AS highest_infection_count, MAX((total_cases / population)*100) AS population_infected_percentage
FROM covid_death
GROUP BY location, population
ORDER BY 4 DESC;

-- Countries with highest death count per population

SELECT location, date, MAX(total_deaths) AS highest_death_count
FROM covid_death
WHERE continent != ''
GROUP BY location
ORDER BY highest_death_count DESC;

	-- Break down by continent
SELECT continent, MAX(total_deaths) AS highest_death_count
FROM covid_death
WHERE continent != ''
GROUP BY continent
ORDER BY highest_death_count DESC;

-- Global numbers

SELECT date, SUM(new_cases)
FROM covid_death
GROUP BY date
ORDER BY date;

	-- Infection_percentage
SELECT date, SUM(new_cases) AS total_cases_global, SUM(new_cases/population) AS infection_percentage_global
FROM covid_death
GROUP BY date
ORDER BY date;

	-- Death_percentage
SELECT date, SUM(new_cases) AS total_cases_global, SUM(new_deaths) AS death_count_global, SUM(new_deaths/population) AS death_percentage_global
FROM covid_death
GROUP BY date
ORDER BY date;

SELECT SUM(new_cases) AS total_cases_global, SUM(new_deaths) AS death_count_global, SUM(new_deaths/population) AS death_percentage_global
FROM covid_death
ORDER BY 1,2;

-- Looking at covid_vaccination

SELECT * 
FROM covid_vaccination
GROUP BY 3,4;

-- Total population vs vaccination

SELECT d.continent, d.location, d.date, population, v.new_vaccinations
FROM covid_death AS d
JOIN covid_vaccination AS v
ON d.location = v.location AND d.date = v.date 
WHERE d.continent != ''
ORDER BY 2,3
LIMIT 500;

	-- Break down by location
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (partition by d.location ORDER BY d.location, d.date) AS total_vaccination_by_countries
FROM covid_death AS d
JOIN covid_vaccination AS v
ON d.location = v.location AND d.date = v.date
WHERE d.continent != ''
ORDER BY 2,3;

WITH population_vs_vaccination (continent, location, date, population, new_vaccinations, total_vaccination_by_countries)
AS (
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (partition by d.location ORDER BY d.location, d.date) AS total_vaccination_by_countries
FROM covid_death AS d
JOIN covid_vaccination AS v
ON d.location = v.location AND d.date = v.date
WHERE d.continent != ''
ORDER BY 2,3
)
SELECT * , (total_vaccination_by_countries/population)*100 AS vaccinations_percentage
FROM population_vs_vaccination;

-- Temp table

CREATE TABLE percentage_population_vaccinated
(continent varchar(100),
location varchar(100),
date date,
population numeric,
new_vaccinations numeric,
total_vaccination_by_countries numeric);

INSERT INTO percentage_population_vaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (partition by d.location ORDER BY d.location, d.date) AS total_vaccination_by_countries
FROM covid_death AS d
JOIN covid_vaccination AS v
ON d.location = v.location AND d.date = v.date;

SELECT *, (total_vaccination_by_countries/population)*100 AS vaccinations_percentage
FROM population_vs_vaccination;

-- Create view to store data for later

CREATE VIEW percentage_population_vaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (partition by d.location ORDER BY d.location, d.date) AS total_vaccination_by_countries
FROM covid_death AS d
JOIN covid_vaccination AS v
ON d.location = v.location AND d.date = v.date
WHERE d.continent != '';

SELECT *
FROM percentage_population_vaccinated;