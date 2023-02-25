SELECT *
FROM Covid_19_Deaths_dataset


SELECT*
FROM Covid_19_Vaccination_dataset
order by 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM Covid_19_Deaths_dataset
order by 1,2

--Looking at Total Cases vs Total Deaths
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPrecentage
FROM Covid_19_Deaths_dataset
Where location = 'Afghanistan'
order by 1,2

--Looking at Total Cases vs Population
SELECT location,date,total_cases,population,(total_cases/population)*100 as DeathPrecentage
FROM Covid_19_Deaths_dataset
Where location = 'Afghanistan'
order by 1,2

--Looking at Countries with Highest Infection Rate Compared to population
SELECT location,date,population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
FROM Covid_19_Deaths_dataset
Group by location,population
order by 1,2

SELECT location,population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as percentpopulationInfected
FROM Covid_19_Deaths_dataset
where continent is not null
GROUP BY location,population
order by percentpopulationInfected desc

--Showing Countries with Highest Deaths Count per population
SELECT location, MAX(total_deaths) as TotalDeathsCount
FROM Covid_19_Deaths_dataset
where continent is not null
GROUP BY location,population
order by TotalDeathsCount desc

--Break down the total death count continent wise
SELECT continent, MAX(total_deaths) as TotalDeathsCount
FROM Covid_19_Deaths_dataset
where continent is not null
GROUP BY continent
order by TotalDeathsCount desc

----Break down the total death count location wise
SELECT location, MAX(total_deaths) as TotalDeathsCount
FROM Covid_19_Deaths_dataset
where continent is  null
GROUP BY location
order by TotalDeathsCount desc

-- Global numbers

SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From Covid_19_Deaths_dataset
where continent is not null
order by 1,2

-- total Vacination vs toatl population

Select death.continent, death.location,death.date,death.population, vacc.new_vaccinations
from Covid_19_Deaths_dataset death
join Covid_19_Vaccination_dataset vacc
	on death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
order by new_vaccinations desc

--total new vaccinations group by continent

Select  death.location,death.date,vacc.new_vaccinations, sum(vacc.new_vaccinations) Over (Partition by death.location) as total_new_vaccination
from Covid_19_Deaths_dataset death
join Covid_19_Vaccination_dataset vacc
	on death.location = vacc.location
	and death.date = vacc.date
where death.location is not null
order by total_new_vaccination desc

-- use cte
with PopvsVac (Continent,Location,Date,Population,New_vaccinations,RollingPeopleVaccinated)
as
(
select dea.Continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from Covid_19_Deaths_dataset dea
join Covid_19_Vaccination_dataset vac
	on dea.location = vac.location
	and dea.date = dea.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


---temp file 
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert  into #PercentPopulationVaccinated
select dea.Continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from Covid_19_Deaths_dataset dea
join Covid_19_Vaccination_dataset vac
	on dea.location = vac.location
	and dea.date = dea.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

create view PercentPopulationVaccinated as
select dea.Continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from Covid_19_Deaths_dataset dea
join Covid_19_Vaccination_dataset vac
	on dea.location = vac.location
	and dea.date = dea.date
where dea.continent is not null
--order by 2,3
