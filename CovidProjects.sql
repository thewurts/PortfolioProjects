--SELECT *
--FROM [dbo].[CovidDeaths]
--ORDER BY 3,4

--SELECT DATA WE WILL BE USING
SELECT [location],[date],[total_cases],[new_cases],[total_deaths],[population]
FROM [dbo].[CovidDeaths]
ORDER BY 1,2

--LOOK AT TOTAL CASES VS TOTAL DEATHS

SELECT [location],[date],[total_cases],[total_deaths],([total_deaths]/[total_cases])*100 As DeathPercentage
FROM [dbo].[CovidDeaths]
where [location] like '%states%'
ORDER BY 1,2

--Shows what percent of population has had covid
SELECT [location],[date],[population],[total_cases],([total_cases]/[population])*100 As PercentPopulationInfected
FROM [dbo].[CovidDeaths]
--where [location] like '%states%'
ORDER BY 1,2


--Look at countries with highest infection rate compared to population
SELECT [location],[population],max([total_cases])as HighestInfectionCount,max(([total_cases]/[population])*100) As PercentPopulationInfected
FROM [dbo].[CovidDeaths]
where [location] like '%states%'
group by [location],[date],[population]
ORDER BY 4 desc


--Showing countries with the highest death count per population

SELECT [location],max(cast ([total_deaths] as int))as TotalDeathCount
FROM [dbo].[CovidDeaths]
where [continent] is not null
group by [location]
ORDER BY 2 desc



--break down by continent

--show continents with the highest death count per population
SELECT [continent],max(cast ([total_deaths] as int))as TotalDeathCount
FROM [dbo].[CovidDeaths]
where [continent] is not null
group by [continent]
ORDER BY 2 desc


--global numbers

SELECT [date],SUM([new_cases])as total_cases,SUM(cast([new_deaths] as int))as total_deaths,SUM(cast([new_deaths] as int))/SUM([new_cases])*100 as DeathPercentage
FROM [dbo].[CovidDeaths]
--where [location] like '%states%'
where continent is not null
group by [date]
ORDER BY 1,2

SELECT SUM([new_cases])as total_cases,SUM(cast([new_deaths] as int))as total_deaths,SUM(cast([new_deaths] as int))/SUM([new_cases])*100 as DeathPercentage
FROM [dbo].[CovidDeaths]
--where [location] like '%states%'
where continent is not null
ORDER BY 1,2

--covid vaccinations
--looking at total population vs vaccinations
Select d.continent,d.location,d.date,d.population,v.new_vaccinations,
SUM(convert(int,v.new_vaccinations)) OVER (Partition by d.location order by d.location,d.date) as RollingPeopleVaccinated,
from [dbo].[CovidDeaths]d
join [dbo].[CovidVaccinations] v
on d.[location] = v.[location]
and d.date = v.date
where d.continent is not null
order by 2,3

--use cte
With PopvsVac(Continent,Location,Date,Population,NewVaccinations,RollingPeopleVaccinated)
as
(Select d.continent,d.location,d.date,d.population,v.new_vaccinations,
SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from [dbo].[CovidDeaths]d
join [dbo].[CovidVaccinations] v
on d.[location] = v.[location]
and d.date = v.date
where d.continent is not null
--order by 2,3
)

Select *,(RollingPeopleVaccinated/population)*100
from PopvsVac


--temp table
drop table if exists  #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into  #PercentPopulationVaccinated
Select d.continent,d.location,d.date,d.population,v.new_vaccinations,
SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from [dbo].[CovidDeaths]d
join [dbo].[CovidVaccinations] v
on d.[location] = v.[location]
and d.date = v.date
where d.continent is not null
--order by 2,3


Select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--SELECT *
--FROM [dbo].[CovidVaccinations]
--ORDER BY 3,4

--Create View to store data for later
Create View PercentPopulationVaccinated as
Select d.continent,d.location,d.date,d.population,v.new_vaccinations,
SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from [dbo].[CovidDeaths]d
join [dbo].[CovidVaccinations] v
on d.[location] = v.[location]
and d.date = v.date
where d.continent is not null
--order by 2,3