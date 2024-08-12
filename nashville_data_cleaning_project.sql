use amazon;
select * from `nashville housing data for data cleaning (reuploaded)`;


-- data Cleaning 
-- renaming table name 
alter table `nashville housing data for data cleaning (reuploaded)`
rename to  nashville_housing;

-- checking the data type of all columns 
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'nashville_housing';

-- change to date time foramat for this we need to bring the april in number form 

-- 1
alter table nashville_housing
add month_name int;

update nashville_housing
set month_name =
case 
when saleDate like '%January%' then 1
when saleDate like '%February%' then 2
when saledate like '%March%' then 3
when saledate like '%April%' then 4
when saledate like '%May%' then 5
when saledate like '%June%' then 6
when saledate like '%July%' then 7
when saledate like '%August%' then 8
when saledate like '%September%' then 9
when saledate like '%October%' then 10
when saledate like '%November%' then 11
when saledate like '%December%' then 12
else NULL
end ;

-- 2
alter table nashville_housing
add year int;

UPDATE nashville_housing
SET year =  SUBSTRING_INDEX(SUBSTRING_INDEX(SaleDate, ' ', 3), ' ', -1) ;


-- SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(SaleDate, ' ', 3), ' ', -1) AS extracted
-- FROM nashville_housing;   here the query gets the string upto third space inclusive and the outer one gives text after 3 space 

 
alter table nashville_housing
add day date;

alter table nashville_housing
modify column day int;

Update  nashville_housing
set day = SUBSTRING_INDEX(SUBSTRING_INDEX(SaleDate, ',', 1), ' ', -1) ;

alter table nashville_housing
modify  column 
date_transformed date;


update nashville_housing
set date_transformed= STR_TO_DATE(concat(day,'-',month_name,'-', year),'%d-%m-%Y') ;

ALTER TABLE nashville_housing
DROP COLUMN SaleDate, DROP COLUMN month_name,DROP COLUMN year, DROP COLUMN day;


select substring_index(LandUse,' ',1) from nashville_housing;
-- extracts a portion of a string before a specified number of occurrences of a delimiter. positive gives text to the right -ve gives text to the left


alter table nashville_housing
change `ï»¿UniqueID` `UniqueID` int;

-- checked nulls 


-- standardising PropertyAddress
-- select  substring_index(PropertyAddress,',', -1) from nashville_housing;
alter table nashville_housing 
add column city varchar(30);

alter table nashville_housing 
rename  column city to Property_city;

update  nashville_housing         -- alter to create columns and drop , update to populate , modify and changewith alter to rename , change data type name etc
set city = substring_index(PropertyAddress,',', -1) ;


-- select substring_index(PropertyAddress,' ', 2) from nashville_housing;
alter table nashville_housing 
add column house_number varchar(30);

alter table nashville_housing 
rename  column house_number to property_house_number;


update  nashville_housing         
set house_number =substring_index(PropertyAddress,' ', 2) ;

 
-- extracting  housenumber

update nashville_housing
set house_number= REGEXP_SUBSTR(house_number, '[0-9]+') ;
-- now turn it to int
alter table nashville_housing 
modify column house_number int;

-- select area from address
alter table nashville_housing 
add column area varchar(30);

alter table nashville_housing 
rename  column area to property_area;
select regexp_substr(substring_index(PropertyAddress,' ', 3), '[A-Za-z]+')
from nashville_housing as a;

update nashville_housing
set property_area =regexp_substr(substring_index(PropertyAddress,',', 1),'[A-Za-z].*') ;


select PropertyAddress from nashville_housing;
-- select regexp_substr(substring_index(PropertyAddress,',', 1),'[A-Za-z].*') from nashville_housing ;
-- teh property and ownere address seems to be identical so proof that both columns are same 

with cte as (SELECT  PropertyAddress,substring_index(OwnerAddress,',',2) , soldasvacant,
    CASE WHEN replace(PropertyAddress,' ', '') like replace(substring_index(OwnerAddress,',',2),' ', '') 
    THEN 1 ELSE 0 END AS check_similarity
FROM nashville_housing)
select * from cte 
where  PropertyAddress like '';


-- for above i used case to ceck similarity and also the trim to remove trailing space and further length to ensure that the difference was not due to uneven space in between 
-- possibility that 90% property and ownere address are same , however due to lack of client info i cant take it 
-- fill the missing values in propaddress based on owner address or do all the steps 


