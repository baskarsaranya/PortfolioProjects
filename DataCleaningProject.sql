Select *
FROM Nashvile_Housing

Select SaleDateConverted, CONVERT(Date,SaleDate)
FROM Nashvile_Housing

Update Nashvile_Housing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE Nashvile_Housing
Add SaleDateConverted Date;

Update Nashvile_Housing
SET SaleDateConverted = CONVERT(Date,SaleDate)


--Populate Property Address data
Select *
FROM Nashvile_Housing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashvile_Housing a
JOIN Nashvile_Housing b
  on a.ParcelID=b.ParcelID
  AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Nashvile_Housing a
JOIN Nashvile_Housing b
  on a.ParcelID=b.ParcelID
  AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

--Seperating Property Address

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
FROM [Portfolio Project].[dbo].[Nashvile_Housing]

--Adding the new columns to the table

ALTER TABLE [Portfolio Project].[dbo].[Nashvile_Housing]
Add PropertySplitAddress Nvarchar(255);

Update [Portfolio Project].[dbo].[Nashvile_Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE [Portfolio Project].[dbo].[Nashvile_Housing]
Add PropertySplitCity Nvarchar(255);

Update [Portfolio Project].[dbo].[Nashvile_Housing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
FROM [Portfolio Project].[dbo].[Nashvile_Housing]

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [Portfolio Project].[dbo].[Nashvile_Housing]

--Updating the table with split information

ALTER TABLE [Portfolio Project].[dbo].[Nashvile_Housing]
Add OwnerSplitAddress Nvarchar(255);

Update [Portfolio Project].[dbo].[Nashvile_Housing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE [Portfolio Project].[dbo].[Nashvile_Housing]
Add OwnerSplitCity Nvarchar(255);

Update [Portfolio Project].[dbo].[Nashvile_Housing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE [Portfolio Project].[dbo].[Nashvile_Housing]
Add OwnerSplitState Nvarchar(255);

Update [Portfolio Project].[dbo].[Nashvile_Housing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
FROM [Portfolio Project].[dbo].[Nashvile_Housing]

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Portfolio Project].[dbo].[Nashvile_Housing]
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [Portfolio Project].[dbo].[Nashvile_Housing]

--Update the table with the new information

Update [Portfolio Project].[dbo].[Nashvile_Housing]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Portfolio Project].[dbo].[Nashvile_Housing]
Group by SoldAsVacant
order by 2


-- Remove Duplicates

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
From [Portfolio Project].[dbo].[Nashvile_Housing]
)
Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress


--Remove Unused Column

ALTER TABLE [Portfolio Project].[dbo].[Nashvile_Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From [Portfolio Project].[dbo].[Nashvile_Housing]

