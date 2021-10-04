select *
from [PortfoliaProject].[dbo].[coviddeath]


--looking at total cases vs total deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases) *100 as Deathpercentage
from [PortfoliaProject].[dbo].[coviddeath]
where location like '%states%'
order by 1,2

--looking at toatal cases vs total population
-- show what percentage of people have covid

select location, date, total_cases, population,(total_cases/population) *100 as Totalpopulation
from [PortfoliaProject].[dbo].[coviddeath]
where continent is not null

order by 1,2

--looking at countries with highest infection rate compared to population
select location, Population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as percentPopulationInfected 
from PortfoliaProject..coviddeath
where continent is not null
group by population,location
order by percentPopulationInfected 


-- showing counrties highest death count per population
select location, Max(cast(total_deaths as int)) as TotalDeathcount
from PortfoliaProject..coviddeath
where continent is  null
group by location
order by TotalDeathcount desc

--let's break things down by continents
select continent, Max(cast(total_deaths as int)) as TotalDeathcount
from PortfoliaProject..coviddeath
where continent is not null
group by continent
order by TotalDeathcount desc


--showing the contnents with highest death count per population
select continent, Max(cast(total_deaths as int)) as TotalDeathcount
from PortfoliaProject..coviddeath
where continent is not null
group by continent
order by TotalDeathcount desc


--Global numbers
select date, sum(new_cases) as Totalcases, sum(cast(total_deaths as int)) as TotalDeaths,sum(cast(total_deaths as int))/ sum(new_cases)*100 as Deathpercentage 
from PortfoliaProject..coviddeath
where continent is not null
group by date
order by 1,2


select  sum(new_cases) as Totalcases, sum(cast(total_deaths as int)) as TotalDeaths,sum(cast(total_deaths as int))/ sum(new_cases)*100 as Deathpercentage 
from PortfoliaProject..coviddeath
where continent is not null

order by 1,2

--looking at total population vs vaccination

select  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingpeopleVaccinated
--(RollingpeopleVaccinated/population)*100
from PortfoliaProject..coviddeath dea

join PortfoliaProject..covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
order by 2,3

--use CTE
with PopvsVac (continent,location, date, population, new_vaccinations, RollingpeopleVaccinated)
as
(
select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingpeopleVaccinated
--(RollingpeopleVaccinated/population)*100
from PortfoliaProject..coviddeath dea

join PortfoliaProject..covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select * ,(RollingpeopleVaccinated/population)*100
from PopvsVac

--Temp table

create table #percentPopulationvaccinated
(continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingpeopleVaccinated numeric

)
INSERT into #percentPopulationvaccinated
select  dea.continent, dea.location, dea.Date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingpeopleVaccinated
--(RollingpeopleVaccinated/population)*100
from PortfoliaProject..coviddeath dea

join PortfoliaProject..covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
--order by 2,3

select * , (RollingpeopleVaccinated/population)*100
from  #percentPopulationvaccinated

--creating view to store data for later visualisations

create view percentPopulationvaccinated as 
select  dea.continent, dea.location, dea.Date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingpeopleVaccinated
--(RollingpeopleVaccinated/population)*100
from PortfoliaProject..coviddeath dea
join PortfoliaProject..covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