UPDATE nashville_housing
SET PropertyAddress = CASE
    WHEN PropertyAddress = '' 
    THEN SUBSTRING_INDEX(OwnerAddress, ',', 2)
    ELSE PropertyAddress
END;

-- here i am populating the prop address with owneraddresss as in 90% cases they are same 




select count(*) from nashville_housing where PropertyAddress like '';  -- implies removed as earlier there were empty rows 

update nashville_housing          -- standardising values -- replacing using update 
set soldasvacant = 'Yes' where 
soldasvacant ='Y' ;


update nashville_housing
set soldasvacant = 'No' where 
soldasvacant ='N' ;

select distinct  property_area, count(*) 
from nashville_housing
group by 1
order by  count(*) desc;  -- property area and tax district are different 


-- lets make a combined colum for full bath bedroom and hal bath 
alter table nashville_housing 
add column total_rooms int;

update nashville_housing 
set total_rooms= Bedrooms+FullBath+HalfBath;




update nashville_housing
set LandUse = 'VACANT RESIDENTIAL LAND' where 
LandUse ='VACANT RES LAND' ;


select distinct LandUse, COUNT(*) as num from new_nashville
group by LandUse order by num desc ;
-- the above shows maxi landuse type is for single family followed by duplex and lot limen , vacant residential land rest freq is around 1 1 only







-- acarege column 
select distinct Acreage from nashville_housing order by acreage desc ;  
-- distinct values 197 max is only 47.5 and 12.87 rest are below 10 

-- to analyse aceragewe can categorise or nbin using case 
select count(*) from nashville_housing where 
Acreage <=2; -- between 8 and 10 it id 2, >10 is 2 , bw 6 and 8 is 1 bw 4 and 6 is 6; bw 2,4 is 36 ; less than = 2 is 2730

-- lets bin 
-- create new colum to populate  < = 1 verysmall land, <2 small , bw 2-6 medium, 8-10 large, 10+ very large 

alter table nashville_housing
add column land_area_category varchar(20);

update nashville_housing
set land_area_category=
case when Acreage <=1 then "very small"
when Acreage <=2 then "small"
when Acreage between 2 and 6 then "medium"
when Acreage between 8 and 10 then "large"
when Acreage >= 10 then "very large" end;




-- so following lets check prices in all three districts 

-- lets see link between tax district and land value 
select   landvalue, count(*) as cnt_value
from nashville_housing
group by 1
order by landvalue desc;


select   avg(landvalue) as avg_land_val
from nashville_housing;

-- avg land value is 27519.1832

-- these can be categorised 
alter table nashville_housing 
add column land_value_range varchar(20)  ;


update  nashville_housing
set land_value_range =
case when LandValue  <=25000  then  'low_prices' 
when LandValue <=50000 then 'below_moderate'
when LandValue <=100000 then 'moderate'
when LandValue <=150000  then 'above_moderate' 
when LandValue <= 300000   then 'high' 
else 'very_high' end  ;









select max(Buildingvalue) from nashville_housing;

-- avg building value is 102,897.4757 , max= 1,249,900 min = 4,000

-- can again be categorised like 

alter table nashville_housing 
add column building_value_range varchar(50)  ;

update  nashville_housing
set building_value_range =
case when BuildingValue  <=10000  then  'low_building_prices' 
when BuildingValue <=25000 then 'below_moderate_building_prices'
when BuildingValue <=100000 then 'moderate_building_prices'
when BuildingValue <=150000  then 'above_moderate_building_prices' 
when BuildingValue <= 500000   then 'high_building_prices' 
else 'very_high_building_prices' end  ;
















-- question from linkedin - find the second highest price in each taxdistrict's each category
with second_highest as(
select TaxDistrict, land_area_category, SalePrice,
rank() over(partition by TaxDistrict,land_area_category order by SalePrice desc) rn 
from nashville_housing)
select * from  second_highest where rn= 2;

 
 
 -- lets find the duplicate records 

 
select count(*) from nashville_housing;   -- 2773

-- learnigns MySQL does not support directly deleting from a Common Table Expression (CTE) using the DELETE statement. 
--  so we create a temporary table excluding duplicates 

drop table new_nashvillehousing;
CREATE temporary table new_nashvillehousing AS

with cte as (select *, 
				row_number() over( partition by ParcelID, LandUse,PropertyAddress,SalePrice ) rn
				from nashville_housing
			) 

