--Data exploring, casting, temporary tables, aggregating functions, working with dates and calculations for the COVID dataset
--Cleaning the table to only columns I'll use for the analysis

SELECT [continent]
      ,[location]
      ,[population]
      ,[date]
      ,[total_cases]
      ,[total_deaths]
      ,[total_tests]
      ,[positive_rate]
      ,[people_fully_vaccinated]
      ,[icu_patients]
      ,[hosp_patients]
      ,[hospital_beds_per_thousand]
  FROM [CovidProject].[dbo].[owid-covid-data]


         --All columns where imported as varchar() so I will convert columns data from varchar() 
	 --to the correct data type into a temporary table 
	 --In the Continent column there was some empty columns but were not NULL values but empty string
         --I used the LEN() function to filter the empty strings in the Continent column and the IS NOT NULL to make sure no NULL values were in the new table view 
  --drop table #covid_summary
Create table #Covid_summary 
(
continent varchar(50),
Location varchar(50),
Population float,
Date date,
New_cases float,
Total_cases float,
New_deaths float,
Total_deaths float,
New_tests float,
Total_tests float,
Positive_rate float,
People_fully_vaccinated float,
Icu_patients float,
Hosp_patients float,
Hospital_beds_per_thousand float,
)

insert into #Covid_summary 
  select
  [continent],
  [location],
  cast(population as float) as Population,
  cast(date as date) as Date,
  cast(new_cases as float) as New_cases,
  cast(round(cast(total_cases as float), 0) as int) as total_cases,
  cast(New_deaths as float) as New_deaths,
  cast(total_deaths as float) as Total_deaths,
  cast(New_tests as float) as New_tests,
  cast([total_tests] as float) as Total_tests,
  cast ([positive_rate] as float) as Positive_rate,
  cast ([people_fully_vaccinated] as float) as people_fully_vaccinated,
  cast ([icu_patients] as float) as icu_patients,
  cast ([hosp_patients] as float) as hosp_patients,
  cast ([hospital_beds_per_thousand] as float) as hospital_beds_per_thousand
  from [dbo].[owid-covid-data]
  where continent is not null and len(continent) > 0


  --Now use the new temporary table to perform various different calculations

  --TABLE 1
  --Population vs Total cases
  --percentage of the population that got infected

  select location, population, date, total_cases, total_deaths, (total_cases/population)*100 as Perc_infected
  from #Covid_summary
    order by Perc_infected desc


  --TABLE 2
  --Population vs Total deaths
  --percentage of the population that died from covid

  select location, population, date, total_cases, total_deaths, (total_deaths/population)*100 as Perc_dead
  from #Covid_summary
  order by Perc_dead desc


  --TABLE 3
  --Total_cases vs Total deaths
  --percentage of the infected population that died from covid or likelihood of dying if you contract cov

  select location, population, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Perc_of_infected_dead
  from #Covid_summary
  where total_cases > 0 --Make sure you are not dividing by zero


  --TABLE 4
  --Countries with the highest infection rate per population

  select location, population, max(total_cases) as Highest_count, max((total_cases/Population)*100) as Perc_infected
  from #Covid_summary
  group by location, Population
  order by Perc_infected desc


  
  --TABLE 5
  --Countries with the highest death rate per population

  select location, population, max(Total_deaths) as Highest_deaths, max((Total_deaths/Population)*100) as Perc_dead
  from #Covid_summary
  group by location, Population
  order by Perc_dead desc



  --TABLE 6
  --Countries with the highest death rate per total covid infections

  select continent 
      ,location
	  ,population
	  ,sum(new_cases) as Total_cases
	  ,sum(new_deaths) as Total_deaths
	  ,sum(new_deaths)/sum(new_cases)*100 as Perc_dead
  from #Covid_summary
  where new_cases > 0 
  group by location, continent, population
  order by Perc_dead desc
 


  --TABLE 7
  --Continents with the highest count of deaths and percentage of deaths by population

  drop table #Continent_summary
  create table #Continent_summary
  (
  Continent varchar(50),
  Tot_population float,
  Total_cases float,
  Total_Death_Count float
  )

  insert into #Continent_summary
  Select continent, sum(distinct population) as Tot_population, sum(new_cases) as Tot_cases, sum(new_deaths) as Total_Death_Count
From #Covid_summary
Group by continent

select *, (Total_Death_Count/Tot_population) as Perc_death  
from #Continent_summary
order by Perc_death desc



  --TABLE 8
  --Continents with the highest count of deaths and percentage of deaths by cases

select *, (Total_Death_Count/Total_cases) as Perc_death  
from #Continent_summary
order by Perc_death desc



  --TABLE 9
  --Global numbers 
Select Sum(distinct population) as Total_population, sum(new_cases) as Total_cases, sum(New_deaths) as Total_deaths, (sum(New_deaths)/sum(new_cases))*100 as Death_Percentage
from #Covid_summary



  --TABLE 10
  --Dates

  select * from #Covid_summary
  order by date


--Creating views for easy acces to the statements since we worked with temporary tables only

  create VIEW Covid_summary_view AS
select
  [continent],
  [location],
  cast(population as float) as Population,
  cast(date as date) as Date,
  cast(new_cases as float) as New_cases,
  cast(round(cast(total_cases as float), 0) as int) as total_cases,
  cast(New_deaths as float) as New_deaths,
  cast(total_deaths as float) as Total_deaths,
  cast(New_tests as float) as New_tests,
  cast([total_tests] as float) as Total_tests,
  cast ([positive_rate] as float) as Positive_rate,
  cast ([people_fully_vaccinated] as float) as people_fully_vaccinated,
  cast ([icu_patients] as float) as icu_patients,
  cast ([hosp_patients] as float) as hosp_patients,
  cast ([hospital_beds_per_thousand] as float) as hospital_beds_per_thousand
  from [dbo].[owid-covid-data]
  where continent is not null and len(continent) > 0

  Create view Continent_summary_view as
  Select continent, sum(distinct population) as Tot_population, sum(new_cases) as Tot_cases, sum(new_deaths) as Total_Death_Count
From Covid_summary_view
Group by continent

--end
