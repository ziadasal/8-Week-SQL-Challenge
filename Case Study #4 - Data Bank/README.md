# 📊 Case Study #4 - Data Bank
<p align="center">
<img src="https://8weeksqlchallenge.com/images/case-study-designs/4.png" align="center" width="400" height="400" >

---
## 🛠️ Bussiness Task
Danny launched a new initiative, Data Bank which runs banking activities and also acts as the world’s most secure distributed data storage platform!
Customers are allocated cloud data storage limits which are directly linked to how much money they have in their accounts.

The management team at Data Bank want to increase their total customer base - but also need some help tracking just how much data storage their customers will need.
This case study is all about calculating metrics, growth and helping the business analyse their data in a smart way to better forecast and plan for their future developments!

---
## 🔐 Entity Relationship Diagram
<p align="center">
<img src="https://8weeksqlchallenge.com/images/case-study-4-erd.png" align="center">


**Table 1: `regions`**

This regions table contains the `region_id` and their respective `region_name` values.
|region_id|region_name|
|:----|:----|
|1|Africa|
|2|America|
|3|Asia|
|4|Australia|
|5|Europe|


**Table 2: `customer_nodes`**

Customers are randomly distributed across the nodes according to their region. This random distribution changes frequently to reduce the risk of hackers getting into Data Bank’s system and stealing customer’s money and data!

|customer_id|node_id|region_id|start_date|end_date|
|:----|:----|:----|:----|:----|
|1|3|4|2020-01-02|2020-01-03|
|2|3|5|2020-01-03|2020-01-17|
|3|5|4|2020-01-27|2020-02-18|
|4|5|4|2020-01-27|2020-01-19|
|5|3|3|2020-01-15|2020-01-23|
|6|1|1|2020-01-11|2020-02-06|
|7|2|5|2020-01-20|2020-02-04|
|8|1|2|2020-01-15|2020-01-28|
|9|4|5|2020-01-21|2020-01-25|
|10|3|4|2020-01-13|2020-01-14|


**Table 3: Customer Transactions**

This table stores all customer deposits, withdrawals and purchases made using their Data Bank debit card.

|customer_id|txn_date|txn_type|txn_amount|
|:----|:----|:----|:----|
|429|2020-01-21|deposit|82|
|155|2020-01-10|deposit|712|
|398|2020-01-01|deposit|196|
|255|2020-01-14|deposit|563|
|185|2020-01-29|deposit|626|
|309|2020-01-13|deposit|995|
|312|2020-01-20|deposit|485|
|376|2020-01-03|deposit|706|
|188|2020-01-13|deposit|601|
|138|2020-01-11|deposit|520|

***

## Question and Solution

## 🏦 A. Customer Nodes Exploration

**1. How many unique nodes are there on the Data Bank system?**

````sql
select count(distinct node_id) as number_nodes
from customer_nodes
````

**Answer:**

|number_nodes|
|:----|
|5|

- There are 5 unique nodes on the Data Bank system.

***

**2. What is the number of nodes per region?**

````sql
select cn.region_id,region_name,count(node_id) number_of_nodes
from customer_nodes cn
join regions r
on cn.region_id = r.region_id
group by cn.region_id,region_name
order by cn.region_id
````

**Answer:**
|region_id|region_name|number_of_nodes|
|:----|:----|:----|
|1|Australia|770|
|2|America|735|
|3|Africa|714|
|4|Asia|665|
|5|Europe|616|

***

**3. How many customers are allocated to each region?**

````sql
select cn.region_id,region_name,count(distinct customer_id) number_of_customer
from customer_nodes cn
join regions r
on cn.region_id = r.region_id
group by cn.region_id,region_name
order by cn.region_id
````

**Answer:**

|region_id|region_name|number_of_customer|
|:----|:----|:----|
|1|Australia|110|
|2|America|105|
|3|Africa|102|
|4|Asia|95|
|5|Europe|88|

***

**4. How many days on average are customers reallocated to a different node?**

````sql
with customerData as(
	select customer_id,region_id,node_id,min(start_date) as first_date
	from customer_nodes
	group by customer_id,region_id,node_id
),reallocated as (
	select customer_id,region_id,node_id,DATEDIFF(DAY, first_date, 
             LEAD(first_date) OVER(PARTITION BY customer_id 
                                   ORDER BY first_date)) AS moving_days
  FROM customerData

)
select round(avg(cast(moving_days as float)),2) avg_days
from reallocated
````

**Answer:**

|avg_days|
|:----|
|23.69|

- On average, customers are reallocated to a different node every 24 days.

***

**5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?**

```sql
with customerData as(
	select customer_id,region_id,node_id,min(start_date) as first_date
	from customer_nodes
	group by customer_id,region_id,node_id
),reallocated as (
	select customer_id,region_id,node_id,DATEDIFF(DAY, first_date, 
             LEAD(first_date) OVER(PARTITION BY customer_id 
                                   ORDER BY first_date)) AS moving_days
  FROM customerData
)
select  
  distinct r.region_id,
  rg.region_name,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY r.moving_days) OVER(PARTITION BY r.region_id) AS median,
  PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY r.moving_days) OVER(PARTITION BY r.region_id) AS percentile_80,
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY r.moving_days) OVER(PARTITION BY r.region_id) AS percentile_95
from reallocated r
join regions rg 
on r.region_id = rg.region_id
where moving_days IS NOT NULL;

```
**Answer:**
|region_id|region_name|median|percentile_80|percentile_95|
|:----|:----|:----|:----|:----|
|1|Australia|23|31|54|
|2|America|21|33.2|57|
|3|Africa|21|33.2|58.8|
|4|Asia|22|32.4|49.85|
|5|Europe|22|31|54.3|

***

Do give me a 🌟 if you like what you're reading. Thank you! 🙆🏻‍♀️