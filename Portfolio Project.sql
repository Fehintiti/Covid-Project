
--CovidDeaths
select * from Portfolio..Coviddeaths
where continent is not null
order by 3,4


--Covidvaccinations
select* from Portfolio..Covidvaccinations
where continent is not null
order by 3,4



select location, date, total_cases,total_deaths, new_cases,population
from Portfolio..Coviddeaths
order by 1,2

---Total cases vs Total Deaths In Nigeria
select location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio..Coviddeaths
where location like '%nigeria%' and continent is not null
order by 4

---TotalCases vs Population For the Whole World
select location, date, Population, total_cases, ( total_cases/population)*100 as Infected_CitizensPercentage
from Portfolio..Coviddeaths
where continent is not null
order by 1,2 


--Country with highest infection rate in the World
select location,Population, max(total_cases) as InfectionRate, max( total_cases/population)*100 as InfectectionPercentage
from Portfolio..Coviddeaths
where continent is not null
group by location,population
order by 4 desc



--Calculate the Total Deaths Count per Country in Africa
select location,continent,max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio..Coviddeaths
where continent is not null and continent like '%Africa%'
group by location,continent
order by 2 desc



--Total Deaths Count per Continent
select location, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio..Coviddeaths
where continent is  null 
group by location
order by 2 desc


--NewCases per day from all the Countries
select date,sum(new_cases) as Totalcases from Portfolio..Coviddeaths
where continent is not null 
group by date
order by 1,2


---NewCases Per Day in Africa
select date,location,sum(new_cases) as Totalcases from Portfolio..Coviddeaths
where continent is null and location like '%Africa%'
group by date,location
order by 1,2


--New cases vs New deaths Percentage in the World
select date,sum(new_cases) as Totalnewcases, sum(cast(new_deaths as int)) as TotalDetahs, sum(cast(new_deaths as int))/sum(new_cases)*100 as NewDeathPercentage
from Portfolio..Coviddeaths
where continent is not null 
group by date
order by 1,2


--Total new cases in the World
select location, sum(new_cases) as Totalnewcases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as NewDeathPercentage
from Portfolio..Coviddeaths
where continent is not null 
group by location
order by 1,2



--Totalnewcases in Africa
select location,Continent, sum(new_cases) as Totalnewcases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as NewDeathPercentage
from Portfolio..Coviddeaths 
where continent is not null and continent  like '%Africa%' 
group by location,continent 
order by 1,2


--Joining Both CovidDeaths and CovidVaccination Tables 

select * from Portfolio..Coviddeaths as dea
join 
Portfolio..Covidvaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
order by 2,3



---New Vaccinations per Population in the World
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,sum(convert(int,vac.new_vaccinations))
over(partition by dea.location) 
from Portfolio..Coviddeaths as dea
join 
Portfolio..Covidvaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- TotalnewVaccinations each day per Population in the World 
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations))
over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated 
from Portfolio..Coviddeaths as dea
join 
Portfolio..Covidvaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and dea.continent like'%Africa%'
order by 2,3



---Using CTE for the PercentageofPeople Vaccinated by location each day in the world
With PopvsVac (continent,location,date,population,new_vaccinations, RollingPeopleVaccinated) 
as
(
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations))
over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated 
from Portfolio..Coviddeaths as dea
join 
Portfolio..Covidvaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.continent like'%Africa%'
)

select *,(RollingPeopleVaccinated/population) *100 as Percentage
from PopvsVac



--TempTables for the PercentageofPeople Vaccinated by location each day in the world
Drop Table if exists #PercentageofPeopleVaccinated
Create Table #PercentageofPeopleVaccinated
(
continent varchar(255),
Location varchar (255),
date datetime,
Population int,
new_vaccinations int,
RollingPeopleVaccinated int)


insert into #PercentageofPeopleVaccinated
 select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations))
over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated 
from Portfolio..Coviddeaths as dea
join 
Portfolio..Covidvaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.continent like'%Africa%'


select *,(RollingPeopleVaccinated/population) *100 as Percentage
from #PercentageofPeopleVaccinated



--Create View
Create View RolPeopleVaccinated as
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations))
over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated 
from Portfolio..Coviddeaths as dea
join 
Portfolio..Covidvaccinations as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and dea.continent like'%Africa%'










