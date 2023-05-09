--Explore Data from Covid_19_Vaccines
SELECT *
  FROM Covid_19.dbo.Covid_19_Vaccines
  WHERE location = 'Mexico'
--Convert 0's and blank values to NULL values on the Vaccines Table.
UPDATE Covid_19.dbo.Covid_19_Vaccines
   SET new_people_vaccinated_smoothed = NULL
 WHERE new_people_vaccinated_smoothed = 0

--Total population vs new vaccinations
SELECT v.date,
       v.continent,
       v.location,
       d.population AS Population,
       v.new_vaccinations AS Vaccinations
  FROM Covid_19.dbo.Covid_19_Vaccines AS v
  JOIN Covid_19.dbo.Covid_19_Deaths AS d
    ON v.date     = d.date
   AND v.location = d.location
 WHERE d.continent IS NOT NULL
 ORDER BY location,
          date

--Total population vs new vaccinations per contry with a window function
SELECT v.date,
       v.continent,
       v.location,
       d.population AS Population,
       v.new_vaccinations AS Vaccinations_per_day,
       SUM(v.new_vaccinations) OVER (PARTITION BY v.location ORDER BY v.date) AS Count_of_People_Vaccined
  FROM Covid_19.dbo.Covid_19_Vaccines AS v
  JOIN Covid_19.dbo.Covid_19_Deaths AS d
    ON v.date     = d.date
   AND v.location = d.location
 WHERE d.continent IS NOT NULL
 ORDER BY location,
          date

--Use a CTE to calculate the Percentage of people fully vaccinated per country with the Vaccines country window function
WITH Country_Daily_Vaccines (date, continent, location, population, people_vaccinated, People_Fully_Vaccined_Country)
  AS (SELECT v.date,
             v.continent,
             v.location,
             d.population,
             v.people_fully_vaccinated,
             SUM(v.people_fully_vaccinated) OVER (PARTITION BY v.location ORDER BY v.location, v.date) AS People_Fully_Vaccined_Country
        FROM Covid_19.dbo.Covid_19_Vaccines AS v
        JOIN Covid_19.dbo.Covid_19_Deaths AS d
          ON v.date     = d.date
         AND v.location = d.location
       WHERE d.continent IS NOT NULL)

Select *,
       ROUND((CAST(People_Fully_Vaccined_Country AS float) / population) * 100, 4) AS People_Vaccineted_Percentage
  FROM Country_Daily_Vaccines

--Create a TEMP TABLE to check the information about vaccines around the world comparing: people new vaccines, vaccinated daily, people fully vacinated and the percentage of people fully vaccinated per country.
DROP TABLE IF EXISTS #Vaccines_PopInfo
CREATE TABLE #Vaccines_PopInfo (
    date DATE,
    continent Varchar(50),
    location Varchar(50),
    population bigint,
    people_fully_vaccinated bigint,
    people_vaccinated bigint,
    new_vaccinations bigint,
    percentage_people_fully_vaccinated float)

INSERT INTO #Vaccines_PopInfo
SELECT v.date,
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
 WHERE d.continent IS NOT NULL

--Query Top Countries with fully vaccinated population in Europe or America, joining the temporary table and the Covid_19_Deaths table
SELECT TOP (10) vp.location,
       MAX(percentage_people_fully_vaccinated) AS best_countries
  FROM #Vaccines_PopInfo AS vp
  JOIN Covid_19.dbo.Covid_19_Deaths AS d
    ON vp.location = d.location
 WHERE d.continent IS NOT NULL
   AND d.continent LIKE '%th%'
    OR d.continent LIKE 'Europe'
 GROUP BY vp.location
