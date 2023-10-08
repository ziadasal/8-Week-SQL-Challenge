--## A. Customer Journey
--Based off the 8 sample customers provided in the sample subscriptions table below, 
---write a brief description about each customer’s onboarding journey.
select s.customer_id , p.plan_name , s.start_date
from subscriptions s
join plans p
on s.plan_id = p.plan_id
where customer_id in (1,2,11,13,15,16,19)
order by customer_id

--B. Data Analysis Questions
--1) How many customers has Foodie-Fi ever had?
select count(distinct customer_id) Number_of_customers
from subscriptions
--2) What is the monthly distribution of trial plan start_date values for our dataset - 
-----use the start of the month as the group by value
with c2 as (
select count(customer_id) number_of_customer, MONTH(start_date) month, YEAR(start_date) year
from subscriptions
where plan_id=0
group by  MONTH(start_date),YEAR(start_date)
)

select * from c2
order by month,year
--3) What plan start_date values occur after the year 2020 for our dataset?
---Show the breakdown by count of events for each plan_name
select count(customer_id) number_of_events,p.plan_name
from subscriptions s
join plans p
on s.plan_id = p.plan_id
where YEAR(start_date) >2020
group by p.plan_name
--4) What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
select sum(iif(plan_id =4 ,1,0)) number_of_customer_churned, round((sum(iif(plan_id =4 ,1,0))*1.0/count(distinct customer_id))*100,1) percentage_of_churn
from subscriptions
--5) How many customers have churned straight after their initial free trial - 
----what percentage is this rounded to the nearest whole number?
with c5 as (
select customer_id,
plan_id ,
LEAD(plan_id) over(partition by customer_id order by start_date) next_plan
from subscriptions )

select sum(iif(plan_id=0 and next_plan = 4 , 1,0)) number_straight_churned,
round(sum(iif(plan_id=0 and next_plan = 4 , 1,0))*100.0/count(distinct(customer_id)),0) percentage_of_straight
from c5

--6) What is the number and percentage of customer plans after their initial free trial?
with c6 as (
select customer_id,
plan_id ,
LEAD(plan_id) over(partition by customer_id order by start_date) next_plan
from subscriptions
)

select plan_name,number_of_customers,round(number_of_customers*100.0/(select count(distinct customer_id) from subscriptions),2) percentage
from (
select next_plan,count(next_plan) number_of_customers
from c6
where plan_id =0
group by next_plan
) as newTab 
join plans 
on next_plan = plan_id

--7) What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
select last_subscribtion,
count(last_subscribtion) number_of_customers,
round(count(last_subscribtion)*100.0/(select count(distinct customer_id) from subscriptions),2) percentage
from 
(
select distinct LAST_VALUE(s.plan_id) over (partition by customer_id order by start_date) last_subscribtion,
LAST_VALUE(start_date) over (partition by customer_id order by start_date) last_date
from subscriptions s
) as newTab
where last_date<='2020-12-31'
group by last_subscribtion

with c7 as (
select customer_id ,plan_id,start_date,
lead(start_date) over (partition by customer_id order by start_date) next_date
from subscriptions
where start_date<='2020-12-31'
)

select plan_name,count(plan_name) number_of_customers , 
round(count(s.plan_id)*100.0/(select count(distinct customer_id) from subscriptions),2) percentage
from c7 s
join plans
on plans.plan_id = s.plan_id
where next_date IS NULL
group by plan_name

--8) How many customers have upgraded to an annual plan in 2020?
select count(distinct customer_id) upgraded_customer_to_annual
from subscriptions
where YEAR(start_date)=2020 and plan_id = 3
--9) How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
with c9 as (
select *,LEAD(plan_id) over(partition by customer_id order by start_date) next_plan,
LEAD(start_date) over(partition by customer_id order by start_date) next_date,
first_value(start_date) over(partition by customer_id order by start_date) first_day
from subscriptions
)

select round(AVG(DateDiff(day,first_day,next_date)*1.0),0) number_of_days_to_annual
from c9
where next_plan=3 

--10) Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
WITH trial_plan AS (
    -- trial_plan CTE: Filter results to include only the customers subscribed to the trial plan.
    SELECT 
        customer_id, 
        start_date AS trial_date
    FROM subscriptions
    WHERE plan_id = 0
), annual_plan AS (
    -- annual_plan CTE: Filter results to only include the customers subscribed to the pro annual plan.
    SELECT 
        customer_id, 
        start_date AS annual_date
    FROM subscriptions
    WHERE plan_id = 3
), bins AS (
    -- bins CTE: Put customers in 30-day buckets based on the average number of days taken to upgrade to a pro annual plan.
    SELECT 
        (AVG(DATEDIFF(DAY, trial.trial_date, annual.annual_date)) / 30) AS avg_days_to_upgrade
    FROM trial_plan AS trial
    JOIN annual_plan AS annual
        ON trial.customer_id = annual.customer_id
    GROUP BY trial.customer_id, annual.customer_id
)

SELECT 
    CONCAT((CAST((avg_days_to_upgrade - 1) * 30 AS NVARCHAR(50))), ' - ', CAST(avg_days_to_upgrade * 30 AS NVARCHAR(50)), ' days') AS bucket, 
    COUNT(*) AS num_of_customers
FROM bins
GROUP BY avg_days_to_upgrade
ORDER BY avg_days_to_upgrade;

--11) How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
WITH c11 AS (
  SELECT 
    sub.customer_id,  
  	plans.plan_id,
    plans.plan_name, 
	  LEAD(plans.plan_id) OVER ( 
      PARTITION BY sub.customer_id
      ORDER BY sub.start_date) AS next_plan_id
  FROM subscriptions AS sub
  JOIN plans 
    ON sub.plan_id = plans.plan_id
 WHERE Year(start_date) = 2020
)
  
SELECT 
  COUNT(customer_id) AS churned_customers
FROM c11
WHERE plan_id = 2
  AND next_plan_id = 1;