SELECT *
FROM nashville_housing
WHERE uniqueid NOT IN (SELECT uniqueid FROM cte where rn>1);
select count(*) from new_nashvillehousing;   -- 2763



select * from nashville_housing where FullBath ='' or FullBath = null ;



-- (e.g., location, amenities like rooms bathroom )?













-- drop view new_nashville;
create view new_nashville as 
select UniqueID,LandUse,Property_city,property_area,TaxDistrict,
land_area_category,LandValue,land_value_range, BuildingValue,building_value_range,
TotalValue,SalePrice,date_transformed,YearBuilt,total_rooms
from nashville_housing;


select * from new_nashville;
-- lets create a view of required columns 

-- spatial analysis  using city , area , tax district 


UPDATE new_nashville 
SET  Property_city= 'Unmentioned_city'
WHERE Property_city ='others' ;

-- 1
select Property_city, count(*) popular_city from new_nashville
group by 1
order by  popular_city desc; 
-- madison is most popular


-- lets check the area individually
select Property_city, property_area, count(*) no_of_houses
from new_nashville
group by 1,2
order by Property_city, no_of_houses desc; 
-- these have 828 categories so probabaly need to be summarised 
-- a histogram kind can be created 

-- trategy for tomorrow -- do top 3 areas in for each landue in each city 






-- what are the most common landuse customers 
select landuse, count(*) as use_wise_customer
from new_nashville 
group by 1
order by use_wise_customer desc;

--  for specific landuse what is the prefered city and district 



select LandUse, Property_city, count(*),
row_number() over(partition by LandUse order by count(*) desc ) as rn
from new_nashville
group by 1,2
;
-- for single family (single houses single family) which are mostly the occupants the madison city >old hickry > goodstvill
-- for duplex type of homes (two familes ) whre the madison> nashville> old hickry 
-- zerolot line (which has less boundary) madison> nashville>goodsville
-- vacant residential land- nashvill>madison> old rickry 
-- for common buildings like church   goodsville> madison> 
-- parsonage  nashville -- office madison respectively,
--  club union is madison 
-- green belt region is old hrickry so probably
-- madison and hickory are actually prefered destimations 






-- time series combined wiht spatial
-- question with years what been the demand for  houses city wise and further landuse wise 
-- 1
select year(date_transformed) as year, count(*) as city_pop
from new_nashville
group by 1;
-- there has been an upward trend from 2013 to 2016 and then decending 
-- what the % inc and dec in demand 

with cte as (select year(date_transformed) as year, count(*) as city_pop,
lag(count(*)) over(order by year(date_transformed)) as previous_years_pop
from new_nashville
group by 1)
select year,
((city_pop- previous_years_pop)/previous_years_pop)*100 as percent_change
 from cte;





-- seen the change in demand city wise 
-- 2
select Property_city,year(date_transformed) as year, count(*) as city_pop,
rank() over(partition by Property_city order by year(date_transformed)) as ran
from new_nashville
group by 1,2;
 
 
 
 -- 3
with city_demand as 
(select Property_city,year(date_transformed) as year, count(*) as city_pop,
lag(count(*)) over(partition by Property_city order by year(date_transformed)) prev_yr_pop,
rank() over(partition by Property_city order by year(date_transformed)) as ran
from new_nashville
group by 1,2)
select  Property_city, year,((city_pop-prev_yr_pop)/prev_yr_pop)*100
from city_demand;


-- combinign this with landuse to see which segment hasseen more demand 
-- 4
with landuse_segment as 
(select landuse,year(date_transformed) as year, count(*) as pop_segment,
lag(count(*)) over(partition by landuse order by year(date_transformed)) prev_popularity,
rank() over(partition by landuse order by year(date_transformed)) as ran
from new_nashville
group by 1,2)
select  landuse, year,((pop_segment-prev_popularity)/prev_popularity)*100 as percent_change
from landuse_segment;







-- land area analuysis 
-- for each land use category what is the prefered area and in each city what kind of are is mostly available 

-- lets see count of each category 
select land_area_category, count(*) as num_each_categ
from nashville_housing 
group by land_area_category
order by num_each_categ desc;
-- very small > small > medium


use amazon;
-- link bw city and lang area as we already know that madison and hickry followed by goods ville and nachville are most preferred 
-- hypothesis probably due to easy availability of small land which is low price or due to availability of public buildings adn facilitis 

