--B. Runner and Customer Experience
--1) How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select DATEPART(WEEK,registration_date) number_of_week ,COUNT(runner_id) AS runner_signup
from runners
group by DATEPART(WEEK,registration_date)
--2) What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
select AVG(pickup_minutes) average_time
from (
select DATEDIFF(MINUTE, CO.order_time, RO.pickup_time) AS pickup_minutes
from customer_orders CO
join runner_orders RO
on Co.order_id = RO.order_id
where distance !=0
group by CO.order_id,Co.order_time,RO.pickup_time) as newTab

--3) Is there any relationship between the number of pizzas and how long the order takes to prepare?
select pizza_order,AVG(pickup_minutes) average_time
from (
select Co.order_id,COUNT(CO.order_id) AS pizza_order, DATEDIFF(MINUTE, CO.order_time, RO.pickup_time) AS pickup_minutes
from customer_orders CO
join runner_orders RO
on Co.order_id = RO.order_id
where distance !=0
group by CO.order_id,Co.order_time,RO.pickup_time) as newTab
group by pizza_order
--4) What was the average distance travelled for each customer?
select customer_id, avg(distance) average_distance
from customer_orders CO
join runner_orders RO
on Co.order_id = RO.order_id
where distance!=0
group by CO.customer_id
--5) What was the difference between the longest and shortest delivery times for all orders?
select max(duration) - min(duration) As 'difference between the longest and shortest'
from runner_orders
where distance!=0
--6) What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT 
  RO.runner_id, 
  CO.customer_id, 
  CO.order_id, 
  COUNT(CO.order_id) AS pizza_count, RO.distance, RO.duration,
  ROUND((RO.distance/RO.duration * 60), 2) AS avg_speed
FROM runner_orders AS RO
JOIN customer_orders AS CO
  ON RO.order_id = CO.order_id
WHERE distance != 0
GROUP BY RO.runner_id, CO.customer_id, CO.order_id, RO.distance, RO.duration
ORDER BY CO.order_id; 

--7) What is the successful delivery percentage for each runner?
SELECT 
  runner_id, 
  ROUND(100 * SUM(
    CASE WHEN distance = 0 THEN 0
    ELSE 1 END) / COUNT(*), 0) AS success_perc
FROM runner_orders
GROUP BY runner_id;