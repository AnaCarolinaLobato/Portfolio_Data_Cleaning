/*
Portfolio Cleaning Data IN SQL

Database Nashville Housing

*/

SELECT *
FROM portfolio_project..NashvilleHousing


-- CONVERTING DATE FORMAT

SELECT SaleDateConverted,CONVERT(Date,SaleDate) 
FROM portfolio_project..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT (Date,SaleDate)


--If the update doesn't work properly

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT (Date,SaleDate)

---------------------------------------------------------------------------------------------------------

--POPULATE PROPERTY ADDRESS DATA


SELECT * 
FROM portfolio_project..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT A.PropertyAddress, A.ParcelID, B.PropertyAddress, B.ParcelID, ISNULL(A.PropertyAddress,B.PropertyAddress) 
FROM portfolio_project..NashvilleHousing A
JOIN portfolio_project..NashvilleHousing B
     ON A.ParcelID = B.ParcelID
	 AND A.[UniqueID ] <> b.[UniqueID ]
--WHERE A.PropertyAddress is null


UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress) 
FROM portfolio_project..NashvilleHousing A
JOIN portfolio_project..NashvilleHousing B
     ON A.ParcelID = B.ParcelID
	 AND A.[UniqueID ] <> b.[UniqueID ]
WHERE A.PropertyAddress is null


-------------------------------------------------------------------------------------------------------------------


--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS(ADDRESS, CITY,STATE)
-- Using SUBSTRING/CHARINDEX OR PARSENAME


SELECT *
FROM portfolio_project..NashvilleHousing 



-- USING SUBSTRING


SELECT SUBSTRING(PropertyAddress,1 , CHARINDEX(',', PropertyAddress) -1) AS Address,
       SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM portfolio_project..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1 , CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



--USING PARSENAME


SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
       PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	   PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM portfolio_project..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 


ALTER TABLE NashvilleHousing
ADD OwnerSpliCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSpliCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



-- OR USE LEFT/RIGHT TO SPLIT COLUMNS IN SIMPLE WAY


SELECT OwnerSplitAddress,
       LEFT(OwnerSplitAddress,4) AS NumberAddress,
	   RIGHT(OwnerSplitAddress, LEN(OwnerSplitAddress)- 4) AS NameAddress
FROM portfolio_project..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD NumberAddress Nvarchar(255);

UPDATE NashvilleHousing
SET NumberAddress = LEFT(OwnerSplitAddress,4)


ALTER TABLE NashvilleHousing
ADD NameAddress Nvarchar(255);

UPDATE NashvilleHousing
SET NameAddress =  RIGHT(OwnerSplitAddress, LEN(OwnerSplitAddress)- 4)



--COMBINE COLUMNS WITH CONCAT


SELECT  CONCAT(NumberAddress,NameAddress)
FROM portfolio_project..NashvilleHousing


----------------------------------------------------------------------------------------------------------------


--CHANGE 'Y' AND 'N' TO YES AND NO IN "Sold as Vacant" FIELD


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM portfolio_project..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
       CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	        WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant END
FROM portfolio_project..NashvilleHousing 


UPDATE NashvilleHousing
SET SoldAsVacant =  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	                     WHEN SoldAsVacant = 'N' THEN 'No'
						 ELSE SoldAsVacant END



--------------------------------------------------------------------------------------------------------


--REMOVE DUPLICATE

WITH RowNumberCTE AS (
SELECT *,ROW_NUMBER() OVER (
         PARTITION BY ParcelId,
		              PropertyAddress,
					  SaleDate,
					  SalePrice,
					  LegalReference
					  ORDER BY UniqueId
					  ) row_num
FROM portfolio_project..NashvilleHousing
)
-- TO DELETE THE DUPLICATES CHANGE 'SELECT' TO 'DELETE' 
SELECT *
FROM RowNumberCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


--------------------------------------------------------------------------------------------------------------


--DELETE UNUSED COLUMNS



ALTER TABLE portfolio_project..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



-- HAVE OTHER SQL STRING FUNCTIONS TO CLEAN DATA AS

-- CLEANING STRINGS WITH TRIM()

-- CHANGING CASE TO UPPER() OR LOWER()

-- REPLACE THE NULL VALUES WITH COALESCE()

-- USE DATE_TRUNC() TO SPECIFY THE DATE YOU NEED