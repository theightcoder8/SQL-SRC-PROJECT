-- Select Data that we are going to be using
/*
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidPortfolioProject..CovidDeaths$
ORDER BY 1,2
*/


-- What percentage of population go Covid
/*
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM CovidPortfolioProject..CovidDeaths$
WHERE total_deaths > 100
--or if you want only US -> WHERE location LIKE 'states'
ORDER BY death_percentage DESC
*/


-- Looking at Countries with highest infection rate compared to Population
/*
SELECT location, population, MAX(total_cases) AS highest_infection_rate, MAX(total_cases/population) * 100 AS percent_population_infected
FROM CovidPortfolioProject..CovidDeaths$
GROUP BY location, population
ORDER BY percent_population_infected DESC
*/


-- Showing Countries with Highest Death Count
/*
SELECT location, MAX(cast(total_deaths AS int)) AS total_death_count
FROM CovidPortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC
*/


-- Showing Continents with Highest Death Count
/*
SELECT location, MAX(cast(total_deaths AS int)) AS total_death_count
FROM CovidPortfolioProject..CovidDeaths$
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC
*/


-- Total Death Percentage of Covid
/*
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_death, SUM(CAST(new_deaths as int))/SUM(New_Cases)*100 AS new_death_percentage
FROM CovidPortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
*/


-- Shows Percentage of Population that has recieved at least one Covid Vaccine
/*
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
			SUM(CONVERT(int, vac.new_vaccinations)) 
			OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
			--, (rolling_people_vaccinated / population)*100 We can't use rolling_people_vaccinated as we use it before. So we are gonna use CTE
FROM AlexFrebergCovidPortfolioProject..CovidDeaths$ dea
JOIN AlexFrebergCovidPortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3
*/

-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From AlexFrebergCovidPortfolioProject..CovidDeaths$ dea
Join AlexFrebergCovidPortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


