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


-- NEW CASES & NEW Deaths
-- Evolution of infections day by day
SELECT date, SUM(new_cases) AS Total_New_Cases_Per_Day, SUM(new_deaths) AS Total_New_Deaths_Per_Day
FROM `covidproject-345520.CovidProjectTraining.Covid_Deaths`
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

-- Evolution of infections day by day by Country
SELECT date, location, SUM(new_cases) AS Total_New_Cases_Per_Day, SUM(new_deaths) AS Total_New_Deaths_Per_Day
FROM `covidproject-345520.CovidProjectTraining.Covid_Deaths`
WHERE continent IS NOT NULL
GROUP BY date,  location
ORDER BY date;


## Using Vax table
-- New vaccinations
SELECT death.location, death.continent, death.date, death.population, vax.new_vaccinations
FROM `covidproject-345520.CovidProjectTraining.Covid_Deaths` death
JOIN `covidproject-345520.CovidProjectTraining.Covid_Vax` vax
ON death.location = vax.location AND death.date = vax.date
ORDER BY location, date


-- Some improvements to see cumulated vaccinations
WITH VaccinatedPop AS 
(SELECT death.location, death.continent, death.date, death.population, vax.new_vaccinations, SUM(new_vaccinations) 
OVER (PARTITION BY  death.location ORDER BY death.location, death.date) AS Cumulated_Vaccinations,
FROM `covidproject-345520.CovidProjectTraining.Covid_Deaths` death
JOIN `covidproject-345520.CovidProjectTraining.Covid_Vax` vax
ON death.location = vax.location AND death.date = vax.date
WHERE death.continent IS NOT NULL
ORDER BY location, date) 

--SELECT * FROM VaccinatedPop ;
-- If we want to see percentage of vaccinated population :
SELECT location, continent, date,ROUND((Cumulated_Vaccinations/Population)*100, 2) FROM VaccinatedPop ;


-- Date of first vaccination for each country 
WITH VaccinatedPop AS 
(
    SELECT death.location, death.continent, death.date, death.population, vax.new_vaccinations, SUM(new_vaccinations) 
    OVER (PARTITION BY  death.location ORDER BY death.location, death.date) AS Cumulated_Vaccinations,
    FROM `covidproject-345520.CovidProjectTraining.Covid_Deaths` death
    JOIN `covidproject-345520.CovidProjectTraining.Covid_Vax` vax
    ON death.location = vax.location AND death.date = vax.date
    WHERE death.continent IS NOT NULL
    ORDER BY location, date
), VaxPercent AS
(
    SELECT location, 
        continent, 
        date, 
        new_vaccinations,
        ROW_NUMBER() OVER(PARTITION BY location ORDER BY date ASC) AS rank
    FROM VaccinatedPop
    WHERE new_vaccinations IS NOT NULL AND new_vaccinations > 0
)
SELECT *
FROM VaxPercent
WHERE rank = 1
ORDER BY date

-- Test of creation of TEMP table
CREATE TEMP TABLE PercentPopulationVaccinated
(
location STRING(255),
continent STRING(255),
date DATE,
Population numeric,
new_vaccinations numeric,
Cumulated_Vaccinations numeric
) AS 

SELECT death.location, death.continent, death.date, CAST(death.population AS NUMERIC), CAST(vax.new_vaccinations AS NUMERIC), SUM(CAST(vax.new_vaccinations AS NUMERIC)) 
OVER (PARTITION BY  death.location ORDER BY death.location, death.date) AS Cumulated_Vaccinations
FROM `covidproject-345520.CovidProjectTraining.Covid_Deaths` death
JOIN `covidproject-345520.CovidProjectTraining.Covid_Vax` vax
ON death.location = vax.location AND death.date = vax.date
ORDER BY location, date;

-- Perform same request than before with our Temps table
SELECT location, continent, date, population, ROUND((Cumulated_Vaccinations/Population)*100, 2) AS Percent_Vaxed
FROM PercentPopulationVaccinated;


-- Same but using View
CREATE VIEW `covidproject-345520.CovidProjectTraining.PercentPopulationVaccinated2` 
(
location,
continent,
date,
Population,
new_vaccinations,
Cumulated_Vaccinations
) AS 
SELECT death.location, death.continent, death.date, CAST(death.population AS NUMERIC), CAST(vax.new_vaccinations AS NUMERIC), SUM(CAST(vax.new_vaccinations AS NUMERIC)) 
OVER (PARTITION BY  death.location ORDER BY death.location, death.date) AS Cumulated_Vaccinations
FROM `covidproject-345520.CovidProjectTraining.Covid_Deaths` death
JOIN `covidproject-345520.CovidProjectTraining.Covid_Vax` vax
ON death.location = vax.location AND death.date = vax.date
ORDER BY location, date;

