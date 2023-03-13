/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-- Total Cases vs Total Deaths
-- Likelihood of dying if contract Covid 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths
Where location = 'India'
Order by 1,2

-- Total Cases vs Population
-- Percentage of population contracted covid
Select Location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
from dbo.CovidDeaths
Where location = 'Canada'
Order by 1,2

-- Countries with highest Infection rate compared to population
Select Location, population, Max(total_cases) as HighestInfectionCount,  Max((total_cases/population)*100) as PercentPopulationInfected
from dbo.CovidDeaths
Group by location, population
Order by PercentPopulationInfected desc

-- Total Death count by continent
Select location, max(cast(total_deaths as int)) as TotalDeathCount 
from dbo.CovidDeaths
Where continent is Null
Group by location
Order by TotalDeathCount desc

-- Continents with the highest death per population
Select continent, max(cast(total_deaths as int)) as TotalDeathCount 
from dbo.CovidDeaths
Where continent is not Null
Group by continent
Order by TotalDeathCount desc

-- Global numbers
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from dbo.CovidDeaths
Where continent is not null
group by date
Order by 1,2

-- Global Death rate
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from dbo.CovidDeaths
Where continent is not null
Order by 1,2

-- Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location,
dea.date) as Rollingpeoplevaccinated
From dbo.CovidDeaths  dea
Join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

-- Use CTE 
With PopvsVac(Continent, Location, Date, Population, New_vaccinations,RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location,
dea.date) as Rollingpeoplevaccinated
From dbo.CovidDeaths  dea
Join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp table
Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
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
sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location,
dea.date) as Rollingpeoplevaccinated
From dbo.CovidDeaths  dea
Join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 