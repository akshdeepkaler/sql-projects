/*  Cleaning Data in SQL Queries*/

Select * 
From dbo.NashvilleHousing

--  Standardize Date Format
Alter Table dbo.NashvilleHousing
Add SaleDateConverted Date;

Update dbo.NashvilleHousing
Set SaleDateConverted = Convert (Date, SaleDate)

Select SaleDateConverted, Convert (Date, SaleDate)
From dbo.NashvilleHousing

-- Populate Property Address data

Select a1.ParcelID, a1.PropertyAddress, a2.ParcelID, a2.PropertyAddress, Isnull(a1.PropertyAddress, a2.PropertyAddress)
From dbo.NashvilleHousing a1
Join dbo.NashvilleHousing a2
	on a1.ParcelID =a2.ParcelID
	and a1.[UniqueID ] <> a2.[UniqueID ]
Where a1.PropertyAddress is null

Update a1
Set PropertyAddress = isnull(a1.PropertyAddress, a2.PropertyAddress)
From dbo.NashvilleHousing a1
Join dbo.NashvilleHousing a2
	on a1.ParcelID =a2.ParcelID
	and a1.[UniqueID ] <> a2.[UniqueID ]
Where a1.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
From dbo.NashvilleHousing

Alter Table dbo.NashvilleHousing
Add StreetName nvarchar(255);

Update dbo.NashvilleHousing
Set StreetName = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table dbo.NashvilleHousing
Add City nvarchar(255);

Update dbo.NashvilleHousing
Set City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, Len(PropertyAddress))

Select * 
From dbo.NashvilleHousing

Select OwnerAddress 
From dbo.NashvilleHousing

-- Breaking down addresses with ParseName 
Alter Table dbo.NashvilleHousing
Add OwnerStreet nvarchar(255);

Update dbo.NashvilleHousing
Set OwnerStreet = PARSEName(Replace(OwnerAddress,',','.') ,3)

Alter Table dbo.NashvilleHousing
Add OwnerCity nvarchar(255);

Update dbo.NashvilleHousing
Set OwnerCity = PARSEName(Replace(OwnerAddress,',','.') ,2)

Alter Table dbo.NashvilleHousing
Add OwnerState nvarchar(255);

Update dbo.NashvilleHousing
Set OwnerState = PARSEName(Replace(OwnerAddress,',','.') ,1)

Select * 
From dbo.NashvilleHousing

-- Change Y and N and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Update NashvilleHousing
Set SoldAsVacant = 
Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End

-- Remove Dulpicates
With RowNumCTE As(
Select *, 
	ROW_NUMBER() Over (
	Partition by ParcelID, 
				 PropertyAddress, SalePrice, SaleDate, LegalReference
				 Order by UniqueID) row_num
From dbo.NashvilleHousing)

Delete
From RowNumCTE
Where row_num > 1

-- Delete Unused Columns
Select *
From dbo.NashvilleHousing

Alter table dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter table dbo.NashvilleHousing
Drop Column SaleDate
