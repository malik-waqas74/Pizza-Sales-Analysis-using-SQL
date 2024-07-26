--Created Database
CREATE DATABASE pizza_base
use pizza_base

SELECT * FROM pizzas
SELECT * FROM pizza_types

--Applied some basic  settings on the data from the csv files..
--Making relationship b/w pizzas and pizztypes table
ALTER TABLE pizzas 
ADD FOREIGN KEY( pizza_type_id)references pizza_types(pizza_type_id)

--Making relation b/w order_details and pizzas table
ALTER TABLE order_details 
ADD FOREIGN KEY( pizza_id)references pizzas(pizza_id)
--Making relation b/w order_details and orders table
ALTER TABLE order_details
ADD FOREIGN KEY(order_id)references orders(order_id)

-------------------Performing Questionare--------------
--Basic:
--Retrieve the total number of orders placed.
SELECT COUNT(order_id) as Total_Orders FROM orders

--Calculate the total revenue generated from pizza sales.
SELECT (Sum(quantity * pizzas.price)) AS TOTAL_REVENUE_$
FROM pizzas inner join 
order_details on order_details.pizza_id = pizzas.pizza_id

--Identify the highest-priced pizza.

SELECT top(1) pizza_types.name,pizzas.price as PRICE
from pizza_types
inner join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
order by pizzas.price desc


--Identify the most common pizza size ordered.
SELECT count(distinct order_details.order_id)as Total_Orders, sum(order_details.quantity) as Total_Sold,pizzas.size from pizzas
inner join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizzas.size order by Total_Sold desc


--List the top 5 most ordered pizza types along with their quantities.
SELECT top(5) SUM(order_details.quantity) as Total,pizza_types.name from pizzas
inner join order_details on order_details.pizza_id = pizzas.pizza_id
inner join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name order by Total desc


--Intermediate:
--Join the necessary tables to find the 
--total quantity of each pizza category ordered.

--looking for categories
select distinct category from pizza_types
--checking for categories with the pizzas
select category,size,pizza_id as Pizza_Name
from pizzas
inner join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id

-- Now Main Task--- Categories with ordered quantity

SELECT sum(quantity)as Total_Ordered,pizza_types.category from pizzas
inner join order_details
on order_details.pizza_id = pizzas.pizza_id
inner join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category

--Determine the distribution of orders by hour of the day.

SELECT DATEPART(hour,orders.time)  as 'hour of the day',
count (order_id)as 'Total Orders'
from orders
group by datepart(hour,orders.time)
order by [Total Orders]

--Join relevant tables to find the category-wise distribution of pizzas.
-- Solution.................
SELECT category, count (distinct pizza_type_id) as 'No of Pizzas' 
from pizza_types
group by category
order by [No of Pizzas]

--Group the orders by date and calculate the average number of pizzas ordered per day.
--firstly get the all orders on one day
-- then extract the orders from the given orders in second query
SELECT round(avg(quantity),0) as Average_Orders from 
(SELECT orders.date, sum(order_details.quantity) as quantity
from order_details
inner join orders 
on orders.order_id = order_details.order_id
group by orders.date) as order_quantity;

--Determine the top 3 most ordered pizza types based on revenue.
--Solution..............
SELECT top(3) Sum(order_details.quantity * pizzas.price) AS TOTALSOLD,pizza_types.name
FROM pizzas inner join 
order_details on order_details.pizza_id = pizzas.pizza_id
inner join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name order by TOTALSOLD desc

--Advanced:
--Calculate the percentage contribution of each pizza type to total revenue.
--Solution.............................
--merging of the two complex queries..
--one gets revenue based on the category
--second get total revenue and applied divsion b/w both
SELECT sum(quantity)as Total_Ordered,
pizza_types.category,(sum(quantity * pizzas.price))/
(SELECT (Sum(quantity * pizzas.price)) AS TOTAL_REVENUE_$
FROM pizzas inner join 
order_details on order_details.pizza_id = pizzas.pizza_id
) *100 as 'Revenue'
from pizzas
inner join order_details
on order_details.pizza_id = pizzas.pizza_id
inner join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category
order by [Revenue] desc


--Analyze the cumulative revenue generated over time.
--Solution.........................
--firstly calculated all revenue from day by day
--secondly extract it on the bases of sales 
-- added the total sales day by day as Cumolative revenue
SELECT Sold_Date, sum(Total_Sales) 
over(order by Sold_date) as cum_Revenue 
from
(SELECT orders.date as Sold_Date,sum(quantity*price) as Total_Sales
from order_details
inner join pizzas on
pizzas.pizza_id = order_details.pizza_id
inner join orders on
orders.order_id = order_details.order_id
group by orders.date) as Sales;


--Determine the top 3 most ordered pizza types based on revenue for each pizza category.
--Solution...............................
SELECT sum(quantity)as Total_Ordered,
pizza_types.name,(sum(quantity * pizzas.price)) as 'Revenue'
from pizzas
inner join order_details
on order_details.pizza_id = pizzas.pizza_id
inner join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name
order by [Revenue] desc






