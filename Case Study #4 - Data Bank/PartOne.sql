--### A. Customer Nodes Exploration

--1. How many unique nodes are there on the Data Bank system?
select count(distinct node_id) as number_nodes
from customer_nodes

--2. What is the number of nodes per region?
select cn.region_id,region_name,count(node_id) number_of_nodes
from customer_nodes cn
join regions r
on cn.region_id = r.region_id
group by cn.region_id,region_name
order by cn.region_id
--3. How many customers are allocated to each region?
select cn.region_id,region_name,count(distinct customer_id) number_of_customer
from customer_nodes cn
join regions r
on cn.region_id = r.region_id
group by cn.region_id,region_name
order by cn.region_id
--4. How many days on average are customers reallocated to a different node?
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

--5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
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
