/* The Carbo-loading dataset by: dunnhumby*/
-- Transaction Details
Select *
From dbo.dh_transactions;

-- Store's Details
Select *
From dbo.dh_store_lookup;

-- Product Information
Select *
From dbo.dh_product_lookup;

-- Trade Activity
Select *
From dbo.dh_causal_lookup;

-- Adding Store's zip code to the transaction table
Select trans.*, stores.store_zip_code
From dbo.dh_transactions as trans
	Left Join dbo.dh_store_lookup as stores
	On trans.store = stores.store;

-- The sales by Geographical Area
-- Area = 1
Select sum(cast(dollar_sales as float)) as area_1_sales
From dbo.dh_transactions
Where geography=1;

-- Area = 2 
Select sum(cast(dollar_sales as float)) as area_2_sales
From dbo.dh_transactions
Where geography=2;

-- Brands having sales greater than $1000
With
	cte_prodtab
	as
	(
		Select trans.*, brand
		From dbo.dh_transactions as trans
			inner Join dbo.dh_product_lookup as product
			On trans.upc = product.upc
	)
Select brand, sum(cast(dollar_sales as float)) as Total_Sales
From cte_prodtab
Group by brand
Having sum(cast(dollar_sales as float)) > 1000;

-- Number of commodities sold 
Select commodity, count(commodity) as number_sold,
	round(sum(cast(dollar_sales as float)),2) as 'Sales_Value (dollars)'
From dbo.dh_transactions as trans
	inner Join dbo.dh_product_lookup as product
	On trans.upc = product.upc
Group by commodity
Order by number_sold desc;

-- Number of households involved in the dataset
SELECT Count (Distinct (household)) as Number_of_households
From dbo.dh_transactions;

-- Percentage of commodity bought by the households
With
	cte_prodtab
	as
	(
		Select trans.*, brand, product_description, commodity, product_size
		From dbo.dh_transactions as trans
			inner Join dbo.dh_product_lookup as product
			On trans.upc = product.upc
	)
Select commodity, count(commodity)/(Select Cast(count(commodity) as float) from cte_prodtab) as percentage_of_commodity
From cte_prodtab
Group by commodity
Order by percentage_of_commodity desc;

-- Highest number of items buyer Analysis
-- Amount spent on commodity
With
	cte_prodtab
	as
	(
		Select trans.*, brand, product_description, commodity, product_size
		From dbo.dh_transactions as trans
			inner Join dbo.dh_product_lookup as product
			On trans.upc = product.upc
		Where household = (Select Top 1 household From dbo.dh_transactions Group by household Order by count(household) desc)
	)
Select commodity, round(sum(CAST(dollar_sales AS float)),2) AS 'amount_spend (dollars)', sum(CAST(units AS float)) number_of_units
From cte_prodtab
Group by commodity
Order by round(sum(CAST(dollar_sales AS float)),2) desc;

-- Amount and Quantity by Brand
With
	cte_prodtab
	as
	(
		Select trans.*, brand, product_description, commodity, product_size
		From dbo.dh_transactions as trans
			inner Join dbo.dh_product_lookup as product
			On trans.upc = product.upc
		Where household = (Select Top 1 household From dbo.dh_transactions Group by household Order by count(household) desc)
	)
Select brand, round(sum(CAST(dollar_sales AS float)),2) AS 'amount_spend (dollars)', sum(CAST(units AS float)) number_of_units
From cte_prodtab
Group by brand
Order by round(sum(CAST(dollar_sales AS float)),2) desc;

-- How many times the household with highest spending used coupons in two years
With
	cte_prodtab
	as
	(
		Select trans.*, brand, product_description, commodity, product_size
		From dbo.dh_transactions as trans
			inner Join dbo.dh_product_lookup as product
			On trans.upc = product.upc
		Where household = (Select Top 1 household From dbo.dh_transactions Group by household Order by count(household) desc)
	)
SELECT coupon, count(coupon) Number_of_coupons
From cte_prodtab
Group by coupon;

-- Household purchased items and its details
With prod_purch as (
Select trans.*, brand, product_description, commodity, product_size
From dbo.dh_transactions as trans
inner Join dbo.dh_product_lookup as product
On trans.upc = product.upc)
SELECT time_of_transaction, household, basket,store, prod_purch.commodity,dollar_sales,units,prod_purch.[day],
Sum(cast(dollar_sales as float)) over (PARTITION by basket) as Total_purchase_price, 
Sum(cast(units as float)) over (PARTITION by basket) as Total_units
From prod_purch
order by cast(prod_purch.[day] as int) asc,time_of_transaction;

-- Creating Temporary table
With prod_purch as (
Select trans.*, brand, product_description, commodity, product_size
From dbo.dh_transactions as trans
inner Join dbo.dh_product_lookup as product
On trans.upc = product.upc)
SELECT time_of_transaction, household, basket,store, prod_purch.commodity,dollar_sales,units,prod_purch.[day],
Sum(cast(dollar_sales as float)) over (PARTITION by basket) as Total_purchase_price, 
Sum(cast(units as float)) over (PARTITION by basket) as Total_units
Into #household_purch_his
From prod_purch
order by cast(prod_purch.[day] as int) asc,time_of_transaction;

-- Viewing top 10 columns
Select Top 10 * From #household_purch_his;