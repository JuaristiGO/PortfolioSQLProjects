USE Covid_19
--CREATE VIEWS TO STORE DATA FOR VISUALIZATIONS
--View for Total Cases vs Population, What percentage of population got sick by Covid-19?
CREATE VIEW DailyPercentage_PopulationInfectedbyCovid
AS
SELECT a.date,
       a.location,
       a.population,
       a.total_cases,
       ROUND((a.total_cases / a.population) * 100, 5) AS Sick_percentage
  FROM (   Select location,
                  date,
                  CAST(total_cases AS float) AS total_cases,
                  CAST(population AS float) AS population
             FROM Covid_19.dbo.Covid_19_Deaths) AS a


--View for countries with the highest infection rate compared to population.
CREATE VIEW HighestInfectionRateCountry
AS
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
 

 --View for countries with highest death count per population and their death percentage
 CREATE VIEW DeathCountAndDeathPercentage
 AS
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

--View for Continents deaths and cases with their percentages
CREATE VIEW ContinentsDeathsCasesInfo
AS
SELECT continent,
       SUM(population) AS Total_continent_population,
       MAX(total_cases) AS Continent_infected_cases,
       ROUND(MAX(a.total_cases) / SUM(a.population) * 100, 5) Continent_infected_percentage,
	   MAX(total_deaths) AS Continent_death_count,
       ROUND(MAX(a.total_deaths) / SUM(a.population) * 100, 10) Continent_death_percentage,
	   ROUND((MAX(a.total_deaths)/MAX(a.total_cases)*100),2) AS Deaths_from_cases_percentage
  FROM (   SELECT continent,
				  CAST(total_cases AS float) AS total_cases,
                  CAST(total_deaths AS float) AS total_deaths,
                  CAST(population AS float) AS population
             FROM Covid_19.dbo.Covid_19_Deaths) AS a
 WHERE continent IS NOT NULL
 GROUP BY continent


 --View for daily cases and deaths around the world
 CREATE VIEW DailyCasesDeathsWorld
 AS
 SELECT date, 
	   SUM(CAST(total_cases AS BIGINT)) AS Global_cases, 
	   SUM(CAST(total_deaths AS BIGINT)) AS Global_deaths,
	   ROUND((SUM(CAST(total_deaths AS float))/SUM(total_cases)*100),2) AS Deaths_from_cases_percentage
 FROM Covid_19.dbo.Covid_19_Deaths
 WHERE continent IS NOT NULL
 GROUP BY date


--View for top fully vaccinated population by country
DROP VIEW IF EXISTS PercentageFullyVaccinatedPopulation 
CREATE VIEW PercentageFullyVaccinatedPopulation
AS
SELECT vp.location,
       d2.continent,
       MAX(percentage_people_fully_vaccinated) AS percentage_people_full_vaccinated
  FROM (   SELECT v.date,
                  d.continent,
                  d.location,
                  population,
                  people_fully_vaccinated,
                  people_vaccinated,
                  new_vaccinations,
                  ROUND((CAST(people_fully_vaccinated AS float) / population) * 100, 4) AS percentage_people_fully_vaccinated
             FROM Covid_19.dbo.Covid_19_Vaccines AS v
             JOIN Covid_19.dbo.Covid_19_Deaths AS d
               ON v.date     = d.date
              AND v.location = d.location
            WHERE d.continent IS NOT NULL) AS vp
  JOIN Covid_19.dbo.Covid_19_Deaths AS d2
    ON vp.location = d2.location
 WHERE d2.continent IS NOT NULL
 GROUP BY vp.location,
          d2.continent

--Compare each country with percentage of death cases.
CREATE VIEW PercentageDeathCases
AS
SELECT location,
       continent,
       (CAST(SUM(new_deaths) AS float) / population) * 100 AS Death_percentage
  FROM Covid_19.dbo.Covid_19_Deaths
 WHERE continent IS NOT NULL
 GROUP BY location,
          continent,
          population


--Compare country death cases percentage vs full vaccinated percentage.
CREATE VIEW ComparePercentage_DeathCases_FullVaccinated
AS
SELECT pvp.location,
       pvp.continent,
       MAX(cd.population) AS population,
       pvp.percentage_people_fully_vaccinated,
       ROUND(pdc.Death_percentage, 4) AS death_percentage
  FROM Covid_19.dbo.PercentageFullyVaccinatedPopulation AS pvp
  JOIN Covid_19.dbo.PercentageDeathCases AS pdc
    ON pvp.continent = pdc.continent
   AND pvp.location  = pdc.location
  JOIN Covid_19.dbo.Covid_19_Deaths AS cd
    ON pvp.location  = cd.location
 WHERE pvp.continent IS NOT NULL
   AND pdc.Death_percentage IS NOT NULL
   AND pvp.percentage_people_fully_vaccinated <= 100
 GROUP BY pvp.location,
          pvp.continent,
          cd.population,
          pvp.percentage_people_fully_vaccinated,
          pdc.Death_percentage

--How vaccines help to reduce deaths.
DROP VIEW IF EXISTS VaccinesCasesDeathsComparison
CREATE VIEW VaccinesCasesDeathsComparison
AS
SELECT q1.date,
       q1.location,
       q1.continent,
       q1.population,
       q1.new_cases,
       q1.count_new_cases AS daily_sum_new_cases,
       q1.new_deaths,
       q1.count_new_deaths AS daily_sum_new_deaths,
       COALESCE(q1.new_people_vaccinated_smoothed, 0) AS new_people_vaccinated,
       COALESCE(q1.count_new_people_vaccinated, 0) AS daily_count_new_people_vaccinated,
       COALESCE(ROUND(((CAST(q1.count_new_people_vaccinated AS float) / q1.population) * 100), 4), 0) AS percentage_vaccinated_population,
       COALESCE(ROUND(((CAST(q1.new_cases AS float) / q1.count_new_people_vaccinated) * 100), 4), 0) AS new_cases_against_vaccination_percentage,
       ROUND(((q1.new_deaths / CAST(q1.new_cases AS float)) * 100), 4) AS deaths_against_cases_percentage
  FROM (   SELECT cd.date,
                  cd.location,
                  cd.continent,
                  cd.population,
                  cd.new_cases,
                  SUM(cd.new_cases) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS count_new_cases,
                  cd.new_deaths,
                  SUM(cd.new_deaths) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS count_new_deaths,
                  cv.new_people_vaccinated_smoothed,
                  SUM(cv.new_people_vaccinated_smoothed) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS count_new_people_vaccinated
             FROM Covid_19.dbo.Covid_19_Deaths AS cd
             JOIN Covid_19.dbo.Covid_19_Vaccines AS cv
               ON cd.date     = cv.date
              AND cd.location = cv.location
            WHERE cd.continent IS NOT NULL) AS q1
 WHERE q1.count_new_deaths IS NOT NULL
  



