# 🍕 Case Study #2 Pizza Runner

## Solution - B. Runner and Customer Experience

### 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

````sql
select DATEPART(WEEK,registration_date) number_of_week ,COUNT(runner_id) AS runner_signup
from runners
group by DATEPART(WEEK,registration_date)
````

**Answer:**

|number_of_week|runner_signup|
|---|---|
|1|2|
|2|1|
|3|1|

- On Week 1 of Jan 2021, 2 new runners signed up.
- On Week 2 and 3 of Jan 2021, 1 new runner signed up.

### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

````sql
select AVG(pickup_minutes) average_time
from (select DATEDIFF(MINUTE, CO.order_time, RO.pickup_time) AS pickup_minutes
from customer_orders CO
join runner_orders RO
on Co.order_id = RO.order_id
where distance !=0
group by CO.order_id,Co.order_time,RO.pickup_time) as newTab
````

**Answer:**

|average_time|
|---|
|16|

- The average time taken in minutes by runners to arrive at Pizza Runner HQ to pick up the order is 16 minutes.

### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

````sql
select pizza_order,AVG(pickup_minutes) average_time
from (
select Co.order_id,COUNT(CO.order_id) AS pizza_order, DATEDIFF(MINUTE, CO.order_time, RO.pickup_time) AS pickup_minutes
from customer_orders CO
join runner_orders RO
on Co.order_id = RO.order_id
where distance !=0
group by CO.order_id,Co.order_time,RO.pickup_time) as newTab
group by pizza_order
````

**Answer:**
|pizza_order|average_time|
|---|---|
|1|12|
|2|16|
|3|30|

- There is a relationship between the number of pizzas and how long the order takes to prepare.

- On average, a single pizza order takes 12 minutes to prepare.
- An order with 3 pizzas takes 30 minutes at an average of 10 minutes per pizza.
- It takes 16 minutes to prepare an order with 2 pizzas which is 8 minutes per pizza — making 2 pizzas in a single order the ultimate efficiency rate.

### 4. Is there any relationship between the number of pizzas and how long the order takes to prepare?

````sql
select customer_id, avg(distance) average_distance
from customer_orders CO
join runner_orders RO
on Co.order_id = RO.order_id
where distance!=0
group by CO.customer_id
````

**Answer:**

|customer_id|average_distance|
|---|---|
|101|20|
|102|16.7333333333333|
|103|23.4|
|104|10|
|105|25|


_(Assuming that distance is calculated from Pizza Runner HQ to customer’s place)_

- Customer 104 stays the nearest to Pizza Runner HQ at average distance of 10km, whereas Customer 105 stays the furthest at 25km.

### 5. What was the difference between the longest and shortest delivery times for all orders?


````sql
select max(duration) - min(duration) As 'difference between the longest and shortest'
from runner_orders
where distance!=0
````
**Answer:**

|difference between the longest and shortest|
|---|
|30|

- The difference between longest (40 minutes) and shortest (10 minutes) delivery time for all orders is 30 minutes.


### 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

````sql
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

````

**Answer:**

|runner_id|customer_id|order_id|pizza_count|distance|duration|avg_speed|
|---|---|---|---|---|---|---|
|1|101|1|1|20|32|37.5|
|1|101|2|1|20|27|44.44|
|1|102|3|2|13.4|20|40.2|
|2|103|4|3|23.4|40|35.1|
|3|104|5|1|10|15|40|
|2|105|7|1|25|25|60|
|2|102|8|1|23.4|15|93.6|
|1|104|10|2|10|10|60

_(Average speed = Distance in km / Duration in hour)_
- Runner 1’s average speed runs from 37.5km/h to 60km/h.
- Runner 2’s average speed runs from 35.1km/h to 93.6km/h. Danny should investigate Runner 2 as the average speed has a 300% fluctuation rate!
- Runner 3’s average speed is 40km/h

### 7. What is the successful delivery percentage for each runner?

````sql
SELECT 
  runner_id, 
  ROUND(100 * SUM(
    CASE WHEN distance = 0 THEN 0
    ELSE 1 END) / COUNT(*), 0) AS success_perc
FROM runner_orders
GROUP BY runner_id;
````

**Answer:**

|runner_id|success_perc|
|---|---|
|1|100|
|2|75|
|3|50|


- Runner 1 has 100% successful delivery.
- Runner 2 has 75% successful delivery.
- Runner 3 has 50% successful delivery

_(It’s not right to attribute successful delivery to runners as order cancellations are out of the runner’s control.)_

***