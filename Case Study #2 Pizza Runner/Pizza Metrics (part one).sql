-----------A. Pizza Metrics
--1) How many pizzas were ordered?
select count(order_id) number_of_orders
from customer_orders
--2) How many unique customer orders were made?
select count(distinct order_time) number_of_customers
from customer_orders
--3) How many successful orders were delivered by each runner?
select runner_id,count(duration) Successful_run
from runner_orders
WHERE distance !=0
group by runner_id
--4) How many of each type of pizza was delivered?
select pizza_name,count(distance) delivered_pizza
from runner_orders RO
join customer_orders CO
on RO.order_id = CO.order_id
join pizza_names P
on CO.pizza_id = P.pizza_id
where distance!= 0
group by pizza_name
--5) How many Vegetarian and Meatlovers were ordered by each customer?
select customer_id,PN.pizza_name,count(distance) delivered_pizza
from customer_orders CO
join pizza_names PN 
on Co.pizza_id = PN.pizza_id
join runner_orders RO
on CO.order_id = RO.order_id
group by customer_id,PN.pizza_name
--6) What was the maximum number of pizzas delivered in a single order?
select top 1 order_id,number_of_pizzas
from (select order_id, count(order_id) number_of_pizzas from customer_orders group by order_id )as newTab
order by number_of_pizzas desc
--7) For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select customer_id ,sum(case when c.exclusions!=' ' OR c.extras<>' ' then 1 else 0 end ) at_least_1_change,
  SUM(
    CASE WHEN c.exclusions = ' ' AND c.extras = ' ' THEN 1 
    ELSE 0
    END) AS no_change
from customer_orders c
join runner_orders RO
on c.order_id=RO.order_id
where distance!=0
group by customer_id
order by customer_id

--8) How many pizzas were delivered that had both exclusions and extras?
select customer_id,Sum(Case When Co.extras<>' ' and Co.exclusions<>' ' then 1 else 0 end) number_of_both_exclusions 
from customer_orders CO
join runner_orders RO
on RO.order_id = CO.order_id
where distance!=0
group by customer_id
order by customer_id
--9) What was the total volume of pizzas ordered for each hour of the day?
SELECT DATEPART(HOUR, order_time) AS hour_of_day, COUNT(order_id) AS pizza_count
FROM customer_orders
GROUP BY DATEPART(HOUR, order_time);
--) What was the volume of orders for each day of the week?
SELECT 
  FORMAT(DATEADD(DAY, 2, order_time),'dddd') AS day_of_week, -- add 2 to adjust 1st day of the week as Monday
  COUNT(order_id) AS total_pizzas_ordered
FROM customer_orders
GROUP BY FORMAT(DATEADD(DAY, 2, order_time),'dddd');

