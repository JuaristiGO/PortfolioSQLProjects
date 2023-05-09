USE NashvilleHousing;
--Cleaning NashvilleHousingData Project Imported from a CSV file

--Explore the data we have
SELECT *
FROM dbo.NashvilleHousingData;
------------------------------------------------------------------------
--Begin the cleaning process from the dataset 'Nashville Housing Data'.
------------------------------------------------------------------------

--First we will Standarize the Date Format.
SELECT SaleDate, CONVERT(datetime, SaleDate)
FROM dbo.NashvilleHousingData

UPDATE dbo.NashvilleHousingData
SET SaleDate = CONVERT(datetime, SaleDate)

ALTER TABLE dbo.NashvilleHousingdata
ADD SaleDateConverted datetime;

UPDATE dbo.NashvilleHousingData
SET SaleDateConverted = CONVERT(datetime, SaleDate);

--Populate Property Address Data; fix null values and separate city from address
SELECT *
FROM dbo.NashvilleHousingData
WHERE PropertyAddress IS NULL

--Join the table itself to see repited values from ParcelID impacting the PropertyAddress and look for NULL values but same ParcelID.
SELECT o.ParcelID, o.PropertyAddress, c.ParcelID, c.PropertyAddress, ISNULL(o.PropertyAddress, c.PropertyAddress)
FROM dbo.NashvilleHousingData AS o
JOIN dbo.NashvilleHousingData AS c
	ON o.ParcelID = c.ParcelID 
	AND o.UniqueID != c.UniqueID
WHERE o.PropertyAddress IS NULL

UPDATE o
SET PropertyAddress = ISNULL(o.PropertyAddress, c.PropertyAddress)
FROM dbo.NashvilleHousingData AS o
JOIN dbo.NashvilleHousingData AS c
	ON o.ParcelID = c.ParcelID 
	AND o.UniqueID != c.UniqueID
WHERE o.PropertyAddress IS NULL

--Break out Address into Individual Columns (address, city)
SELECT 
SUBSTRING(PropertyAddress, 0, CHARINDEX(',',PropertyAddress)) AS SAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS SCity
FROM dbo.NashvilleHousingData

ALTER TABLE dbo.NashvilleHousingdata 
ADD SAddress Varchar(225);

UPDATE dbo.NashvilleHousingData
SET SAddress = SUBSTRING(PropertyAddress, 0, CHARINDEX(',',PropertyAddress));

ALTER TABLE dbo.NashvilleHousingdata 
Add SCity Varchar(225);

UPDATE dbo.NashvilleHousingData
SET SCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress));

--Fix OwnerAddress splitting adress, city and state (using parsename function works with dots so have to replace commas for dots)
SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'), 1) AS SOwnerState,
PARSENAME(REPLACE(OwnerAddress,',','.'), 2) AS SOwnerCity,
PARSENAME(REPLACE(OwnerAddress,',','.'), 3) AS SOwnerAddress
FROM dbo.NashvilleHousingData

ALTER TABLE dbo.NashvilleHousingdata 
ADD SOwnerAddress Varchar(225);

UPDATE dbo.NashvilleHousingData
SET SOwnerAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3);

ALTER TABLE dbo.NashvilleHousingdata 
Add SOwnerCity Varchar(225);

UPDATE dbo.NashvilleHousingData
SET SOwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2);

ALTER TABLE dbo.NashvilleHousingdata 
Add SOwnerState Varchar(225);

UPDATE dbo.NashvilleHousingData
SET SOwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1);

--Fix the SoldAsVacant Column change it to 
SELECT DISTINCT(SoldAsVacant), COUNT(SoldASVacant) AS count
FROM dbo.NashvilleHousingData
GROUP BY SoldAsVacant

ALTER TABLE dbo.NashvilleHousingData
ALTER COLUMN SoldASVacant Varchar(50)

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 0 THEN 'No'
     WHEN SoldAsVacant = 1 THEN 'Yes'
	 ELSE SoldAsVacant
	 END
FROM dbo.NashvilleHousingData

Update dbo.NashvilleHousingData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 0 THEN 'No'
     WHEN SoldAsVacant = 1 THEN 'Yes'
	 ELSE SoldAsVacant
	 END

-- Remove Duplicates using CTE and a Window fuction to find where are the duplicates. 
-- Use Row_Number window function to see the rows that are duplicated having the same vital information in the Partition By statement.
WITH RowNum_CTE AS(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY  UniqueID ) AS ROW_NUM
FROM dbo.NashvilleHousingData
)

--SELECT *
--FROM RowNum_CTE
--WHERE ROW_NUM > 1

DELETE 
FROM RowNum_CTE
WHERE ROW_NUM > 1

--Round Acreage to 2 digits.
SELECT ROUND(Acreage, 2) AS RAcreage
FROM dbo.NashvilleHousingData

UPDATE dbo.NashvilleHousingData
SET Acreage = ROUND(Acreage, 2);

--Delete Unused Columns (Do not do that for raw data and OLTP DBs)
SELECT *
FROM dbo.NashvilleHousingData
-- PropertyAddress, SaleDateConverted (we dont need the time), TaxDistrict, OwnerAddress

ALTER TABLE dbo.NashvilleHousingData
DROP COLUMN OwnerAddress, SaleDateConverted, PropertyAddress, TaxDistrict

--Check everything 

SELECT *
FROM dbo.NashvilleHousingData;

--NOTE: Error marks are there because the columns have been eliminated in the last step. They where replaced in order to clean the dataset.
