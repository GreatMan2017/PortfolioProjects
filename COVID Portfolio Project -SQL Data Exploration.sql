/*
Exploring Covid-19 Data

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4


-- Retrieve the initial set of data that we will be working with.

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2



-- Examining the correlation between the total number of Covid cases and total number of deaths
-- Providing insight into the mortality risk associated with contracting Covid in different countries.

Select Location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Analyzing the relationship between the total number of Covid cases and the population size
-- Revealing the proportion of the population affected by Covid

Select Location, date, population, total_cases, (CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(CAST(total_cases AS FLOAT) / CAST(population AS FLOAT) * 100) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
-- Where Location like '%states%'
Where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc



-- Displaying countries with the highest death count in relation to their respective populations.

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where Location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- Let's categorize the data based on continents for a detailed analysis.



-- Displaying continents with the highest death count in relation to their respective populations.

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- Analyzing the relationship between the total number of Covid cases and total number of deaths.
-- Illustrating the probability of mortality if an individual contracts Covid within their respective continent.

Select continent, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Examining the relationship between the total number of Covid cases and the population size.
-- Revealing the percentage of the population that has been affected by Covid within a specific continent.

Select continent, date, population, total_cases, (CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Analyzing continents with the highest infection rates in relation to their respective populations.
Select continent, MAX(population) AS population, MAX(total_cases) as HighestInfectionCount, MAX(CAST(total_cases AS FLOAT) / CAST(population AS FLOAT) * 100) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by PercentPopulationInfected desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2



-- Examining the relationship between the total population and the number of vaccinations administered

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- Analyzing the correlation between the total population and the number of vaccinations administered.
-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 AS 'RollingPeopleVaccinated per Population'
From #PercentPopulationVaccinated



-- Creating a view to store the data for futue visualizations and analysis.

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
