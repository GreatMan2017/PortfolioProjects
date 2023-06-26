
/*

Cleaning Data in SQL Queries using the NashvilleHousing sales data obtained from https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/Nashville%20Housing%20Data%20for%20Data%20Cleaning.xlsx

*/

Select *
From PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select SaleDate ,CONVERT(Date,SaleDate) 
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)



---------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
-- There were duplicate records with same PARCELID but different addresss(Actual PropertyAddress or Null)
-- So for cases like this, I replaced the 'NULL' with the actual 'PropertyAddress'

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
-- order by ParcelID


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update NashvilleHousing
SET PropertySplitCity = Substring(PropertyAddress, (CHARINDEX(',', PropertyAddress)+1), LEN(PropertyAddress))

Select * 
From PortfolioProject.dbo.NashvilleHousing


-- Breaking our OwnerAddress into three columns based on the '.' delimiter

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select * 
From PortfolioProject.dbo.NashvilleHousing




------------------------------------------------------------------------------------------------------


-- Change Y and N to YES and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
,	CASE When SoldAsVacant = 'Y' THEN 'YES'
		 When SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant
		 END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = 
    CASE When SoldAsVacant = 'Y' THEN 'YES'
		 When SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant
		 END



-------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

-- Write some CTEs and use Windows function (Partition BY) to find where there are duplicate values
-- We want to partition our data so we can identify the duplicate rows. Rank, OrderRank, Row_Number are few options to accomplish this
--We'l be making use of the Row_Number option
--We need to partition it on things that should be unique to each row


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
From PortfolioProject.dbo.NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num > 1



--------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate



----------------------------------------------------------------------------------------------------------------------------

-- Handling NULL values
Select * From NashvilleHousing
Where Bedrooms IS NOT NULL
  And FullBath IS NOT NULL
  And HalfBath IS NOT NULL;