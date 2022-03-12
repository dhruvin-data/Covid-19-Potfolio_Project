SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is not null
order by 1, 2;

--Looking at Total Cases vs. Total Deaths
--Likelihood of dying if you get infected with Covid in India
SELECT location, date, total_cases, total_deaths, Round((total_deaths/ total_cases)*100, 2) as Death_Percentage
FROM CovidDeaths
WHERE location = 'India'
order by 1, 2 desc;

--Looking at Total Cases vs. Population
SELECT location, date, population, total_cases, Round((total_cases/ population)*100, 2) AS Infection_Rate
FROM CovidDeaths
WHERE location = 'India'
order by 1, 2 desc;

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, ROUND(MAX(total_cases/population)*100, 2) AS Highest_Infection_Rate
FROM CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY Highest_Infection_Rate desc;

SELECT location, MAX(CAST(total_deaths AS int)) as Deaths
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY Deaths DESC;

--BREAKING THINGS BY CONTINENT
--Showing the continents with the highest death per population
SELECT continent, MAX(CAST(total_deaths AS int)) as Total_Deaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Deaths DESC;

--GLOBAL NUMBERS
SELECT SUM(new_cases) AS TOTAL_CASES, SUM(CAST(new_deaths AS int)) AS TOTAL_DEATHS, ROUND(SUM(CAST(new_deaths AS int))/SUM(new_cases)*100, 2) AS Death_Rate
FROM CovidDeaths
Where continent IS NOT NULL
ORDER BY 1, 2;

SELECT * 
FROM CovidVaccinations;

SELECT * 
FROM CovidDeaths AS cd
JOIN CovidVaccinations AS cv
ON cd.location = cv.location
AND cd.date = cv.date

--Total Population vs Vaccinations

With PopVsVac(Continent, Location, Date, Population, New_Vaccinations, Number_Of_Vaccinations_Till_Date)
AS(
SELECT cd.continent, cd.location, cd.date, cd.population, new_vaccinations, SUM(CAST(new_vaccinations AS int)) OVER(Partition BY cd.location ORDER BY cd.location, cd.date) AS Number_Of_Vaccinations_Till_Date
FROM CovidDeaths AS cd
JOIN CovidVaccinations AS cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE total_vaccinations is not null 
AND cd.continent is not null
--ORDER BY 2, 3
)
SELECT *, ROUND((Number_Of_Vaccinations_Till_Date/Population)*100, 2) AS Rate_Of_Vaccination
FROM PopVsVac;

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPeopleVaccination
CREATE TABLE #PercentPeopleVaccination(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Number_Of_Vaccinations_Till_Date numeric)

INSERT INTO #PercentPeopleVaccination
SELECT cd.continent, cd.location, cd.date, cd.population, new_vaccinations, SUM(CAST(new_vaccinations AS int)) OVER(Partition BY cd.location ORDER BY cd.location, cd.date) AS Number_Of_Vaccinations_Till_Date
FROM CovidDeaths AS cd
JOIN CovidVaccinations AS cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE total_vaccinations is not null 
AND cd.continent is not null
ORDER BY 2, 3

SELECT *, ROUND((Number_Of_Vaccinations_Till_Date/Population)*100, 2) AS Rate_Of_Vaccination
FROM #PercentPeopleVaccination;

--Creating a View's to store data for later data visualisations
CREATE VIEW PercentPopulationVaccinated AS
SELECT cd.continent, cd.location, cd.date, cd.population, new_vaccinations, SUM(CAST(new_vaccinations AS int)) OVER(Partition BY cd.location ORDER BY cd.location, cd.date) AS Number_Of_Vaccinations_Till_Date
FROM CovidDeaths AS cd
JOIN CovidVaccinations AS cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE total_vaccinations is not null 
AND cd.continent is not null
--ORDER BY 2, 3

SELECT location, population, date, MAX(total_cases) AS Highest_Infection_Count, ROUND(MAX(total_cases/population)*100, 2) AS Highest_Infection_Rate
FROM CovidDeaths
WHERE continent is not null
GROUP BY location, population, date
ORDER BY Highest_Infection_Rate desc;