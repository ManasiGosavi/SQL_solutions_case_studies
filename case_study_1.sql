----------------------------------------------------------------------
--                    Data In Motion        
--            SQL Case Study 1: Tiny Shop Sales
--                Solutions by Manasi Gosavi
----------------------------------------------------------------------
----------------------------------------------------------------------


----------------------------------------------------------------------
-- 1) Which product has the highest price? Only return a single row.
----------------------------------------------------------------------

select                             /*|*/ select top 1 product_name,
	product_name,              /*|*/        price as highest_price
	price as highest_price     /*|*/ from
from                               /*|*/       products
	products                   /*|*/  order by price desc
where                              /*|*/
	price = (                  /*|*/
	select                     /*|*/
		MAX(price)         /*|*/
	from                       /*|*/
		products);         /*|*/

----------------------------------------------------------------------
 product_name | highest_price 
--------------+---------------
 Product M    |         70.00
----------------------------------------------------------------------


----------------------------------------------------------------------
-- 2) Which customer has made the most orders?
----------------------------------------------------------------------

with total_orders as (						
select
	c.first_name first_name,				
	c.last_name last_name,
	count(o.order_id) as number_of_orders	
from
	customers as c
join orders as o
		using (customer_id)
group by
	customer_id
)
select
	first_name,								
	last_name,
	number_of_orders
from
	total_orders							
where										
	number_of_orders = (
	select
		max(number_of_orders)
	from
		total_orders
    );

----------------------------------------------------------------------
 first_name | last_name | number_of_orders 
------------+-----------+------------------
 Jane       | Smith     |                2
 Bob        | Johnson   |                2
 John       | Doe       |                2
----------------------------------------------------------------------


----------------------------------------------------------------------
-- 3) What’s the total revenue per product?
----------------------------------------------------------------------

SELECT 
		p.product_name,	
		p.price,
		SUM(p.price*o.quantity) as total_revenue
FROM products p
join order_items o on p.product_id = o.product_id
group by p.product_name,p.price                            	
    
----------------------------------------------------------------------
 product_id | price | total_revenue 
------------+-------+---------------
 Product A  | 10.00 |         50.00
 Product B  | 15.00 |        135.00
 Product C  | 20.00 |        160.00
 Product D  | 25.00 |         75.00
 Product E  | 30.00 |         90.00
 Product F  | 35.00 |        210.00
 Product G  | 40.00 |        120.00
 Product H  | 45.00 |        135.00
         .      .             .
         .      .             .
----------------------------------------------------------------------
-- 4) Find the day with the highest revenue.
----------------------------------------------------------------------

With Higest_revenue_bydate as
(
select  p.product_name as product_name,
		sum(p.price*oi.quantity) as total_revenue,
		o.order_date as order_date
from products p join order_items oi on p.product_id = oi.product_id
join orders o on oi.order_id = o.order_id 
group  by product_name, order_date
)

select  order_date, 
		total_revenue
from Higest_revenue_bydate

where total_revenue = (select MAX(total_revenue) from Higest_revenue_bydate)


 order_date | revenue_per_date 
------------+------------------
 2023-05-16 |           210.00
 2023-05-11 |           210.00


----------------------------------------------------------------------
-- 5) Find the first order (by date) for each customer.
----------------------------------------------------------------------

select 
 c.first_name as first_name,
 c.last_name as last_name,
 c.customer_id as cust_id,
 MIN(o.order_date) as First_date

 from customers c join orders o on  c.customer_id = o.customer_id
 group by first_name,last_name,c.customer_id
 order by c.customer_id

--------------------------------------------------
first_name|	last_name 	|cust_id  |	First_date
--------------------------------------------------
John			Doe 	    1		01-05-2023
Jane			Smith	    2		02-05-2023
Bob			Johnson	    3		03-05-2023
Alice			Brown	    4		07-05-2023
Charlie			Davis	    5		08-05-2023
Eva			Fisher	    6		09-05-2023
George			Harris	    7		10-05-2023
Ivy			Jones	    8		11-05-2023
Kevin			Miller	    9		12-05-2023
Lily			Nelson	   10		13-05-2023
Oliver			Patterson  11	        14-05-2023
Quinn			Roberts	   12		15-05-2023
Sophia			Thomas	   13		16-05-2023



