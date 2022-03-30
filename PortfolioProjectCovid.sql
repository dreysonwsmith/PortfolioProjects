SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

--SELCT data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1, 2

--Looking at total cases vs total deaths
--Shows the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from PortfolioProject..CovidDeaths
WHERE location like 'United States'
WHERE continent is not null
order by 1, 2


--Looking at total cases vs population
--Shows what percentage of the population has gotten covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentOfPopulationInfected
from PortfolioProject..CovidDeaths
WHERE location like 'United States'
order by 1, 2

--Looking at countries with highest infection rates compared to the population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 
AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
--WHERE location like 'United States'
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing Countries with the highest death count per population.

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE location like 'United States'
WHERE continent is not null
Group by Location
order by TotalDeathCount desc

--Let's look at the numbers by continent 

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE location like 'United States'
WHERE continent is not null
Group by continent
order by TotalDeathCount desc

--Showing the continent with the highest death count

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE location like 'United States'
WHERE continent is not null
Group by continent
order by TotalDeathCount desc

--Global numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) as DeathPercentage
from PortfolioProject..CovidDeaths
--WHERE location like 'United States'
WHERE continent is not null
--GROUP BY date
order by 1, 2


Select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

--Looking at toal population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location
dea.date) as RollingPeopleVaccinated,
--,(RollingPeopleVaccinated/Population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
)
--Use CTE

With PopvsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT*, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--Temp table

Drop Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

SELECT*, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--Creating view to store date for later visualizations

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