select land_area_category,Property_city, count(*) as cnt ,
row_number() over( partition by land_area_category order by count(*) desc )
from nashville_housing 
group by 1,2

;
-- in madison very small_lands are mostly available which implice prices are resonable for single families 
-- foll by this for vary small cat old hickry > nashville and > goodsville are most prefered 




-- lets see relation with land use

select distinct  land_area_category,LandUse, count(*)  as cnt
from nashville_housing 
group by 1,2
order by land_area_category, cnt desc;

-- most small , very small are used by single family whichis obvious 
-- form of dwelling setup which accommodates two distinct living spaces within a single building. 
	-- This variety of multi-family residence serves as an intermediary between an apartment and a traditional house,
-- zero lot line in which the structure comes up to, or very near to, the edge of the property line
--  even offices , parsonage and union hall are prefered in very small area as opposed to single family which also has a very large area so not direct link
-- many vacant residiantial land are 


with landarea_segment as 
(select land_area_category,year(date_transformed) as year, count(*) as area_segment,
lag(count(*)) over(partition by land_area_category order by year(date_transformed)) prev_area_popularity,
rank() over(partition by land_area_category order by year(date_transformed)) as ran
from new_nashville
group by 1,2)
select  land_area_category, year,((area_segment-prev_area_popularity)/prev_area_popularity)*100 as percent_change
from landarea_segment;







-- land use vs land value range  

with cte as (
select distinct LandUse,  land_value_range, count(*),
row_number() over(partition by landuse order by  count(*) desc ) as rn
from nashville_housing 
group by 1,2
) 
select * from cte where rn between 1 and 2
;
-- here the low vlaue is prefered by single family adn then below moderate , duplex is the third most prefered wiht prices below_moderate 
-- in genral the land value is nostly in low range taht too in genral service district  whichis below 25k 




with landvaluechange as
(select Property_city , year(date_transformed) as year, 
avg(LandValue) as avg_land_value
from new_nashville 
group by 1,2)

select Property_city , year, 
((avg_land_value - lag(avg_land_value) over(partition by Property_city order by year))/lag(avg_land_value)
 over(partition by Property_city order by year))* 100 as percent_change
from landvaluechange;


-- adding land use 


with landvaluechange as
(select LandUse , year(date_transformed) as year, 
avg(LandValue) as avg_land_value_by_use
from new_nashville 
group by 1,2)

select LandUse , year, 
((avg_land_value_by_use - lag(avg_land_value_by_use) over(partition by LandUse order by year))/lag(avg_land_value_by_use)
 over(partition by LandUse order by year))* 100 as percent_change
from landvaluechange;




-- link between city and building value with the buildign value range 
select 
Property_city,
building_value_range , count(*) as num_buildings,
row_number() over (partition by building_value_range order by count(*) desc ) as rn
from new_nashville group by 1,2
;
-- moderate prices in madison > nashville > old hickry in above moderate building proces madison and goodsville and old hickry have max bukdings in above moderate prices
-- in above  moderate prices madison > goodsvill> old hickry 
-- in fact high buildign prices in madison > old ickry and goodsville are preferred 
-- belo moderate coincidently have less number of buildings may be due to less rooms or high land value or less availabiliuty of public spaces etc 

-- the above forces me to check for what purpsoe the bildignds are needed may be insights can be derived and further why belo moderate are not in demand despite low buildign proces 

select 
LandUse, building_value_range , count(*) , 
row_number() over(partition by building_value_range)
from new_nashville 
group by 1,2  ;


-- for moderate prices single families > duplex> 
-- for abive moderate price range single family> duplex > chirch 
-- for below moderate prices only single family and zero lot liem are occupants so probably more strategies for them can be made to target them 
-- high prices are for single fam > vacant residental lanf and office buildign and residentail comb
--  public like  residential combo, office  have high buildign value , church  has abive moderate value , 
-- split class, vacant residentioal lanf have vey high  buildign prices along wiht 4 single family also 




with buildingvaluechange as
(select Property_city , year(date_transformed) as year, 
avg(BuildingValue) as avg_buldng_value
from new_nashville 
group by 1,2)

select Property_city , year, 
((avg_buldng_value - lag(avg_buldng_value) over(partition by Property_city order by year))/lag(avg_buldng_value)
 over(partition by Property_city order by year))* 100 as percent_change
from buildingvaluechange;








-- total value 
-- lets see the value colum as it might have direct link cus here proces are only in lakhs and also in 100s and 1000s so wht it means ?

