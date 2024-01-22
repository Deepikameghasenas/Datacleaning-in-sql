--cleaning data in sql queries

select *
from portfolioproject1.dbo.NashvilleHousing

--get the saledate 
select saleDate,convert(Date,saleDate)
from portfolioproject1.dbo.NashvilleHousing

--alter the table with the daledateconverted with date and then 
--update the table with the field name and display it
alter table NashvilleHousing
add SaleDateConverted Date;

update [NashvilleHousing]
set SaleDateConverted=convert(date,saleDate)

select saleDateConverted,convert(Date,saleDate)
from portfolioproject1.dbo.NashvilleHousing

/* data cleaning done on the PropertyAddress which is null)*/
--property address
select PropertyAddress
from portfolioproject1.dbo.NashvilleHousing
--where PropertyAddress is null

select a.parcelID, a.PropertyAddress,b.parcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolioproject1.dbo.NashvilleHousing a
join portfolioproject1.dbo.NashvilleHousing b
on a.parcelID=b.parcelID
and a.UniqueID<>b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolioproject1.dbo.NashvilleHousing a
join portfolioproject1.dbo.NashvilleHousing b
on a.parcelID=b.parcelID
and a.UniqueID<>b.UniqueID
where a.PropertyAddress is null

--breaking PropertyAddress into individual columns (Address, City, State)
select PropertyAddress
from portfolioproject1.dbo.NashvilleHousing
order by ParcelID

--split the address to 2 separate parts by ,
select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
from portfolioproject1.dbo.NashvilleHousing


--similarly split the owner address accod=rdingly

select parsename(Replace(OwnerAddress,',','.'),3)
,parsename(Replace(OwnerAddress,',','.'),2)
,parsename(Replace(OwnerAddress,',','.'),1)
from portfolioproject1.dbo.NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress varchar(200);

update NashvilleHousing
set OwnerSplitAddress=parsename(Replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity varchar(200);

update NashvilleHousing
set OwnerSplitCity=parsename(Replace(OwnerAddress,',','.'),2)

alter table NashvilleHousing
add OwnerSplitState varchar(200);

update NashvilleHousing
set OwnerSplitState=parsename(Replace(OwnerAddress,',','.'),1)

select *
from portfolioproject1.dbo.NashvilleHousing

--change yes to y and No to No in SoldAsVacant
select Distinct(SoldAsVacant),count(SoldAsVacant)
from portfolioproject1.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
,case when SoldAsVacant ='Y' then 'yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
	end
from portfolioproject1.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant=case when SoldAsVacant ='Y' then 'yes'
	when SoldAsVacant='N' then 'No'
	else SoldAsVacant
	end

--remove duplicates
with RowNumCTE as(
select *,
row_number()over(
partition by ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
order by
UniqueID
)row_num
from portfolioproject1.dbo.NashvilleHousing
--order by ParcelID
)

select *
from RowNumCTE