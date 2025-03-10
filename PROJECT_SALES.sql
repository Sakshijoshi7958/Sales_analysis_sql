#Retrieve the total number of orders placed.

select COUNT(*) as total_orders from orders;

#Calculate the total revenue generated from pizza sales.
SELECT round(sum(price*quantity),2) as revenue FROM pizzas
join order_details
ON pizzas.pizza_id = order_details.pizza_id;

#Identify the highest-priced pizza.
SELECT pizzas.price, pizza_types.name FROM pizza_types
JOIN pizzas
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price desc
limit 1;

#Identify the most common pizza size ordered.
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS ordercount
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY SIZE
ORDER BY ordercount DESC
LIMIT 1;

#List the top 5 most ordered pizza types along with their quantities.
SELECT pizza_types.name,sum(order_details.quantity) AS quantity
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id 
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

#Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pizza_types.category, sum(order_details.quantity) as quantitycount FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY quantitycount DESC;


#Determine the distribution of orders by hour of the day.
SELECT HOUR(order_time),count(order_id) FROM orders
GROUP BY HOUR(order_time);


#Join relevant tables to find the category-wise distribution of pizzas.
SELECT category,COUNT(name) FROM pizza_types
GROUP BY category;

#Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(quantity_sum),0) FROM
(SELECT orders.order_date ,SUM(order_details.quantity) AS quantity_sum FROM orders
JOIN order_details
ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) as order_per_day;


#Determine the top 3 most ordered pizza types based on revenue.
SELECT pizza_types.name, sum(order_details.quantity*pizzas.price) AS revenue
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
group by pizza_types.name ORDER BY revenue DESC
LIMIT 3;

# Calculate the percentage contribution of each pizza type to total revenue.
SELECT pizza_types.category,round(SUM(pizzas.price*order_details.quantity)/(SELECT round(sum(price*quantity),2) FROM pizzas
join order_details
ON pizzas.pizza_id = order_details.pizza_id)*100,2)
AS revenue FROM pizzas
JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category order by revenue desc;


# Analyze the cumulative revenue generated over time.
SELECT SUM(revenue) over(order by order_date) as cum_revenue FROM
(SELECT orders.order_date,ROUND(SUM(order_details.quantity*pizzas.price),2) AS revenue FROM pizzas
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id 
JOIN orders ON order_details.order_id = orders.order_id
group by orders.order_date) as SALES;


# Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT name, revenue FROM
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn from
(SELECT pizza_types.category,pizza_types.name, SUM(order_details.quantity*pizzas.price) as revenue
FROM pizza_types JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category,pizza_types.name) AS a) as b WHERE rn <= 3;


