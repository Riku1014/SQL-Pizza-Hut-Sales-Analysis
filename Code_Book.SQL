-- Create Database
create database pizza_sales

-- To use the Database
USE pizza_sales;

-- Checking All tables
select *  from order_details;
select *  from orders;
select *  from pizza_types;
select *  from pizzas;

-- Describe the tables
DESCRIBE order_details;
DESCRIBE orders;
DESCRIBE pizza_types;
DESCRIBE pizzas;

-- Retrieve the Total number of Orders Placed
select count(order_id) as Total_orders from orders;

-- Calculate the total revenue generated from pizzas sale
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS Total_sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
-- Identify the highest Price Pizza
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Identify the most comman pizza size ordered
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- List the top 5 most ordered Pizza types along with their Quantites.
SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS Order_Quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Order_Quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered
 SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS Quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Quantity DESC;

-- Determine the distribution of the orders by hour of the day.
SELECT 
    HOUR(time) AS Order_time, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(time);

-- Join relevant tables to find the category-wise Distribution of pizzas.
select category, count(name) from pizza_types
group by category;

-- Rename the Date Colum of orders Table 
ALTER TABLE orders 
CHANGE date order_date text;
 
-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(Quantity), 0) AS Avg_Pizzas_ordered_per_Day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS Quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_Quantity;

-- Determine the top 3 most Ordered Pizza types based on revenue.
SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Revenue DESC
LIMIT 3;

-- Calculate the percentage Contribution of each pizza type of total revenue.
SELECT 
    pizza_types.category, 
    ROUND(
        SUM(order_details.quantity * pizzas.price) / 
        (SELECT SUM(order_details.quantity * pizzas.price) FROM order_details JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100, 2
    ) AS revenue
FROM 
    pizza_types 
JOIN 
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN 
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 
    pizza_types.category 
ORDER BY 
    revenue DESC ;

-- Analyze the Cumulative Revenue Generated Over Time.
select order_date,
sum(revenue) over(order by order_date) as cum_revenue
from
(select orders.order_date,
sum(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date) as Sales;

-- Determine The Top 3 Most Ordered Pizza Types Based on Revenue for Each Pizza Category
SELECT 
    category, 
    name, 
    revenue, 
    RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS ranks
FROM 
    (SELECT 
         pizza_types.category, 
         pizza_types.name, 
         SUM(order_details.quantity * pizzas.price) AS revenue
     FROM 
         pizza_types 
     JOIN 
         pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id 
     JOIN 
         order_details ON order_details.pizza_id = pizzas.pizza_id 
     GROUP BY 
         pizza_types.category, pizza_types.name
    ) AS Sales
ORDER BY 
    category, ranks;
