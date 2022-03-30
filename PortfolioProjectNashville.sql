/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[NashvilleHousing]

  Select *
  From PortfolioProject..NashvilleHousing

  --Change sale date

  Select SaleDate, CONVERT(Date, SaleDate)
  From PortfolioProject..NashvilleHousing

  Update NashvilleHousing
  Set SaleDate = CONVERT(Date, SaleDate)

  Alter Table NashvilleHousing
  Add SaleDateConverted Date;

  Update NashvilleHousing
  Set SaleDateConverted = Convert(date, SaleDate)

  Select SaleDateConverted, CONVERT(Date, SaleDate)
  From PortfolioProject..NashvilleHousing

  --Populate property address data

Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
Order By ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]

--Breaking Address out into individual columns (Address, City, and State)

 Select PropertyAddress
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
--Order By ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address

From PortfolioProject..NashvilleHousing


  Alter Table PortfolioProject..NashvilleHousing
  Add PropertySplitAddress Nvarchar(255);

  Update PortfolioProject..NashvilleHousing
  Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

  Alter Table PortfolioProject..NashvilleHousing
  Add PropertySplitCity Nvarchar(255);

  Update PortfolioProject..NashvilleHousing
  Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select OwnerAddress
From PortfolioProject..NashvilleHousing


Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing

  Alter Table PortfolioProject..NashvilleHousing
  Add OwnerSplitAddress Nvarchar(255);

  Update PortfolioProject..NashvilleHousing
  Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

  Alter Table PortfolioProject..NashvilleHousing
  Add OwnerSplitCity Nvarchar(255);

  Update PortfolioProject..NashvilleHousing
  Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

  Alter Table PortfolioProject..NashvilleHousing
  Add OwnerSplitState Nvarchar(255);

  Update PortfolioProject..NashvilleHousing
  Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)


Select *
From PortfolioProject..NashvilleHousing


--Changing any 'Y' or 'N' to 'Yes' or 'No'

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End

--Remove Duplicates

With RowNumCTE as(
Select *,
Row_number() Over (
Partition By ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			Order by
				UniqueID
				) row_num

From PortfolioProject..NashvilleHousing
--Order By ParcelID
)
Select * 
From RowNumCTE
where row_num > 1
Order By PropertyAddress


--Delete Unused Columns


Select *
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject..NashvilleHousing
Drop Column SaleDate 