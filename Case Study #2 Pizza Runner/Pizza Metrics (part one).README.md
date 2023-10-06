# 🍕 Case Study #2 - Pizza Runner

## 🍝 Solution - A. Pizza Metrics

### 1. How many pizzas were ordered?

````sql
select count(order_id) number_of_orders
from customer_orders
````

**Answer:**

|number of pizzas ordered|
|---|
|14|

- Total of 14 pizzas were ordered.

### 2. How many unique customer orders were made?

````sql
select count(distinct order_time) number_of_customers
from customer_orders
````

**Answer:**
|number of unique customer orders|
|---|
|10|

- There are 10 unique customer orders.

### 3. How many successful orders were delivered by each runner?

````sql
select runner_id,count(duration) Successful_run
from runner_orders
group by runner_id
````

**Answer:**

|runner_id|Successful_run|
|---|---|
|1|4|
|2|3|
|3|1|

- Runner 1 has 4 successful delivered orders.
- Runner 2 has 3 successful delivered orders.
- Runner 3 has 1 successful delivered order.

### 4. How many of each type of pizza was delivered?

````sql
select pizza_name,count(distance) delivered_pizza
from runner_orders RO
join customer_orders CO
on RO.order_id = CO.order_id
join pizza_names P
on CO.pizza_id = P.pizza_id
where distance!= 0
group by pizza_name
````

**Answer:**

|pizza_name|delivered_pizza|
|---|---|
|Meatlovers|9|
|Vegetarian|3|

- There are 9 delivered Meatlovers pizzas and 3 Vegetarian pizzas.

### 5. How many Vegetarian and Meatlovers were ordered by each customer?**

````sql
select customer_id,PN.pizza_name,count(distance) delivered_pizza
from customer_orders CO
join pizza_names PN 
on Co.pizza_id = PN.pizza_id
join runner_orders RO
on CO.order_id = RO.order_id
group by customer_id,PN.pizza_name
````

**Answer:**

|customer_id|pizza_name|delivered_pizza|
|---|---|---|
|101|Meatlovers|2|
|101|Vegetarian|1|
|102|Meatlovers|2|
|102|Vegetarian|2|
|103|Meatlovers|3|
|103|Vegetarian|1|
|104|Meatlovers|1|
|105|Vegetarian|1|


- Customer 101 ordered 2 Meatlovers pizzas and 1 Vegetarian pizza.
- Customer 102 ordered 2 Meatlovers pizzas and 2 Vegetarian pizzas.
- Customer 103 ordered 3 Meatlovers pizzas and 1 Vegetarian pizza.
- Customer 104 ordered 1 Meatlovers pizza.
- Customer 105 ordered 1 Vegetarian pizza.

### 6. What was the maximum number of pizzas delivered in a single order?

````sql
select top 1 order_id,number_of_pizzas
from (select order_id, count(order_id) number_of_pizzas from customer_orders group by order_id )as newTab
order by number_of_pizzas desc
````

**Answer:**

|order_id|number_of_pizzas|
|---|---|
|4|3|

Maximum number of pizza delivered in a single order is 3 pizzas.

### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

````sql
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
````

**Answer:**

|customer_id|at_least_1_change|no_change|
|---|---|---|
|101|0|2|
|102|0|3|
|103|3|0|
|104|2|1|
|105|1|0|


- Customer 101 and 102 likes his/her pizzas per the original recipe.
- Customer 103, 104 and 105 have their own preference for pizza topping and requested at least 1 change (extra or exclusion topping) on their pizza.

### 8. How many pizzas were delivered that had both exclusions and extras?

````sql
select customer_id,Sum(Case When Co.extras<>' ' and Co.exclusions<>' ' then 1 else 0 end) number_of_both_exclusions 
from customer_orders CO
join runner_orders RO
on RO.order_id = CO.order_id
where distance!=0
group by customer_id
order by customer_id
````

**Answer:**

|customer_id|number_of_both_exclusions|
|---|---|
|103|1|


- Only 1 pizza delivered that had both extra and exclusion topping. It is ordered by customer 103.

### 9. What was the total volume of pizzas ordered for each hour of the day?

````sql
SELECT 
  DATEPART(HOUR, [order_time]) AS hour_of_day, 
  COUNT(order_id) AS pizza_count
FROM #customer_orders
GROUP BY DATEPART(HOUR, [order_time]);
````

**Answer:**

|hour_of_day|pizza_count|
|---|---|
|11|1|  
|12|2|
|13|3|
|18|3|
|19|1|
|21|3|
|23|1|

- Highest volume of pizza ordered is at 13 (1:00 pm), 18 (6:00 pm) and 21 (9:00 pm).
- Lowest volume of pizza ordered is at 11 (11:00 am), 19 (7:00 pm) and 23 (11:00 pm).

### 10. What was the volume of orders for each day of the week?

````sql
SELECT 
  FORMAT(DATEADD(DAY, 2, order_time),'dddd') AS day_of_week, -- add 2 to adjust 1st day of the week as Monday
  COUNT(order_id) AS total_pizzas_ordered
FROM #customer_orders
GROUP BY FORMAT(DATEADD(DAY, 2, order_time),'dddd');
````

**Answer:**
  |day_of_week|total_pizzas_ordered|
  |---|---|
  |Friday|5|
  |Monday|5|
  |Saturday|3|
  |Sunday|1|

- There are 5 pizzas ordered on Friday and Monday.
- There are 3 pizzas ordered on Saturday.
- There is 1 pizza ordered on Sunday.

***Click [here](https://github.com/katiehuangx/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232%20-%20Pizza%20Runner/B.%20Runner%20and%20Customer%20Experience.md) for solution for B. Runner and Customer Experience!***