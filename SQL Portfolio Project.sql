SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4




--select the data I will be analysing

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2




-- Looking at Total Cases VS Total Deaths
-- Shows the probability of dying if you get Covid in the UK

ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths float

ALTER TABLE CovidDeaths
ALTER COLUMN total_cases float

ALTER TABLE CovidDeaths
ALTER COLUMN new_cases float

ALTER TABLE CovidDeaths
ALTER COLUMN new_deaths float

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%united%kingdom%'
AND continent IS NOT NULL
ORDER BY 1,2




-- Looking at Total Cases VS Population
-- Shows the perecentage of UK population who got Covid

SELECT location, date, Population, total_cases, (total_cases/Population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%united%kingdom%'
AND continent IS NOT NULL
ORDER BY 1,2




-- Looking at Highest Infection Count compared to Populations

SELECT location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population)) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%united%kingdom%'
WHERE continent IS NOT NULL
GROUP BY location, Population
ORDER BY PercentPopulationInfected DESC




-- Looking at Highest Infection Count compared to Populations (BY CONTINENT)

SELECT continent, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population)) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%united%kingdom%'
WHERE continent IS NOT NULL
GROUP BY continent, Population
ORDER BY PercentPopulationInfected DESC




-- Showing Countries with Highest Death Count per Population 

SELECT location,  MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%united%kingdom%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC




-- Showing Countries with Highest Death Count per Population (BY CONTINENT)

SELECT continent,  MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%united%kingdom%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC




-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/NULLIF(SUM(new_cases),0) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%united%kingdom%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2




-- GLOBAL NUMBERS (TOTAL)

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/NULLIF(SUM(new_cases),0) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%united%kingdom%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2




--Looking at Total Vaccinations VS Population

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
dea.date) as RollingPeopleVaccinated, --(RollingPeopleVaccinated/population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3




-- USE CTE

WITH PopvsVac (Continent, date, location, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/population) * 100
FROM PopvsVac




-- Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population) * 100
FROM #PercentPopulationVaccinated




-- Creating View to store data for later visualisations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population) * 100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated