Create database superstore

use superstore
select top 10 *
from global_superstore

-- Drop unspecified column
Alter table global_superstore
drop column 记录数

-- Alter Order_Date and Ship_Date column datatype
Alter table global_superstore
Alter column Order_Date Date

Alter table global_superstore
Alter column Ship_Date Date

-- Total sales, total profit, quantity by product category
use superstore
select Category, 
        sum(sales) as [Total Sales], 
        round(sum(Profit),2) as [Total Profit],
        sum(quantity) as [Total Quantity]
from global_superstore
group by Category

-- Total sales and total profit by sub-category

select Category,
        Sub_Category,
        sum(Sales) as [Total Sales],
        round(sum(profit),2) as [Total Profit]
from global_superstore
group by Category, Sub_Category
order by Category, [Total Sales] desc
 
-- Count the number of customers, orders, sales in each country
select Country, 
        count (distinct Customer_ID) as [Total Customers],
        count(Distinct Order_ID) as [Total Order],
        sum(Sales) as [Total Sales],
        round(sum(Profit),2) as [Total profit]
from global_superstore
group by Country
order by [Total Sales] DESC, [Total profit] DESC

-- Order priority
select Order_Priority, count(distinct Order_ID) as [Total Order]
from global_superstore
group by Order_Priority 

-- Number of orders, total sales and average ship cost by order priority
select Order_Priority,
        count(distinct Order_ID) as [Total Order],
        sum(Sales) as [Total Sales],
        round(AVG(Shipping_Cost),2) as [Average Shipping Cost]
from global_superstore
group by Order_Priority

-- Sales, the number of orders, AOV by segment
SELECT Segment, 
        sum(Sales) as [Total Sales], 
        count (distinct Order_ID) as [Total Order],
        round(cast(sum(Sales) as float)/count(distinct Order_ID),2) as AOV
from global_superstore
group by Segment

--  Total orders by Discount
select Discount, count(Order_ID) as [Total order]
from global_superstore
group by Discount
Order by [Total order] DESC

-- Orders by market
select Market, count(Distinct Order_ID) as [Total Order]
from global_superstore
group by Market

-- Total customers, order, sales (revenue) and profits  each year
select Year, 
        count(distinct Customer_ID) as [Total Customer],
        count(distinct Order_ID) as [Total Order],
        sum(Sales) as [Total Sales],
        round(sum(Profit),2) as [Total Profit]
from global_superstore
group by Year
order by year

--Total Order by Weeknum
select weeknum as Weeknum,
        count(Distinct Order_ID) as [Total Order]
from global_superstore
group by weeknum
order by weeknum

-- Add Shipping day column
Alter table global_superstore
Add [Shipping Day] Int
Update global_superstore
set [Shipping Day] = DATEDIFF (day, Order_Date, Ship_Date)
 
-- Shipping days

select [Shipping Day],
        count(distinct Order_ID) as [Total Oder]
from (
    select order_ID,
        CASE
            when [Shipping Day] = 0 then 'Within the day'
            when [Shipping Day] between 1 and 2 then '1-2 days'
            when [Shipping Day] between 3 and 4 then '3-4 days'
            else 'Over 4 days'
        END as [Shipping Day]
    from global_superstore) as A
group by [Shipping Day]
order by [Total Oder]

-- Number of orders, average shippng cost by ship mode
select Ship_Mode,
        count(distinct Order_ID) as [Total Order],
        round(avg([Shipping Day]),2) as [Average Shipping Day],
        round(AVG(Shipping_Cost),2) as [Average Shipping Cost]
from global_superstore
group by Ship_Mode

-- Order by Order_Date Weekday and Category

With T1 as ( 
        select Category, order_ID, datepart(weekday, Order_Date) as Weekday
        from global_superstore
),

T2 as (
        select Category, Weekday, count (distinct order_ID) as [Total Order]
        from T1
        group by Weekday, Category
)

select Category, 
        CASE
                when Weekday = 1 then 'Sunday'
                when Weekday = 2 then 'Monday'
                when Weekday = 3 then 'Tuesday'
                when Weekday = 4 then 'Wednesday'
                when Weekday = 5 then 'Thursday'
                when Weekday = 6 then 'Friday'
                when Weekday = 7 then 'Saturday'
        END as Weekday,
        [Total Order]
from T2

use superstore
select distinct Customer_ID
from global_superstore

select Segment, Category, sum(Quantity) as [Total Quantity]
from global_superstore
group by Segment, Category

--Shipping days by category

select [Shipping Day],
        Category,
        count(distinct Order_ID) as [Total Oder]
from (
    select order_ID, Category,
        CASE
            when [Shipping Day] = 0 then 'Within the day'
            when [Shipping Day] between 1 and 2 then '1-2 days'
            when [Shipping Day] between 3 and 4 then '3-4 days'
            else 'Over 4 days'
        END as [Shipping Day]
    from global_superstore) as A
group by [Shipping Day], Category

--Customer segement and Ship_mode relationship
select Segment, Ship_Mode, count (distinct Order_ID) as [Total Order]
from global_superstore
group by Segment, Ship_Mode

-- Country that ranks in the 1st position in total revenue each quarter
with cte as (
        select Year(Order_Date) as Year, DATEPART(QUARTER, Order_Date) as Quarter, Country,
                Sum(Sales) over (partition by Country) as Total_Revenue
        from global_superstore
),

cte1 as (
        select *,
                rank () over (partition by Year, Quarter order by Total_Revenue) as Rank
        from cte
)

select distinct Year, Quarter, Country, Total_Revenue
from cte1
where Rank = 1
order by Year, Quarter