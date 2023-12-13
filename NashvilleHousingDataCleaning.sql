SELECT *
FROM nashvillehousing

-- --------------------------------------------------------------------------------------

-- Standardize Date Format
SELECT SaleDate, DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %d,%Y'),'%Y-%m-%d')
FROM nashvillehousing

SET SQL_SAFE_UPDATES=0

UPDATE nashvillehousing
SET SaleDate = DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %d,%Y'),'%Y-%m-%d')

SELECT SaleDate
FROM nashvillehousing

-- --------------------------------------------------------------------------------------

-- Populate PropertyAddress data in empty strings (''). 
-- Noticed duplicate ParcelIDs with different UniqueIDs.  
SELECT ParcelID, COUNT(ParcelID)
FROM nashvillehousing
-- WHERE PropertyAddress LIKE ''
GROUP BY ParcelID
HAVING COUNT(ParcelID) > 1

-- Convert empty string ('') in PropertyAddress to NULL
SELECT *
FROM nashvillehousing
-- WHERE PropertyAddress IS NULL
WHERE PropertyAddress LIKE ''

UPDATE nashvillehousing
SET PropertyAddress = NULL
WHERE PropertyAddress LIKE ''

-- Self join on ParcelID to replace NULLs in PropertyAddress
SELECT *
FROM nashvillehousing
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
	IFNULL(a.PropertyAddress,b.PropertyAddress)
FROM nashvillehousing a
	JOIN nashvillehousing b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE nashvillehousing a
	JOIN nashvillehousing b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress,b.PropertyAddress)
WHERE a.PropertyAddress IS NULL

-- --------------------------------------------------------------------------------------

-- Breaking out address into individual columns (Address, City, State)
-- Using PropertyAddress to get Address and City
SELECT PropertyAddress
FROM nashvillehousing

SELECT 
	SUBSTRING(PropertyAddress, 1, LOCATE(',',PropertyAddress)-1) as Address,
    SUBSTRING(PropertyAddress, LOCATE(',',PropertyAddress)+1, LENGTH(PropertyAddress)) as City
FROM nashvillehousing

ALTER TABLE nashvillehousing
ADD PropertySplitAddress VARCHAR(255)

UPDATE nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',',PropertyAddress)-1)

ALTER TABLE nashvillehousing
ADD PropertySplitCity VARCHAR(255)

UPDATE nashvillehousing
SET PropertySplitCIty = SUBSTRING(PropertyAddress, LOCATE(',',PropertyAddress)+1, LENGTH(PropertyAddress))

SELECT *
FROM nashvillehousing

-- Using OwnerAddress to get Address, City, and State
SELECT OwnerAddress,
	SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ', ', 1), ', ', -1),
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ', ', 2), ', ', -1),
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ', ', 3), ', ', -1)
FROM nashvillehousing

ALTER TABLE nashvillehousing
ADD OwnerSplitAddress VARCHAR(255),
ADD OwnerSplitCity VARCHAR(255),
ADD OwnerSplitState VARCHAR(255)

UPDATE nashvillehousing
SET OwnerSplitAddress = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ', ', 1), ', ', -1),
	OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ', ', 2), ', ', -1),
	OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ', ', 3), ', ', -1)

SELECT *
FROM nashvillehousing

-- --------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END
FROM nashvillehousing

UPDATE nashvillehousing
SET SoldAsVacant = 
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END
END

-- --------------------------------------------------------------------------------------

-- Remove Duplicates by Creating Duplicate Table then Replaceing Original Table
CREATE Table nashvillehousing_distinct LIKE nashvillehousing

INSERT INTO nashvillehousing_distinct 
	SELECT DISTINCT *
    FROM nashvillehousing

DROP TABLE nashvillehousing

RENAME TABLE nashvillehousing_distinct TO nashvillehousing

-- --------------------------------------------------------------------------------------

-- Remove Unwanted/Unused Columns

SELECT *
FROM nashvillehousing

ALTER TABLE nashvillehousing
DROP OwnerAddress, 
DROP TaxDistrict, 
DROP PropertyAddress