----------------------------------------------------------------------
-- 6) Find the top 3 customers who have ordered the most distinct products
----------------------------------------------------------------------

 select
 top 3 o.customer_id as customer_id,
 COUNT(DISTINCT oi.product_id) as Dist_prod
 from orders o join order_items oi on o.order_id = oi.order_id
 group by customer_id


 customer_id |   Dist_prod 
-------------+------------
           1 |           3
           2 |           3
           3 |           3


----------------------------------------------------------------------
-- 7) Which product has been bought the least in terms of quantity?
----------------------------------------------------------------------

 WITH least_bought as
(
	select 
		product_id,
		SUM(quantity) over(partition by product_id ) as least_brought_prod
	from 
		order_items
) 

select  
	p.product_name AS Product_Name,
	least_brought_prod
from  
	least_bought  
	join products p 
	on least_bought.product_id = p.product_id
where least_brought_prod = (
			   select min(least_brought_prod) 
			   from least_bought)
group by Product_Name, least_bought.least_brought_prod


 product_name | least_brought_prod 
------------+--------------+--------------
 Product D    |            3
 Product E    |            3
 Product G    |            3
 Product H    |            3
 Product I    |            3
 Product K    |            3
 Product L    |            3


----------------------------------------------------------------------
-- 8) What is the median order total?
----------------------------------------------------------------------

WITH order_total as (
	select o.order_id, 
	sum(p.price*oi.quantity) as total
from 
	orders o join 
	order_items oi on o.order_id = oi.order_id join 
	products p on oi.product_id=p.product_id
group by o.order_id
)
select 
	PERCENTILE_CONT(0.5) within group (order by total) over () as Median_order_total
from order_total


 median_order_total 
--------------------
              112.5


----------------------------------------------------------------------
-- 9) For each order, determine if it was ‘Expensive’ (total over 300), ‘Affordable’ (total over 100), or ‘Cheap’.
----------------------------------------------------------------------

WITH ALL_orders as (
	select oi.order_id,
	SUM(oi.quantity * p.price) as Total_Cost
from 
	order_items oi join 
	products p on oi.product_id = p.product_id
group by oi.order_id
)

Select 
	order_id as Order_No,
	Total_Cost,

CASE WHEN Total_Cost >300 THEN 'Expensive'
	 WHEN Total_Cost >100 AND Total_Cost <= 300 THEN 'Affordable'
	 ELSE 'Cheap'
END AS Order_Type
from ALL_orders
order by Order_No


 Order_No | Total_Cost | Order_Type 
----------+-------------+----------------
        1 |       35.00 | Cheap
        2 |       75.00 | Affordable
        3 |       50.00 | Cheap
        4 |       80.00 | Affordable
        5 |       50.00 | Cheap
        6 |       55.00 | Affordable
        7 |       85.00 | Affordable
        8 |      145.00 | Expensive
        9 |      140.00 | Expensive
       10 |      285.00 | Expensive
       11 |      275.00 | Expensive
       12 |       80.00 | Affordable
       13 |      185.00 | Expensive
       14 |      145.00 | Expensive
       15 |      225.00 | Expensive
       16 |      340.00 | Expensive


----------------------------------------------------------------------
-- 10) Find customers who have ordered the product with the highest price.
----------------------------------------------------------------------

WITH MAX_Price_prod as (

select 
	oi.order_id,
	o.customer_id,
	c.first_name,
	c.last_name,
	MAX(p.price) over(partition by p.product_id order by p.product_id) as Highest_prod_range 
from 
	products p 
	join order_items oi on p.product_id=oi.product_id
	join orders o on oi.order_id = o.order_id
	join customers c on o.customer_id = c.customer_id
)

select 
	customer_id,
	first_name,
	last_name,
from 
	MAX_Price_prod
where 
	Highest_prod_range =	(
				select MAX(Highest_prod_range
				) from MAX_Price_prod)
    
 customer_id | first_name | last_name 
-------------+------------+-----------
          13 | Sophia     | Thomas
           8 | Ivy        | Jones
           
           
