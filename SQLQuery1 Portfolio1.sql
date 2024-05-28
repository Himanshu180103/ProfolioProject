Select *
From Portfolio_project..CovidDeaths
Order by 3,4

Select location,date, total_cases, new_cases, total_deaths, population
From Portfolio_project..CovidDeaths
Order by 1,2

-- Looking at total cases vs total deaths

Select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_project..CovidDeaths
Where location like '%states%' 
Order by 1,2

-- Looking at total cases vs population
-- Shows % of population who got covid

Select location,date, total_cases, population, (total_cases/population)*100 as CovidPercentage
From Portfolio_project..CovidDeaths
Where location like '%states%' 
Order by 1,2

-- Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CovidPercentage
From Portfolio_project..CovidDeaths
-- Where location like '%states%' 
Group by location, population
Order by CovidPercentage desc

--Showing countries with highest death count per population 

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio_project..CovidDeaths 
Where continent is not null
Group by location
Order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT 

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio_project..CovidDeaths 
Where continent is null
Group by location
Order by TotalDeathCount desc

--Showing continents with the highest  death count per population 

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio_project..CovidDeaths 
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio_project..CovidDeaths
Where continent is not null   
Group by date
Order by 1,2 

-- Overall Death Percentage

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio_project..CovidDeaths
Where continent is not null     
--Group by date
Order by 1,2 

--Looking at total population vs vaccinations

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations    
,SUM(CAST(vac.new_vaccinations as int)) OVER(Partition by dea.location ORDER BY dea.location,dea.date) AS total_vaccinations
From Portfolio_project..CovidDeaths dea
Join Portfolio_project..CovidVaccinations vac
On dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not null  
Order by 2,3 

--We cant use total_vacc again after it so we use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, total_vaccinations)
As
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations    
,SUM(CAST(vac.new_vaccinations as int)) OVER(Partition by dea.location ORDER BY dea.location,dea.date) AS total_vaccinations
From Portfolio_project..CovidDeaths dea
Join Portfolio_project..CovidVaccinations vac
On dea.location=vac.location
and dea.date=vac.date
Where dea.continent is not null  
)
Select*, (total_vaccinations/population)*100
From PopvsVac

--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
total_vaccinations numeric
)
Insert Into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations    
,SUM(CAST(vac.new_vaccinations as int)) OVER(Partition by dea.location ORDER BY dea.location,dea.date) AS total_vaccinations
From Portfolio_project..CovidDeaths dea
Join Portfolio_project..CovidVaccinations vac
On dea.location=vac.location
and dea.date=vac.date
--Where dea.continent is not null  

Select*, (total_vaccinations/population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations    
,SUM(CONVERT(int , vac.new_vaccinations)) OVER(Partition by dea.location ORDER BY dea.location,dea.date) AS total_vaccinations
From Portfolio_project..CovidDeaths dea
Join Portfolio_project..CovidVaccinations vac
	On dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null  
--Order by 2,3 

Select *
From PercentPopulationVaccinated

