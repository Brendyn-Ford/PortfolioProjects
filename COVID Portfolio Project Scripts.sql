Select *
From PortfolioProjects.dbo.CovidDeaths
Where continent is not null
Order By 3,4

-- I am going to select the data that I will be using
Select
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
From PortfolioProjects.dbo.CovidDeaths
Order By 1,2

-- Looking at Total Cases vs Total Deaths and likelihood of dying if you contract covid in your country
Select
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProjects.dbo.CovidDeaths
Where location like '%states%'
Order By 1,2


-- Looking at Total Cases vs Population and shows what percentage of population got covid
Select
	location,
	date,
	population,
	total_cases,
	(total_cases/population)*100 AS PercentPopulationInfected
From PortfolioProjects.dbo.CovidDeaths
Where location like '%states%'
Order By 1,2


-- Looking at Countries with Highest Infection Rate compared to Population
Select
	location,
	population,
	MAX(total_cases) AS HighestInfectionCount,
	MAX((total_cases/population))*100 AS PercentPopulationInfected
From PortfolioProjects.dbo.CovidDeaths
Where continent is not null
Group by location,population
Order By PercentPopulationInfected desc


-- Showing the Countries with Highest Death Count per Population. Had to cast total_deaths because of its data type.
Select
	location,
	MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProjects.dbo.CovidDeaths
Where continent is not null
Group by location
Order By TotalDeathCount desc


-- Showing the continents with the hightest death count
Select
	continent,
	MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProjects.dbo.CovidDeaths
Where continent is not null
Group by continent
Order By TotalDeathCount desc


-- These are global numbers
Select
	date,
	SUM(new_cases) AS TotalCases,
	SUM(cast(new_deaths as int)) AS TotalDeaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProjects..CovidDeaths
Where continent is not null
Group By date
Order By 1,2


-- Looking at data from other table
Select *
From PortfolioProjects..CovidVaccinations


-- Joining the two tables
Select *
From PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac 
	ON dea.location = vac.location
	and dea.date = vac.date


-- Looking at Total Population vs Vaccination
Select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) As RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac 
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3


-- Using CTE for the RollingPeopleVaccinated/Population calculated field
With PopvsVac (Continet, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(Select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) As RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac 
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3 
)
Select *,
(RollingPeopleVaccinated/Population)*100 As PercentagePopulationVaccinated
From PopvsVac


-- Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) As RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac 
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3 

Select *,
(RollingPeopleVaccinated/Population)*100 As PercentagePopulationVaccinated
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations
Create View PercentagePopulationVaccinated As
Select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location, dea.date) As RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac 
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3 