/****** Script for SelectTopNRows command from SSMS  ******/
--Explore Data from Covid_19_deaths
SELECT TOP(1000) *
FROM Covid_19.dbo.Covid_19_Deaths

--Update table changing 0's, blanks spaces, etc. To NULL values for the next queries. 
UPDATE Covid_19.dbo.Covid_19_Deaths
SET continent=NULL WHERE continent=''


-- Total Cases vs Total Deaths in México with Death Percentage per date.
Select location,
       date,
       total_cases,
       total_deaths,
       (a.total_deaths / a.total_cases) * 100 AS Death_percentage
  FROM (   Select location,
                  date,
                  CAST(total_cases AS float) AS total_cases,
                  total_deaths
             FROM Covid_19.dbo.Covid_19_Deaths) AS a
 WHERE location like '%M_x%'
 ORDER BY 1,
          2

--Total Cases vs Population in Mexico, what percentage of population got sick by Covid-19
SELECT location,
       date,
       population,
       total_cases,
       ROUND((a.total_cases / a.population) * 100, 5) AS Sick_percentage
  FROM (   Select location,
                  date,
                  CAST(total_cases AS float) AS total_cases,
                  CAST(population AS float) AS population
             FROM Covid_19.dbo.Covid_19_Deaths) AS a
 WHERE location like 'Mexico'
 ORDER BY date, Sick_percentage DESC

--Countries with the highest infection rate compared to population
SELECT location,
       population,
       MAX(total_cases) AS highest_infection_count,
       ROUND(MAX(a.total_cases / a.population) * 100, 5) AS Sick_percentage
  FROM (   Select location,
                  date,
                  CAST(total_cases AS float) AS total_cases,
                  CAST(population AS float) AS population
             FROM Covid_19.dbo.Covid_19_Deaths) AS a
 GROUP BY location,
          a.population
 ORDER BY Sick_percentage DESC

--Countries with highest death count per population and their death percentage
SELECT location,
       population,
       MAX(total_deaths) AS highest_death_count,
       ROUND(MAX(a.total_deaths / a.population) * 100, 5) AS deaths_percentage
  FROM (   Select location,
                  date,
                  CAST(total_deaths AS float) AS total_deaths,
                  CAST(population AS float) AS population
             FROM Covid_19.dbo.Covid_19_Deaths) AS a
 GROUP BY location,
          population
 ORDER BY highest_death_count DESC

--Exploring results by continent (death percentage) 
SELECT continent,
       SUM(population) AS Total_continent_population,
       MAX(total_deaths) AS Continent_death_count,
       ROUND(MAX(a.total_deaths) / SUM(a.population) * 100, 10) Continent_death_percentage
  FROM (   SELECT continent,
                  CAST(total_deaths AS float) AS total_deaths,
                  CAST(population AS float) AS population
             FROM Covid_19.dbo.Covid_19_Deaths) AS a
 WHERE continent IS NOT NULL
 GROUP BY continent
 ORDER BY Total_continent_population DESC

--Exploring results by continent (infection percentage) 
SELECT continent,
       SUM(population) AS Total_continent_population,
       MAX(total_cases) AS Continent_infected_cases,
       ROUND(MAX(a.total_cases) / SUM(a.population) * 100, 5) Continent_infected_percentage
  FROM (   SELECT continent,
                  CAST(total_cases AS float) AS total_cases,
                  CAST(population AS float) AS population
             FROM Covid_19.dbo.Covid_19_Deaths) AS a
 WHERE continent IN ( 'Asia', 'Africa', 'Europe', 'North America', 'South America', 'Oceania' )
 GROUP BY continent
 ORDER BY Total_continent_population DESC

--Percentage of people infected around the world
SELECT SUM(w.Continent_cases_percentage) AS Worlds_cases_percentage
  FROM (   SELECT continent,
                  SUM(population) AS Total_continent_population,
                  MAX(total_cases) AS Continent_cases_count,
                  ROUND(MAX(a.total_cases) / SUM(a.population) * 100, 5) Continent_cases_percentage
             FROM (   SELECT continent,
                             CAST(total_cases AS float) AS total_cases,
                             CAST(population AS float) AS population
                        FROM Covid_19.dbo.Covid_19_Deaths) AS a
            WHERE continent IN ( 'Asia', 'Africa', 'Europe', 'North America', 'South America', 'Oceania' )
            GROUP BY continent) AS w

--Global numbers: Cases vs Deaths per day around the world
SELECT date, 
	   SUM(CAST(total_cases AS BIGINT)) AS Global_cases, 
	   SUM(CAST(total_deaths AS BIGINT)) AS Global_deaths
 FROM Covid_19.dbo.Covid_19_Deaths
 WHERE continent IS NOT NULL
 GROUP BY date
 ORDER BY date

 --Global numbers: Global death percentage per day calculation with the summatory of cases and deaths each day.  
 SELECT date, 
	   SUM(CAST(total_cases AS BIGINT)) AS Global_cases_per_day, 
	   SUM(CAST(new_cases AS BIGINT)) AS Global_new_cases_per_day,
	   SUM(CAST(total_deaths AS BIGINT)) AS Global_deaths_per_day,
	   SUM(CAST(new_deaths AS BIGINT)) AS Global_new_deaths_per_day,
	   ROUND(SUM(CAST(new_deaths AS float))/SUM(new_cases)*100,4) AS Global_death_percentage_per_day
 FROM Covid_19.dbo.Covid_19_Deaths
 WHERE continent IS NOT NULL
 GROUP BY date
 ORDER BY date

--Global numbers: Average death percentage 
SELECT ROUND(AVG(a.Global_death_percentage_per_day),4) AS Global_average_death_percentage
FROM ( SELECT date, 
	   SUM(CAST(total_cases AS BIGINT)) AS Global_cases_per_day, 
	   SUM(CAST(new_cases AS BIGINT)) AS Global_new_cases_per_day,
	   SUM(CAST(total_deaths AS BIGINT)) AS Global_deaths_per_day,
	   SUM(CAST(new_deaths AS BIGINT)) AS Global_new_deaths_per_day,
	   ROUND(SUM(CAST(new_deaths AS float))/SUM(new_cases)*100,4) AS Global_death_percentage_per_day
	   FROM Covid_19.dbo.Covid_19_Deaths
       WHERE continent IS NOT NULL
       GROUP BY date ) AS a