select  distinct TaxDistrict, 
avg(TotalValue) over( partition by TaxDistrict) as avg_total_value_districtwise,
max(TotalValue) over( partition by TaxDistrict) as max_total_value_districtwise,
min(TotalValue) over( partition by TaxDistrict) as min_total_value_districtwise
from nashville_housing
 order by avg_total_value_districtwise desc;
 
 -- in goodsvill avg total value is more foll by genreal service and urbam service 
 
select  distinct  Property_city,
avg(TotalValue) over( partition by Property_city) as avg_total_value_categorywise,
max(TotalValue) over( partition by Property_city) as max_total_value_categorywise,
min(TotalValue) over( partition by Property_city) as min_total_value_categorywise
from nashville_housing
 order by avg_total_value_categorywise desc;
 
 -- avg value is max in old hickry > goodsville> joletown 
 -- madison > nashvill > white creek have least avg value probably thats why preffered 
 




select  distinct  Property_city, land_area_category,
avg(TotalValue) over( partition by Property_city,land_area_category) as avg_total_value_categorywise,
max(TotalValue) over( partition by Property_city,land_area_category) as max_total_value_categorywise,
min(TotalValue) over( partition by Property_city,land_area_category) as min_total_value_categorywise
from nashville_housing
 order by  avg_total_value_categorywise desc;

--  joetown small has highest totalvalue
-- madison very large > madison very large and beyond
-- old hickry even small has higher avg toatl value foll by medium little absurdity
-- white creek very small has lowest avg total val 





select  distinct TaxDistrict, land_area_category, 
avg(TotalValue) over( partition by TaxDistrict, land_area_category) as avg_total_value_categorywise,
max(TotalValue) over( partition by TaxDistrict, land_area_category) as max_total_value_categorywise,
min(TotalValue) over( partition by TaxDistrict, land_area_category) as min_total_value_categorywise
from nashville_housing
 order by avg_total_value_categorywise desc;
 
 -- in genral service district avg toaal in large is 56k

select total_rooms,  TotalValue from new_nashville 
order by totalvalue desc;
-- 12 has highest value however followed by 7 and 10 which shows not direct link probably location and ammenities play more imp role 
-- so lets combine this with city and area


-- lets see top 3 results in each city 
with cte as (select Property_city, total_rooms, TotalValue,
row_number() over(partition by Property_city order by totalvalue desc ) as rn
from new_nashville 
group by 1,2,3)
select * from cte where rn in (1,2,3)
;



-- lets see  sale price 



select distinct TaxDistrict, 
avg(SalePrice) over(partition by TaxDistrict) as average_price,
min(SalePrice) over(partition by TaxDistrict) as min_price,
max(SalePrice) over(partition by TaxDistrict) as max_price 
from nashville_housing
order by average_price desc;

-- min sale price is 100 max is 1700000 
-- district wise a avg is max in goodsville and range is ,ax in general service district 

-- city wise 
select distinct Property_city ,
avg(SalePrice) over(partition by Property_city) as average_price,
min(SalePrice) over(partition by Property_city) as min_price,
max(SalePrice) over(partition by Property_city) as max_price 
from nashville_housing
order by average_price desc;
-- goodlettsvillle > old hickry > wite has high average price 
-- madison adn nashville have low which are the most prefereerd so prob low sale price has better takers 









select SalePrice , land_area_category, 
count(*) as num 
from nashville_housing 
group by 1,2
order by 2, 1 desc ;      
-- while ordering  we see that  price for small was the highest and then large and then very small 
-- so probably the area alone is not playing enough role 





-- temporal analysis saleprice tend  over the years 

select date_transformed, year(date_transformed) as yr ,SalePrice,
sum(SalePrice) over(partition by year(date_transformed) order by date_transformed ) as yrsale
from new_nashville
;


-- lets pivot 
with cte as (
select date_transformed, year(date_transformed) as yr ,SalePrice,
sum(SalePrice) over(partition by year(date_transformed) order by date_transformed ) as yrsale,
row_number() over (partition by year(date_transformed) order by date_transformed ) as rn
from new_nashville
) 
select sum(case 
when yr=2013 then SalePrice 
end) as total_2013,
sum(case 
when yr=2014 then SalePrice 
end) as total_2014,
sum(case 
when yr=2015 then SalePrice 
end) as total_2015,
sum(case 
when yr=2016 then SalePrice 
end) as total_2016
from cte;
