--Project on Covid-19 using World data from <https://ourworldindata.org/covid-deaths> with the objective to analize and create visualizations about cases, deaths and vaccines around the world.
--Create Database Covid_19 to import the dataset in CSV format.
CREATE DATABASE Covid_19;

--1) Import the dataset: Select task in the Database, next import Data -> Config Header and Rows by CSV (seppararted by comma) and enter the destination for SQL Server.
SELECT TOP (10000) *
  FROM Covid_19.dbo.[owid-covid-data]

--2) Clean the data. Change datatypes from the dataset. (All the data types are Varchar(50) they have to be changed to the propper ones with an ALTER TABLE|ALTER COLUMN Statement).
--3) Create 2 different tables and add the values in a new query with an Insert Into statement using Select to fill the tables right from the dataset imported table.
--4) Explore the Data from Covid_19_deaths in a new query using different statements and functions.
--5) Explore the Data from Covid_19_vaccines in a new query using Joins, Window Functions, CTE's and creating a Temporary Table.
--6) Create Views to store data for visualizations.