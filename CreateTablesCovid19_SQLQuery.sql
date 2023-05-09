-- Create the first table with the most important data from the imported dataset table with their proper data types. 
CREATE TABLE Covid_19_Deaths (
	  [iso_code] varchar(50)
      ,[continent] varchar(50)
      ,[location] varchar(50)
      ,[date] DATE 
	  ,[population] BIGINT
      ,[total_cases] INT
      ,[new_cases] INT
      ,[new_cases_smoothed] float
      ,[total_deaths] int
      ,[new_deaths] int
      ,[new_deaths_smoothed] float
      ,[total_cases_per_million] float
      ,[new_cases_per_million] float
      ,[new_cases_smoothed_per_million] float
      ,[total_deaths_per_million] float
      ,[new_deaths_per_million] float
      ,[new_deaths_smoothed_per_million] float
      ,[reproduction_rate] float
      ,[icu_patients] int
      ,[icu_patients_per_million] float
      ,[hosp_patients] int
      ,[hosp_patients_per_million] float
      ,[weekly_icu_admissions] int
      ,[weekly_icu_admissions_per_million] float
      ,[weekly_hosp_admissions] int
      ,[weekly_hosp_admissions_per_million] float
)

-- Add the values to the Covid_19_Deaths table with an INSERT INTO, SELECT Statement from the dataset.
INSERT INTO Covid_19.dbo.Covid_19_Deaths
SELECT [iso_code]
      ,[continent]
      ,[location]
      ,[date]
	  ,[population]
      ,[total_cases]
      ,[new_cases]
      ,[new_cases_smoothed]
      ,[total_deaths]
      ,[new_deaths]
      ,[new_deaths_smoothed]
      ,[total_cases_per_million]
      ,[new_cases_per_million]
      ,[new_cases_smoothed_per_million]
      ,[total_deaths_per_million]
      ,[new_deaths_per_million]
      ,[new_deaths_smoothed_per_million]
      ,[reproduction_rate]
      ,[icu_patients]
      ,[icu_patients_per_million]
      ,[hosp_patients]
      ,[hosp_patients_per_million]
      ,[weekly_icu_admissions]
      ,[weekly_icu_admissions_per_million]
      ,[weekly_hosp_admissions]
      ,[weekly_hosp_admissions_per_million]
FROM Covid_19.dbo.Covid_19_Deaths

--Create the second table with just the relate vaccines information and their data types according to the imported data.
CREATE TABLE Covid_19_Vaccines (
	   [iso_code] varchar(50)
      ,[continent] varchar(50)
      ,[location] varchar(50)
      ,[date] DATE
	  ,[total_tests] BIGINT
      ,[new_tests] INT
      ,[total_tests_per_thousand] float
      ,[new_tests_per_thousand] float
      ,[new_tests_smoothed] INT
      ,[new_tests_smoothed_per_thousand] float 
      ,[positive_rate] float
      ,[tests_per_case] float
      ,[tests_units] varchar(50)
      ,[total_vaccinations] BIGINT
      ,[people_vaccinated] BIGINT
      ,[people_fully_vaccinated] BIGINT
      ,[total_boosters] BIGINT 
      ,[new_vaccinations] BIGINT
      ,[new_vaccinations_smoothed] INT
      ,[total_vaccinations_per_hundred] float
      ,[people_vaccinated_per_hundred] float
      ,[people_fully_vaccinated_per_hundred] float
      ,[total_boosters_per_hundred] float
      ,[new_vaccinations_smoothed_per_million] INT
      ,[new_people_vaccinated_smoothed] INT 
      ,[new_people_vaccinated_smoothed_per_hundred] float
      ,[stringency_index] float 
      ,[population_density] float
      ,[median_age] float
      ,[aged_65_older] float
      ,[aged_70_older] float
      ,[gdp_per_capita] float 
      ,[extreme_poverty] float
      ,[cardiovasc_death_rate] float
      ,[diabetes_prevalence] float
      ,[female_smokers] float
      ,[male_smokers] float
      ,[handwashing_facilities] float
      ,[hospital_beds_per_thousand] float
      ,[life_expectancy] float
      ,[human_development_index] float
      ,[excess_mortality_cumulative_absolute] float
      ,[excess_mortality_cumulative] float
      ,[excess_mortality] float
      ,[excess_mortality_cumulative_per_million] float 
)

--Insert Values to the Covid_19_Vaccines table, from the imported dataset.
INSERT INTO Covid_19.dbo.Covid_19_Vaccines
SELECT [iso_code]
      ,[continent] 
      ,[location]
      ,[date] 
	  ,[total_tests] 
      ,[new_tests] 
      ,[total_tests_per_thousand] 
      ,[new_tests_per_thousand] 
      ,[new_tests_smoothed] 
      ,[new_tests_smoothed_per_thousand]  
      ,[positive_rate] 
      ,[tests_per_case] 
      ,[tests_units] 
      ,[total_vaccinations]
      ,[people_vaccinated]
      ,[people_fully_vaccinated] 
      ,[total_boosters] 
      ,[new_vaccinations] 
      ,[new_vaccinations_smoothed] 
      ,[total_vaccinations_per_hundred] 
      ,[people_vaccinated_per_hundred] 
      ,[people_fully_vaccinated_per_hundred] 
      ,[total_boosters_per_hundred] 
      ,[new_vaccinations_smoothed_per_million] 
      ,[new_people_vaccinated_smoothed]
      ,[new_people_vaccinated_smoothed_per_hundred] 
      ,[stringency_index]  
      ,[population_density] 
      ,[median_age] 
      ,[aged_65_older] 
      ,[aged_70_older] 
      ,[gdp_per_capita] 
      ,[extreme_poverty] 
      ,[cardiovasc_death_rate] 
      ,[diabetes_prevalence] 
      ,[female_smokers] 
      ,[male_smokers] 
      ,[handwashing_facilities] 
      ,[hospital_beds_per_thousand] 
      ,[life_expectancy] 
      ,[human_development_index]
      ,[excess_mortality_cumulative_absolute]
      ,[excess_mortality_cumulative] 
      ,[excess_mortality] 
      ,[excess_mortality_cumulative_per_million] 
FROM Covid_19.dbo.[owid-covid-data]

--Clean data using 'Alter Table, Alter Column' to change the data types from the imported dataset so later the tables created can be filled up 
ALTER TABLE [Covid_19].[dbo].[owid-covid-data]
ALTER COLUMN [life_expectancy] float
