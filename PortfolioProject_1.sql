SELECT *
FROM dbo.CovidDeaths
order by 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
order by 1,2

-- lookin at total cases vs total deaths
-- likelihood of dying
SELECT location, date, total_cases, total_deaths, (total_deaths*1.00/total_cases)*100 as deathpercentage
FROM dbo.CovidDeaths
where location LIKE '%states%'
order by 1,2


-- looking of total cases vs population

SELECT location, date, total_cases, population, (total_cases*1.00/population)*100 as case_percentage
FROM dbo.CovidDeaths
--where location LIKE '%states%'
order by 1,2


--looking at countries with highest infection rate compared to population

SELECT location, 
		population, 
		max(total_cases) AS highestinfectionCount,
		max((total_cases*1.00/population)*100) as percentPopulationInfected
FROM dbo.CovidDeaths
--where location LIKE '%states%'
GROUP BY location, population 
order by percentPopulationInfected desc


--Showing the countries with highest death count per population

SELECT location, 
		max(cast(total_deaths as int)) AS totaldeathcounts
FROM dbo.CovidDeaths
where continent IS NOT NULL
GROUP BY location 
order by totaldeathcounts desc


--BREAKS BY CONTINENT
-- SHOWING CONTINENT WITH HIGHEST DEATH COUNT

SELECT continent, 
		max(cast(total_deaths as int)) AS totaldeathcounts
FROM dbo.CovidDeaths
where continent IS NOT NULL
GROUP BY continent
order by totaldeathcounts desc



-- global numbers
SELECT  date
		,SUM(new_cases) newCaseCount
		,SUM(new_deaths) newDeathCount
		,SUM(new_deaths)*1.00/SUM(new_cases) new_DeathperCase
		--,total_deaths
		--,(total_deaths*1.00/total_cases)*100 as newdeathpercentage
FROM dbo.CovidDeaths
where new_cases != 0 and new_deaths !=0
GROUP BY date
order by 1,2

--looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population
		,vac.new_vaccinations
		,SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location order by dea.location,dea.date) as rollingPeopleVaccinated
		,
FROM DBO.CovidDeaths dea
join DBO.CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

---USE CTE

with PopvsVac as (
SELECT dea.continent, dea.location, dea.date, dea.population
		,vac.new_vaccinations
		,SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location order by dea.location,dea.date) as rollingPeopleVaccinated
		--,(rollingPeopleVaccinated/population)*100
FROM DBO.CovidDeaths dea
join DBO.CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3)
Select *,(rollingPeopleVaccinated*1.00/population)*100
FROM PopvsVac
order by 2,3


--Temp table
drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population
		,vac.new_vaccinations
		,SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location order by dea.location,dea.date) as rollingPeopleVaccinated
		--,(rollingPeopleVaccinated/population)*100
FROM DBO.CovidDeaths dea
join DBO.CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
--WHERE dea.continent is not NULL
--ORDER BY 2,3

Select *,(rollingPeopleVaccinated*1.00/population)*100
from #PercentPopulationVaccinated

-- CREATING VIEW TO STORE DATA FOR VISUALIZATION

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population
		,vac.new_vaccinations
		,SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location order by dea.location,dea.date) as rollingPeopleVaccinated
		--,(rollingPeopleVaccinated/population)*100
FROM DBO.CovidDeaths dea
join DBO.CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated









