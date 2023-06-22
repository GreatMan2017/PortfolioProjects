
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4



Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2



-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%states%' and continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, population, total_cases, (CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
-- Where Location like '%states%'
Where continent is not null
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(CAST(total_cases AS FLOAT) / CAST(population AS FLOAT) * 100) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
-- Where Location like '%states%'
Where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc



-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where Location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where Location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your continent

Select continent, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid in your continent

Select continent, date, population, total_cases, (CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
-- Where Location like '%states%'
Where continent is not null
order by 1,2


-- Looking at Continents with Highest Infection Rate compared to Population
Select continent, MAX(population) AS population, MAX(total_cases) as HighestInfectionCount, MAX(CAST(total_cases AS FLOAT) / CAST(population AS FLOAT) * 100) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by PercentPopulationInfected desc


-- GLOBAL NUMBERS

Select /*date,*/ SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
Where continent is not null and new_cases != 0
--Group By date
order by 1,2



-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- Looking at Total Population vs Vaccinations
-- USE CTE

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



-- TEMP TABLE

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



-- Creating View to store data for later visualizations

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