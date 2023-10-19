
--changing the SaleDate format to normal date_format
USE yemmite
SELECT * FROM Nashvilehousing

SELECT SaleDate 
FROM Nashvilehousing

SELECT SaleDate, convert(Date, SaleDate) 
FROM Nashvilehousing

Alter Table yemmite.dbo.Nashvilehousing
add SaleDate_converted date

update Nashvilehousing
set SaleDate_converted = CONVERT(date, SaleDate)

SELECT SaleDate, SaleDate_converted 
FROM Nashvilehousing


            --TO POPULATE PropertyAddress column

--TO ACHIEVE THIS WE NEED TO JOIN A TABLE WITH EACH OTHER BY INTRODUCING ALLIAS

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress,b.PropertyAddress) as new_address
From Nashvilehousing a
JOIN Nashvilehousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashvilehousing a
join Nashvilehousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

select PropertyAddress
from Nashvilehousing
where PropertyAddress is not null

     --THE ABOVE SHOWS THAT PROPERTY ADDRESS HAS BEEN POPULATED THEREFORE IT HAS
	-- NO NULL VALUE(56,477 ROWS) CONFIRMED

-------------------------------------------------------------------------------------------------
			
			--3 BREAKING CHARACTER(PropertyAddress and OwnerAddress)

  --checking what is in PropertyAddress
SELECT PropertyAddress
from Nashvilehousing  


              --USING SUBSTRING AND CHARINDEX FUNCTION TO BREAK THE PROPERTY ADDRESS
                                 --INTO ADDRESS AND CITY
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address
From Nashvilehousing  

      
	  --THE ABOVE STATEMENT STARTS FROM THE ADDRESS AND ENDS AT COMMA(,)

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
From Nashvilehousing  


      --THE ABOVE STATEMENT REMOVES THE COMMA(,)

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,
len(PropertyAddress)) as city
From Nashvilehousing 

    --THE ABOVE SPLITS THE PROPERTYADDRESS INTO ADDRESS AND CITY
	--NB: THE 1 IS REMOVED IN THE SECOND SUBSTRING FUNCTION AND +1 WAS ADDED
    -- BECAUSE WE ARE NOT STARTING FROM THE FIRST LETTER BUT FROM LETTER AFTER COMMA
-- NB SUBSTRING SYNTAX IS:  SUBSTRING(STRING, START, LENGTH)

ALTER table Nashvilehousing  
add property_SplitAddress nvarchar(255)
      --THE ABOVE STATEMENT ADD ANOTHER COLUMN IN THE NASHVILEHOUSING TABLE

update Nashvilehousing
set property_SplitAddress = 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )
        -- THE ABOVE STATEMENT UPDATED THE NEW COLUMN ADDED IN THE TABLE

ALTER table Nashvilehousing  
add property_SplitCity nvarchar(255)
     --THE ABOVE STATEMENT ADD ANOTHER COLUMN IN THE NASHVILEHOUSING TABLE

update Nashvilehousing
set Property_SplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1,
len(PropertyAddress))
     -- THE ABOVE STATEMENT UPDATED THE NEW COLUMN ADDED IN THE TABLE


	 -- CHECKING THE TABLE WE HAVE:
select *
from Nashvilehousing

--TO SPLIT THE OWNERADDRESS, PARSENAME FUNCTION WILL BE USED INTEAD OF SUBSTRING 
--AND CHARINDEX

SELECT OwnerAddress
from Nashvilehousing

select
	PARSENAME(replace(OwnerAddress, ',', '.'), 3) as Address,
	PARSENAME(replace(OwnerAddress, ',', '.'), 2) as City,
	PARSENAME(replace(OwnerAddress, ',', '.'), 1) as State
	from Nashvilehousing

	ALTER table Nashvilehousing  
add Owner_SplitAddress nvarchar(255)
     --THE ABOVE STATEMENT ADD ANOTHER COLUMN(Owner_SplitAddress) IN THE NASHVILEHOUSING TABLE

update Nashvilehousing
set Owner_SplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)


ALTER table Nashvilehousing  
add Owner_SplitCity nvarchar(255)
     --THE ABOVE STATEMENT ADD ANOTHER COLUMN(Owner_SplitCity) IN THE NASHVILEHOUSING TABLE

update Nashvilehousing
set Owner_SplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

ALTER table Nashvilehousing  
add Owner_SplitState nvarchar(255)
     --THE ABOVE STATEMENT ADD ANOTHER COLUMN(Owner_SplitState) IN THE NASHVILEHOUSING TABLE

update Nashvilehousing
set Owner_SplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)

----------------------------------------------------------------------------------------------

--CHANGING 'Y' AND 'N' IN SoldAsVacant COLUMN TO 'YES' AND 'NO'

SELECT SoldAsVacant
from Nashvilehousing

-- TO CONVERT 'N' AND 'Y' TO NO AND YES WE ARE MAKING USE OF FUNCTION CASE WHEN

select SoldAsVacant,
(case when SoldAsVacant = 'N' then 'NO'
	WHEN SoldAsVacant = 'Y' THEN 'YES'
	ELSE SoldAsVacant
	END) AS SOLD_AS_VACANT
FROM Nashvilehousing

ALTER TABLE Nashvilehousing
ADD SOLD_AS_VACANT NVARCHAR(300)

UPDATE Nashvilehousing
SET SOLD_AS_VACANT = (case when SoldAsVacant = 'N' then 'NO'
	WHEN SoldAsVacant = 'Y' THEN 'YES'
	ELSE SoldAsVacant
	END)
	
SELECT *
from Nashvilehousing
--------------------------------------------------------------------------
     
	 ---REMOVING DUPLICATES USING THE CTE FUNCTION

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Nashvilehousing
)
DELETE
From RowNumCTE
Where row_num > 1

--TO CHECK WHETHER THERE ARE MORE DUPLICATES


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Nashvilehousing
)
SELECT *
From RowNumCTE
Where row_num > 1

----------------------------------------------------------------------------

-- DELETING UNUSED COLUMN(S)

ALTER TABLE Nashvilehousing
drop column OwnerAddress, PropertyAddress, TaxDistrict, SaleDate

-- TO CHECK THE NEW CLEANED TABLE
select * 
from Nashvilehousing