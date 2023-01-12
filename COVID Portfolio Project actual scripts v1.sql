Select Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--Looking at Total cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
Where location like '%states%'
ORDER BY 1,2 

--Looking at Total cases vs Population
--Shows what percentage of population got covid

Select Location, date, population, total_cases,  (total_cases/population)*100 as EffectedCasePercentage
FROM CovidDeaths
--Where location like '%states%'
ORDER BY 1,2 

--Looking at countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentagePopulationInfection
FROM CovidDeaths
--Where location like '%states%'
GROUP BY Location, population
ORDER BY PercentagePopulationInfection desc

--Showing countries with highest death count per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--Where location like '%states%'
where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc


--Lets break things down by continent

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--Where location like '%states%'
where continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

--BREAK BY CONTINENT
--Showing the continent with highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--Where location like '%states%'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc



--GLOBAL NUMBERS

Select SUM(new_cases) as Total_cases, SUM(isnull(cast(new_deaths as numeric))) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--Looking at Total Population vs Vaccinations

Select Dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations
, SUM(cast(new_deaths as numeric(12,0))) OVER (Partition by Dea.location ORDER BY Dea.location, Dea.date) as RollingPeopleVaccinated
FROM CovidDeaths Dea
JOIN Covidvaccination Vacc
 On Dea.Location=Vacc.location
 and Dea.date=Vacc.date
 WHERE Dea.continent is not NULL
 ORDER BY 2,3



 --USE CTE
 
 With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
 as
 (
 Select Dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations
, SUM(cast(new_deaths as numeric(12,0))) OVER (Partition by Dea.location ORDER BY Dea.location, Dea.date) as RollingPeopleVaccinated
FROM CovidDeaths Dea
JOIN Covidvaccination Vacc
 On Dea.Location=Vacc.location
 and Dea.date=Vacc.date
 WHERE Dea.continent is not NULL
 --ORDER BY 2,3
 )
 Select *, (RollingPeopleVaccinated/Population)*100
 From PopvsVac



 --TEMP TABLE

 DROP TABLE if exists #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric)

 INSERT into #PercentPopulationVaccinated
  Select Dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations
, SUM(cast(new_deaths as numeric(12,0))) OVER (Partition by Dea.location ORDER BY Dea.location, Dea.date) as RollingPeopleVaccinated
FROM CovidDeaths Dea
JOIN Covidvaccination Vacc
 On Dea.Location=Vacc.location
 and Dea.date=Vacc.date
 --WHERE Dea.continent is not NULL
 --ORDER BY 2,3
 
 Select *, (RollingPeopleVaccinated/Population)*100
 From #PercentPopulationVaccinated



 --CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

 Create View PercentPopulationVaccinated as
  Select Dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations
, SUM(cast(new_deaths as numeric(12,0))) OVER (Partition by Dea.location ORDER BY Dea.location, Dea.date) as RollingPeopleVaccinated
FROM CovidDeaths Dea
JOIN Covidvaccination Vacc
 On Dea.Location=Vacc.location
 and Dea.date=Vacc.date
 WHERE Dea.continent is not NULL
 --ORDER BY 2,3