SELECT * from PortfolioProject..covidDeaths
order by 3,4

--SELECT * from PortfolioProject..covidVaccinations
--order by 3,4

--Select the data that we are going to be using
Select Location, date, total_cases, new_cases,total_deaths, population
from PortfolioProject..covidDeaths
order by 1,2

--Total cases vs Total deaths. Probability of dying if you get CoVID in Kenya
Select Location, date, total_cases,total_deaths, (Total_deaths/total_cases)*100.0 as Death_Percentage
from PortfolioProject..covidDeaths
Where location like '%Kenya%'
order by 1,2

--Total cases vs Population
Select Location, date, total_cases, population, (Total_cases/population)*100.0 as Percentage_with_covid
from PortfolioProject..covidDeaths
Where location like '%Kenya%'
order by 1,2

--Country with the highest infection rate compared to population
Select Location, population, MAX(Total_cases) as highest_infection_count, MAX((Total_cases/population))*100.0 as InfectedPopulation_Percentage
from PortfolioProject..covidDeaths
--Where location like '%Kenya%'
Group by location, population
order by InfectedPopulation_Percentage desc

--Country with the highest death rate compared to population
Select Location, MAX(cast (Total_deaths as int)) as highest_death_count
from PortfolioProject..covidDeaths
where continent is not NULL
--Where location like '%Kenya%'
Group by location
order by highest_death_count desc

--interms of continent
Select continent, MAX(cast (Total_deaths as int)) as highest_death_count
from PortfolioProject..covidDeaths
where continent is not NULL
--Where location like '%Kenya%'
Group by continent
order by highest_death_count desc

--worldwide numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..covidDeaths
Where continent is not null
group by date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..covidDeaths
Where continent is not null
order by 1,2


Select *
from PortfolioProject..covidVaccinations dea
join PortfolioProject..covidDeaths vacc
on dea.location= vacc.location
and dea.date=vacc.date

Select dea.continent, dea.location, dea.date, population, new_vaccinations, SUM(CONVERT(int,new_vaccinations)) OVER(Partition by dea.Location order by dea.location, dea.date) as cumulative_vaccinated
from PortfolioProject..covidVaccinations dea
join PortfolioProject..covidDeaths vacc
on dea.location= vacc.location
and dea.date=vacc.date
where dea.continent is not null
order by 2,3

--CTE
with popVSvacc (continent,location,date,population,new_vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, population, new_vaccinations, SUM(CONVERT(int,new_vaccinations)) OVER(Partition by dea.Location order by  dea.date) as RollingPeopleVaccinated
from PortfolioProject..covidVaccinations dea
join PortfolioProject..covidDeaths vacc
on dea.location= vacc.location
and dea.date=vacc.date
where dea.continent is not null
)
Select * , (RollingPeopleVaccinated/Population)*100
from popVSvacc


--TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, population, new_vaccinations, SUM(CONVERT(int,new_vaccinations)) OVER(Partition by dea.Location order by  dea.date) as RollingPeopleVaccinated
from PortfolioProject..covidVaccinations dea
join PortfolioProject..covidDeaths vacc
on dea.location= vacc.location
and dea.date=vacc.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--creating view for visualization
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, population, new_vaccinations, SUM(CONVERT(int,new_vaccinations)) OVER(Partition by dea.Location order by  dea.date) as RollingPeopleVaccinated
from PortfolioProject..covidVaccinations dea
join PortfolioProject..covidDeaths vacc
on dea.location= vacc.location
and dea.date=vacc.date
where dea.continent is not null





