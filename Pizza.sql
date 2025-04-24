create database pizza;
use pizza;

create table orders(
order_id int not null,
date date not null,
time time not null,
primary key(order_id));

create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id));

-- Basic:
-- Retrieve the total number of orders placed.
Select count(*) as num_of_orders from orders;

-- Calculate the total revenue generated from pizza sales.
select round(sum(price*quantity),2) as total_revenue from pizzas inner join order_details on order_details.pizza_id=pizzas.pizza_id;

-- Identify the highest-priced pizza.
select name,price from pizzas inner join pizza_types on pizza_types.pizza_type_id=pizzas.pizza_type_id order by price desc limit 1;

-- Identify the most common pizza size ordered.
select size,count(size) as Size_ordered from pizzas inner join order_details on order_details.pizza_id=pizzas.pizza_id 
group by size order by Size_ordered desc limit 5;

-- List the top 5 most ordered pizza types along with their quantities.
Select name, sum(quantity) as Quantity_count from order_details inner join pizzas on pizzas.pizza_id=order_details.pizza_id inner join 
pizza_types on pizza_types.pizza_type_id=pizzas.pizza_type_id group by name order by Quantity_count desc limit 5;

-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.
select category,sum(quantity) as Tot_quantity from pizzas inner join order_details on order_details.pizza_id=pizzas.pizza_id inner join 
pizza_types on pizza_types.pizza_type_id=pizzas.pizza_type_id group by category;

-- Determine the distribution of orders by hour of the day.
select count(order_id) as No_of_order,date,hour(time) as hourly from orders group by date,hourly;

-- Join relevant tables to find the category-wise distribution of pizzas.
select category, count(order_details_id) as distribution from pizza_types inner join pizzas on pizzas.pizza_type_id=pizza_types.pizza_type_id inner join
order_details on order_details.pizza_id=pizzas.pizza_id group by category;
-- or--
select category, count(name) from pizza_types group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
Select date,round(avg(order_details_id)) as avg_order from orders inner join order_details on order_details.order_id=orders.order_id group by date;

-- Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.pizza_type_id, sum(order_details.quantity*price) as tot_revenue from pizza_types inner join pizzas on pizzas.pizza_type_id=pizza_types.pizza_type_id inner join 
order_details on order_details.pizza_id=pizzas.pizza_id group by pizza_types.pizza_type_id order by tot_revenue desc limit 3;

Select * from order_details;
select * from pizzas;
Select * from orders;
Select * from pizza_types;

-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.
Select pizza_types.pizza_type_id, round(sum(order_details.quantity*price)/(select sum(price*order_details.quantity) from pizzas inner join
order_details on order_details.pizza_id=pizzas.pizza_id)*100,2) as revenue from pizza_types inner join pizzas on 
pizzas.pizza_type_id=pizza_types.pizza_type_id inner join order_details on order_details.pizza_id=pizzas.pizza_id group by
pizza_types.pizza_type_id order by revenue desc;

-- Analyze the cumulative revenue generated over time.
Select date,round(sum(revenue)over(order by date),2) as Cum_revenue from
(Select date,sum(order_details.quantity*price) as revenue from pizzas inner join order_details on order_details.pizza_id=pizzas.pizza_id
inner join orders on orders.order_id=order_details.order_id group by date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
Select name,category,revenue from
(Select name,category,revenue, rank () over (partition by category order by revenue desc) as rev_by_category from
(select pizza_types.category,pizza_types.pizza_type_id,pizza_types.name, sum(order_details.quantity*price) as revenue from pizza_types 
inner join pizzas on pizzas.pizza_type_id=pizza_types.pizza_type_id inner join order_details on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category,pizza_types.pizza_type_id,pizza_types.name) as cate) as cate2 where rev_by_category<=3;












