-- use the database containing nashvill housing data
USE NashvileHousing;

-- Scan the dataset columns and data
SELECT * FROM nashville_housing LIMIT 5;
DESCRIBE nashville_housing;

-- Handle Dates in the dataset
SET SQL_SAFE_UPDATES = 0;
UPDATE nashville_housing 
SET SaleDate = STR_TO_DATE(SaleDate, '%M %d, %Y');


-- Handle properties with missing address
UPDATE nashville_housing AS no_address
JOIN nashville_housing AS with_address
    ON no_address.ParcelID = with_address.ParcelID
    AND no_address.UniqueID <> with_address.UniqueID
SET no_address.PropertyAddress = with_address.PropertyAddress
WHERE no_address.PropertyAddress IS NULL;

-- Split Property Address into Columns (Address, City, State)
ALTER TABLE nashville_housing
ADD COLUMN city VARCHAR(255),
ADD COLUMN street_address VARCHAR(255);

UPDATE nashville_housing
SET 
    house_city = TRIM(SUBSTRING_INDEX(PropertyAddress, ',', -1)),
    house_address = TRIM(SUBSTRING_INDEX(PropertyAddress, ',', 1));

-- Split Owner Address into Individual Columns (Address, City, State)
ALTER TABLE nashville_housing
ADD COLUMN owner_city VARCHAR(255),
ADD COLUMN owner_address VARCHAR(255),
ADD COLUMN owner_state VARCHAR(3);

UPDATE nashville_housing
SET 
    owner_address = TRIM(SUBSTRING_INDEX(OwnerAddress, ',',1)),
	owner_city = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',',2), ',', -1)),
	owner_state = TRIM(SUBSTRING_INDEX(OwnerAddress, ',',-1));
	
-- Change 'Y' and 'N' to 'Yes' and 'No' in "Sold as Vacant" Field
UPDATE nashville_housing
SET SoldAsVacant = CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant  -- Optional: to keep other values unchanged
END;


-- Remove Duplicates
WITH Remove_duplicates AS (
    SELECT UniqueID,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM nashville_housing
)
DELETE FROM nashville_housing
WHERE UniqueID IN (
    SELECT UniqueID
    FROM Remove_duplicates
    WHERE row_num > 1
);

-- Delete Unused Columns
ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;
    


