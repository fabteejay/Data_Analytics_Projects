select *
from Covid19_Project..CovidDealths$
where continent is not null
order by 3,4


--select *
--from [Covid19_Project].[dbo].[CovidVacinations$]
-- where continent is not null
--order by 3,4

-- Now Selecting the Datas I am going to be using from the whole datas.

select location, date, total_cases, new_cases, total_deaths, population
from Covid19_Project..CovidDealths$
where location like '%nigeria%' 
and where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Showa likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths / total_cases) *100 as Death_Percentage
from Covid19_Project..CovidDealths$
where location like '%nigeria%'
and where continent is not null
order by 1,2

-- Because total_cases and total_deaths columns are of type nvarchar, I write the code like this.
SELECT location, date, CAST(total_cases AS float), CAST(total_deaths AS float), 
(CAST(total_deaths AS float) / CAST(total_cases AS float)) * 100 AS Death_Percentage
FROM Covid19_Project..CovidDealths$
WHERE location LIKE '%nigeria%'
and continent is not null
ORDER BY 1, 2;


-- Looking at Total Case vs Population
-- Shows what percentage of population got Covid
SELECT location, date, CAST(population AS float)  Population, CAST(total_cases AS float)  Total_Cases,  
(CAST(total_cases AS float) / CAST(population AS float)) * 100 AS PopultionInfected_Percentage
FROM Covid19_Project..CovidDealths$
--WHERE location LIKE '%nigeria%'
where continent is not null
ORDER BY 1, 2;

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, CAST(population AS float)  Population, max(CAST(total_cases AS float))  Highest_Infection_Count,  
max((CAST(total_cases AS float) / CAST(population AS float))) * 100 AS Population_Infected_Percentage
FROM Covid19_Project..CovidDealths$
-- WHERE location LIKE '%nigeria%'
where continent is not null
Group by Location, Population
ORDER BY Population_Infected_Percentage desc

-- Showing Countries with Highest Death Count per Population

SELECT location, max(CAST(total_deaths AS int))  Total_Death_Percentage
FROM Covid19_Project..CovidDealths$
--WHERE location LIKE '%nigeria%'
where continent is not null --this will remove columns like world and the continent deaths numbers.
group by location
ORDER BY Total_Death_Percentage desc



-- Breaking it down to continents.

-- Showing the continent with highest death count per population.

SELECT continent, max(CAST(total_deaths AS int))  Total_Death_Percentage
FROM Covid19_Project..CovidDealths$
--WHERE location LIKE '%nigeria%'
where continent is not null --this will remove columns like world and the continent deaths numbers.
group by continent
ORDER BY Total_Death_Percentage desc


-- Global Numbers

SELECT sum(new_cases) as total_cases, sum(CAST(new_deaths AS int)) as total_deaths, 
sum(CAST(new_deaths AS float)) / sum(CAST(total_cases AS float)) * 100 AS Death_Percentage
FROM Covid19_Project..CovidDealths$
-- WHERE location LIKE '%nigeria%'
where continent is not null
--Group by date
ORDER BY 1, 2;


-- Looking at the total population vs total vaccinations
-- total amount of people in the world that had been vaccinated.

select death.continent, death.location, death.date, death.population, 
vac.new_vaccinations, sum(convert(float, vac.new_vaccinations)) over 
(partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100  --This can't work that is why we need to introduce CTE
from Covid19_Project..CovidDealths$  death
join Covid19_Project..CovidVacinations$  vac
	on death.location = vac.location
	and death.date = vac.date	-- just to ensure that they were joined correctly.
WHERE death.location LIKE '%nigeria%'
--where death.continent is not null
--Group by date
ORDER BY 2, 3



-- Using CTE

with PopvsVac (continent, Location, Date, POpulation, New_Vaccinations, RollingPeopleVaccinated)
as
(
select death.continent, death.location, death.date, death.population, 
vac.new_vaccinations, sum(convert(float, vac.new_vaccinations)) over 
(partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100  --This can't work that is why we need to introduce CTE
from Covid19_Project..CovidDealths$  death
join Covid19_Project..CovidVacinations$  vac
	on death.location = vac.location
	and death.date = vac.date	-- just to ensure that they were joined correctly.
WHERE death.location LIKE '%nigeria%'
--where death.continent is not null
--Group by date
--ORDER BY 2, 3
)
select *, (RollingPeopleVaccinated/POpulation)/100
from PopvsVac -- you need to select this with the CTE


--Temp Tab

Drop table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated -- Note
(											 -- Always EXECUTE your create table first.
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
select death.continent, death.location, death.date, death.population, 
vac.new_vaccinations, sum(convert(float, vac.new_vaccinations)) over 
(partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100  --This can't work that is why we need to introduce CTE
from Covid19_Project..CovidDealths$  death
join Covid19_Project..CovidVacinations$  vac
	on death.location = vac.location
	and death.date = vac.date	-- just to ensure that they were joined correctly.
--WHERE death.location LIKE '%nigeria%'
--where death.continent is not null
--Group by date
--ORDER BY 2, 3

select *, (RollingPeopleVaccinated/population)/100
from #PercentagePopulationVaccinated -- you need to select this with the CTE


-- Now creating view to store data that I will need later.


create view PercentagePopulationsVaccinated as
select death.continent, death.location, death.date, death.population, 
vac.new_vaccinations, sum(convert(float, vac.new_vaccinations)) over 
(partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100  --This can't work that is why we need to introduce CTE
from Covid19_Project..CovidDealths$  death
join Covid19_Project..CovidVacinations$  vac
	on death.location = vac.location
	and death.date = vac.date	-- just to ensure that they were joined correctly.
--WHERE death.location LIKE '%nigeria%'
where death.continent is not null
--Group by date
--ORDER BY 2, 3

select *
from PercentagePopulationsVaccinated