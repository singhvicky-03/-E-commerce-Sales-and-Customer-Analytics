use me;


-- Print all details of Orders which were placed by Customers whose ID is a multiple of 10, payment method by Payment with ID 4, 
-- shipped by Shipper with ID 3 and which are greater than 30,000 in order value.
-- Sort the result set in descending order of Customer ID.
select * from orders
where customerid %10=0 and paymentid=4 and shipperid =3 and 
total_order_amount>30000
order by customerid desc;

-- Identify and print top three months where the most number of orders were delivered across both the years 2020 and 2021.
-- Print Month Number, Month Name, followed by the order count.
-- Sort the result in descending order of Count.
select month(deliverydate) as mnumber ,monthname(deliverydate) as month_, count(*) as total_order from orders 
where year(deliverydate) in (2020,2021) 
group by mnumber, month_ 
order by total_order desc
limit 3;

-- Calculate the total spend across orders of customers whose full name consists of the letter 'a'.
-- Print Customer ID, Full Name and Total Spend.
-- Let the full name be combination of First Name and Last Name separated by a space.
-- Sort the result in ascending order of Customer ID.
-- If you see blank cells in the full name column that means you have concatenated a string with null.
-- For such cases just print the first name without any concatenation
select c.customerid, coalesce(concat(c.firstname,' ',c.lastname),c.firstname)as fullname, sum(o.total_order_amount) from customers as c
join orders as o on c.customerid=o.customerid
where concat(c.firstname,' ',c.lastname) like '%a%'
group by  c.customerid,fullname
order by c.customerid asc;

-- Write a query to get the order IDs of all the orders which were paid either using Credit card or debit card.
-- Print Order ID, Customer ID, Payment type and Total Order Amount.
-- (Replace Credit card with 'Credit' and Debit card with 'Debit' - Use REPLACE Function and not CASE WHEN).
-- Sort the result in ascending order of Order ID.
select o.orderid,o.customerid,
replace(replace(p.paymenttype,'credit card','credit'),'debit card','debit') as payment_type,o.total_order_amount from orders as o
join payments as p on o.paymentid=p.paymentid
where p.paymenttype in ('credit card','debit card')
order by o.orderid asc;

-- Write a query to find the Orders which were delivered exactly in 2 days.
-- Print Order Id, Customer ID, Order Date, Delivery Date and Total Order Amount for each of these orders.
-- Order your output in terms of Customer ID asc.
select customerid,orderid,orderdate,deliverydate , total_order_amount from orders
where timestampdiff(day,orderdate,deliverydate)=2
order by customerid asc;

-- Identify the top 5 categories which had the highest quantity of products ordered.
-- Print Category ID, Category Name and Corresponding Total Quantity.
-- Sort the result in descending order of Total Quantity.
select c.categoryid,c.categoryname,sum(od.quantity) as total_quantity from category as c
join products as p on c.categoryid=p.category_id 
join orderdetails as od on p.productid=od.productid
group by c.categoryid,c.categoryname
order by total_quantity desc; 

-- Get the sum of quantity shipped by each Shipper in each quarter of each year.
-- Print Year, Quarter, ShipperID, Company Name, Quantity Shipped.
-- Order your output in ascending order of the year.
-- For records with same year - sort them in ascending order of quarter, for records with the same quarter - sort them in descending order of Total Quantity.
-- Remember to consider the shipping date when getting the Year and Quarter information.
select year(o.shipdate) as year, quarter(o.shipdate) as quarter, s.shipperid , s.companyname, sum(od.quantity) as total_quantity from shippers as s 
join orders as o on s.shipperid=o.shipperid
join orderdetails as od on o.orderid=od.orderid
group by year,quarter, s.shipperid , s.companyname
order by year asc , quarter asc , total_quantity desc;

-- Calculate the average discount percentage on products of each brand belonging to the bakeware sub category.
-- Print Brand name and their average percentage discount in nearest integer value.(e.g. - 77.80 will be 78 and 77.10 will be 77)
-- DISCOUNT = ((MARKET_PRICE - SALE_PRICE)/MARKET_PRICE) X 100
-- Sort the result in desceding order of Average discount value.
select brand , round(avg(((market_price-sale_price)/market_price)*100)) as avg_discount from products
where sub_category in ('bakeware')
group by brand
order by avg_discount desc;

-- Write a query to find out the top 3 selling categories in 2020.
-- Print Category ID, Category name and the number of orders placed.
-- Order your output in descending order of number of order.
with categories_sell as
(select c.categoryid , c.categoryname ,od.orderid from category as c
join products as p on c.categoryid=p.category_id
join orderdetails as od on p.productid=od.productid
join orders as o on od.orderid=o.orderid
where year(o.orderdate)= 2020)select categoryid , categoryname , count(orderid) as cnt from categories_sell
group by categoryid , categoryname
order by cnt desc
limit 3 ;

-- Write a query to rank the products on the basis of highest selling price within each category.
-- If two Products has same selling price then ranking took alphabetically their name in consideration.
-- Prevent skipping of ranks.
-- Print ProductID, Product Name, CategoryID, Brand, Sale Price and Rank.
select productid , product, category_id,brand, sale_price ,dense_rank() 
over(partition by category_id order by sale_price desc , product asc) as rank_ from products;

-- Write a query to find the Total order amount in each year during the festive season.
-- (Consider festive season to be September,October and November months).
-- Print 2x2 matrix of year and total order amount.
-- Order your query based on ascending order of Year.
select year(orderdate) as year, sum(total_order_amount) as order_amount from orders 
where month(orderdate) in (9,10,11) 
group by year(orderdate)
order by year(orderdate) asc;

-- Write a query to identify customer IDs who have ordered only once and find out how many months back the order was placed from now.
-- Use timestampdiff to find the last ordered months ago
-- Print customer ID along with the number of months count.
-- Order your output in ascending order of Customer ID.
select customerid, timestampdiff(month,orderdate,now()) as months_ago from orders
group by customerid , months_ago
having count(orderid)=1
order by customerid asc;

-- print the products, orderid and productid which take the shipping time greater than 5 days 
-- order the output in asc order of order and productid
select o.orderid, p.productid, p.product , datediff(o.deliverydate,o.orderdate) as day_taken_to_ship from products as p 
join orderdetails as od on p.productid=od.productid 
join orders as o on o.orderid=od.orderid 
where datediff(o.deliverydate,o.orderdate) >= 5  
order by o.orderid asc, p.productid asc;

-- print the top 3 customers who order the most during each quater as each year summarize the output in year ,quater,name of customers who ordered most
-- name of customers who orders second most and third most let the name of customers separated by comma and spac
with topcust as
 (select year(orderdate) as year_ , quarter(orderdate) as quarter_ ,c.customerid ,concat(firstname, ' ',lastname)  as fullname, count(orderid) as num_order
 from orders as o
 join customers as c on o.customerid=c.customerid
 group by year_ ,quarter_ , fullname,c.customerid) ,
 topcust_ as
 (select *,  dense_rank() over(partition by year_,quarter_ order by num_order desc) as ranking
 from topcust ),
 topcust_2 as (
 select * from topcust_ 
 where ranking<=3),
 topcust_3 as (
 select year_,quarter_,ranking, group_concat(' ',fullname) as customers_name
 from topcust_2
 group by year_,quarter_,ranking)
 select year_,quarter_,
 max(case when ranking=1 then customers_name end) as rank_1,
 max(case when ranking=2 then customers_name end) as rank_2,
 max(case when ranking=3 then customers_name end) as rank_3
 from topcust_3
 group by year_,quarter_;
 













