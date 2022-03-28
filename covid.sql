-- Init to check data
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM `covidproject-345520.CovidProjectTraining.Covid_Deaths`  WHERE continent IS NOT NULL 
ORDER BY location, date;


-- Percentage of dying if you contract Covid
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM `covidproject-345520.CovidProjectTraining.Covid_Deaths`
WHERE location = 'france'
ORDER BY location, date;

-- Max Death Percentage in France ? ~23.9%
SELECT date, (total_deaths/total_cases)*100 as DeathPercentage
FROM `covidproject-345520.CovidProjectTraining.Covid_Deaths`
WHERE location = 'France'
ORDER BY DeathPercentage DESC LIMIT 1;

-- Highest Percentage of population infected by Covid in All Countries
SELECT location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
FROM `covidproject-345520.CovidProjectTraining.Covid_Deaths`
ORDER BY PercentPopulationInfected DESC LIMIT 1;

-- Highest Percentage of population infected by Covid in Each countries
SELECT location, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM `covidproject-345520.CovidProjectTraining.Covid_Deaths`
GROUP BY location
ORDER BY PercentPopulationInfected DESC;

-- Highest number of population who died 
SELECT location, MAX(total_deaths) as MaxDeaths
FROM `covidproject-345520.CovidProjectTraining.Covid_Deaths`
GROUP BY location
ORDER BY MaxDeaths DESC;
-- Not exactly what I meant but we can see how many people died in the world or each continents


-- Highest number of population who died in countries
SELECT location, MAX(total_deaths) as MaxDeaths
FROM `covidproject-345520.CovidProjectTraining.Covid_Deaths`
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY MaxDeaths DESC;
-- USA, Brazil and India

-- Percentage of population who died in countries per Population
SELECT location, MAX(total_deaths) as MaxDeaths, Population, MAX(total_deaths/Population)*100 as DeathPercentage
FROM `covidproject-345520.CovidProjectTraining.Covid_Deaths`
WHERE continent IS NOT NULL
GROUP BY location, Population
ORDER BY DeathPercentage DESC;
-- Peru: 0.64% of its population died

-- Number of population who died in countries per Population by continent
SELECT continent, SUM(TotalDeaths) AS TotalD
FROM 
    (SELECT location, continent, MAX(total_deaths) as TotalDeaths
    FROM `covidproject-345520.CovidProjectTraining.Covid_Deaths`
    GROUP BY location, continent
    )
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalD DESC;
-- These results are pretty close to what we get before by using location = continent
