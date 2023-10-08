# 🥑 Case Study #3: Foodie-Fi

<img src="https://8weeksqlchallenge.com/images/case-study-designs/3.png" alt="image">

## 📚 Table of Contents
- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Question and Solution](#question-and-solution)

Please note that all the information regarding the case study has been sourced from the following link: [here](https://8weeksqlchallenge.com/case-study-3/). 

***

## Business Task
Danny and his friends launched a new startup Foodie-Fi and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world.

This case study focuses on using subscription style digital data to answer important business questions on customer journey, payments, and business performances.

## Entity Relationship Diagram

![image](https://8weeksqlchallenge.com/images/case-study-3-erd.png)

**Table 1: `plans`**

| plan_id | plan_name     | price |
| ------- | ------------- | ----- |
| 0       | trial         | 0.00  |
| 1       | basic monthly | 9.90  |
| 2       | pro monthly   | 19.90 |
| 3       | pro annual    | 199.00|
| 4       | churn         | NULL  |

There are 5 customer plans.

- Trial — Customer sign up to an initial 7 day free trial and will automatically continue with the pro monthly subscription plan unless they cancel, downgrade to basic or upgrade to an annual pro plan at any point during the trial.
- Basic plan — Customers have limited access and can only stream their videos and is only available monthly at $9.90.
- Pro plan — Customers have no watch time limits and are able to download videos for offline viewing. Pro plans start at $19.90 a month or $199 for an annual subscription.

When customers cancel their Foodie-Fi service — they will have a Churn plan record with a null price, but their plan will continue until the end of the billing period.

**Table 2: `subscriptions`**

| customer_id | plan_id | start_date |
| ----------- | ------- | ---------- |
|1|0|2020-08-01|
|1|1|2020-08-08|
|2|0|2020-09-20|
|2|3|2020-09-27|
|11|0|2020-11-19|
|11|4|2020-11-26|
|13|0|2020-12-15|
|13|1|2020-12-22|
|13|2|2021-03-29|
|15|0|2020-03-17|
|15|2|2020-03-24|
|15|4|2020-04-29|
|16|0|2020-05-31|
|16|1|2020-06-07|
|16|3|2020-10-21|
|18|0|2020-07-06|
|18|2|2020-07-13|
|19|0|2020-06-22|
|19|2|2020-06-29|
|19|3|2020-08-29|

Customer subscriptions show the **exact date** where their specific `plan_id` starts.

If customers downgrade from a pro plan or cancel their subscription — the higher plan will remain in place until the period is over — the `start_date` in the subscriptions table will reflect the date that the actual plan changes.

When customers upgrade their account from a basic plan to a pro or annual pro plan — the higher plan will take effect straightaway.

When customers churn, they will keep their access until the end of their current billing period, but the start_date will be technically the day they decided to cancel their service.

***

## Question and Solution
## 🎞️ A. Customer Journey

Based off the 8 sample customers provided in the sample subscriptions table below, write a brief description about each customer’s onboarding journey.

**Answer:**

```sql
select *
from subscriptions 
where customer_id in (1,2,11,13,15,16,19)
order by customer_id
```

|customer_id	|plan_id	|start_date|
| ----------- | ------- | -------- |
|1 | trial | 2020-08-01 |
|1 | basic monthly | 2020-08-08 |
|2 | trial | 2020-09-20 |
|2 | pro annual | 2020-09-27 |
|11 | trial | 2020-11-19 |
|11 | churn | 2020-11-26 |
|13 | trial | 2020-12-15 |
|13 | basic monthly | 2020-12-22 |
|13 | pro monthly | 2021-03-29 |
|15 | trial | 2020-03-17 |
|15 | pro monthly | 2020-03-24 |
|15 | churn | 2020-04-29 |
|16 | trial | 2020-05-31 |
|16 | basic monthly | 2020-06-07 |
|16 | pro annual | 2020-10-21 |
|19 | trial | 2020-06-22 |
|19 | pro monthly | 2020-06-29 |
|19 | pro annual | 2020-08-29 |

for customer_id = 1, the customer started with a free trial on 1 Aug 2020 and subscribed to the basic monthly plan on 8 Aug 2020.

for customer_id = 2, the customer started with a free trial on 20 Sep 2020 and upgraded to the pro annual plan on 27 Sep 2020.

for customer_id = 11, the customer started with a free trial on 19 Nov 2020 and churned on 26 Nov 2020.

for customer_id = 13, the customer started with a free trial on 15 Dec 2020, subscribed to the basic monthly plan on 22 Dec 2020, and upgraded to the pro monthly plan on 29 Mar 2021.

for customer_id = 15, the customer started with a free trial on 17 Mar 2020, upgraded to the pro monthly plan on 24 Mar 2020, and churned on 29 Apr 2020.

for customer_id = 16, the customer started with a free trial on 31 May 2020, subscribed to the basic monthly plan on 7 Jun 2020, and upgraded to the pro annual plan on 21 Oct 2020.

for customer_id = 19, the customer started with a free trial on 22 Jun 2020, upgraded to the pro monthly plan on 29 Jun 2020, and upgraded to the pro annual plan on 29 Aug 2020.

***

## B. Data Analysis Questions

### 1. How many customers has Foodie-Fi ever had?

To determine the count of unique customers for Foodie-Fi, I utilize the `COUNT()` function wrapped around `DISTINCT`.

```sql
select count(distinct customer_id) Number_of_customers
from subscriptions
```

**Answer:**
|Num_of_customers|
|----------------|
|1000|

- Foodie-Fi has 1,000 unique customers.

### 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

```sql
with c2 as (
select count(customer_id) number_of_customer, MONTH(start_date) month, YEAR(start_date) year
from subscriptions
where plan_id=0
group by  MONTH(start_date),YEAR(start_date)
)

select * from c2
order by month,year
```

**Answer:**
|num_of_customer	|month|year|
|----------------|-----|----|
|88|1|2020|
|68|2|2020|
|94|3|2020|
|81|4|2020|
|88|5|2020|
|79|6|2020|
|89|7|2020|
|88|8|2020|
|87|9|2020|
|79|10|2020|
|75|11|2020|
|84|12|2020|


Among all the months, March has the highest number of trial plans, while February has the lowest number of trial plans.

### 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name.


````sql
select count(customer_id) number_of_events,p.plan_name
from subscriptions s
join plans p
on s.plan_id = p.plan_id
where YEAR(start_date) >2020
group by p.plan_name
````

**Answer:**
|number_of_events	|plan_name|
|----------------|---------|
|8|basic monthly|
|71|churn|
|63|pro annual|
|60|pro monthly|

### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

Let's analyze the question:
- First, we need to determine
  - The number of customers who have churned, meaning those who have discontinued their subscription.
  - The total number of customers, including both active and churned ones.

- To calculate the churn rate, we divide the number of churned customers by the total number of customers. The result should be rounded to one decimal place.

```sql
select sum(iif(plan_id =4 ,1,0)) number_of_customer_churned, round((sum(iif(plan_id =4 ,1,0))*1.0/count(distinct customer_id))*100,1) percentage_of_churn
from subscriptions
```

**Answer:**
|number_of_customer_churned	|percentage_of_churn|
|--------------------------|-------------------|
|306|30.6|

- Out of the total customer base of Foodie-Fi, 306 customers have churned. This represents approximately 30.6% of the overall customer count.

### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?


```sql
with c5 as (
select customer_id,
plan_id ,
LEAD(plan_id) over(partition by customer_id order by start_date) next_plan
from subscriptions )

select sum(iif(plan_id=0 and next_plan = 4 , 1,0)) number_straight_churned,
round(sum(iif(plan_id=0 and next_plan = 4 , 1,0))*100.0/count(distinct(customer_id)),0) percentage_of_straight
from c5
```

**Answer:**

|number_straight_churned	|percentage_of_straight|
|--------------------------|----------------------|
|92|9|

- A total of 92 customers churned immediately after the initial free trial period, representing approximately 9% of the entire customer base.

### 6. What is the number and percentage of customer plans after their initial free trial?

```sql
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
```

**Answer:**

|plan_name	|number_of_customers	|percentage|
| ------- | ------------------- | --------------------- |
| 1       | 546                 | 54.6                  |
| 2       | 325                 | 32.5                  |
| 3       | 37                  | 3.7                   |
| 4       | 92                  | 9.2                   |

- More than 80% of Foodie-Fi's customers are on paid plans with a majority opting for Plans 1 and 2. 
- There is potential for improvement in customer acquisition for Plan 3 as only a small percentage of customers are choosing this higher-priced plan.

### 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

```sql
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
```

**Answer:**
|plan_name	|number_of_customers	|percentage|
| ------- | ------------------- | --------------------- |
|basic monthly|224|22.4|
|churn|235|23.5|
|pro annual|195|19.5|
|pro monthly|327|32.7|
|trial|19|1.9|

### 8. How many customers have upgraded to an annual plan in 2020?

```sql
select count(distinct customer_id) upgraded_customer_to_annual
from subscriptions
where YEAR(start_date)=2020 and plan_id = 3
```

**Answer:**
|upgraded_customer_to_annual|
|---------------------------|
|195|

- 195 customers have upgraded to an annual plan in 2020.

### 9. How many days on average does it take for a customer to upgrade to an annual plan from the day they join Foodie-Fi?


````sql
with c9 as (
select *,LEAD(plan_id) over(partition by customer_id order by start_date) next_plan,
LEAD(start_date) over(partition by customer_id order by start_date) next_date,
first_value(start_date) over(partition by customer_id order by start_date) first_day
from subscriptions
)

select round(AVG(DateDiff(day,first_day,next_date)*1.0),0) number_of_days_to_annual
from c9
where next_plan=3 
````

**Answer:**

|number_of_days_to_annual|
|-----------------------|
|105|

- On average, customers take approximately 105 days from the day they join Foodie-Fi to upgrade to an annual plan.

### 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

To understand how the `WIDTH_BUCKET()` function works in creating buckets of 30-day periods, you can refer to this [StackOverflow](https://stackoverflow.com/questions/50518548/creating-a-bin-column-in-postgres-to-check-an-integer-and-return-a-string) answer.

```sql
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
```

**Answer:**

| bucket         | num_of_customers |
| -------------- | ---------------- |
| 0 - 30 days    | 49               |
| 30 - 60 days   | 24               |
| 60 - 90 days   | 35               |
| 90 - 120 days  | 35               |
| 120 - 150 days | 43               |
| 150 - 180 days | 37               |
| 180 - 210 days | 24               |
| 210 - 240 days | 4                |
| 240 - 270 days | 4                |
| 270 - 300 days | 1                |
| 300 - 330 days | 1                |
| 330 - 360 days | 1                |

### 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

```sql
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
```

**Answer:**

| churned_customers |
| ----------------- |
| 0                 |

In 2020, there were no instances where customers downgraded from a pro monthly plan to a basic monthly plan.

***

## C. Challenge Payment Question
The Foodie-Fi team wants to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:
  * monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
  * upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
  * upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
  * once a customer churns they will no longer make payments

Example outputs for this table might look like the following:

| customer_id | plan_id | plan_name     | payment_date | amount | payment_order  |
|-------------|---------|---------------|--------------|--------|----------------|
| 1           | 1       | basic monthly | 2020-08-08   | 9.90   | 1              |
| 1           | 1       | basic monthly | 2020-09-08   | 9.90   | 2              |
| 1           | 1       | basic monthly | 2020-10-08   | 9.90   | 3              |
| 1           | 1       | basic monthly | 2020-11-08   | 9.90   | 4              |
| 1           | 1       | basic monthly | 2020-12-08   | 9.90   | 5              |
| 2           | 3       | pro annual    | 2020-09-27   | 199.00 | 1              |
| 13          | 1       | basic monthly | 2020-12-22   | 9.90   | 1              |
| 15          | 2       | pro monthly   | 2020-03-24   | 19.90  | 1              |
| 15          | 2       | pro monthly   | 2020-04-24   | 19.90  | 2              |
| 16          | 1       | basic monthly | 2020-06-07   | 9.90   | 1              |
| 16          | 1       | basic monthly | 2020-07-07   | 9.90   | 2              |
| 16          | 1       | basic monthly | 2020-08-07   | 9.90   | 3              |
| 16          | 1       | basic monthly | 2020-09-07   | 9.90   | 4              |
| 16          | 1       | basic monthly | 2020-10-07   | 9.90   | 5              |
| 16          | 3       | pro annual    | 2020-10-21   | 189.10 | 6              |
| 18          | 2       | pro monthly   | 2020-07-13   | 19.90  | 1              |
| 18          | 2       | pro monthly   | 2020-08-13   | 19.90  | 2              |
| 18          | 2       | pro monthly   | 2020-09-13   | 19.90  | 3              |
| 18          | 2       | pro monthly   | 2020-10-13   | 19.90  | 4              |


****
## D. Outside The Box Questions
### 1. How would you calculate the rate of growth for Foodie-Fi?
- I choose the year of 2020 to analyze because I already created the ```payments``` table in part C.
- If you want to incorporate the data in 2021 to see the whole picture (quarterly, 2020-2021 comparison, etc.), 
create a new ```payments``` table and change all the date conditions in part C to '2021-12-31'

```TSQL
WITH monthlyRevenue AS (
  SELECT 
    MONTH(payment_date) AS months,
    SUM(amount) AS revenue
  FROM payments
  GROUP BY MONTH(payment_date)
)

SELECT 
  months,
  revenue,
  (revenue-LAG(revenue) OVER(ORDER BY months))/revenue AS revenue_growth
FROM monthlyRevenue;
```
| months | revenue  | revenue_growth  |
|--------|----------|-----------------|
| 1      | 1282.00  | NULL            |
| 2      | 2792.60  | 0.540929        |
| 3      | 4342.40  | 0.356899        |
| 4      | 5972.70  | 0.272958        |
| 5      | 7324.10  | 0.184514        |
| 6      | 8765.50  | 0.164440        |
| 7      | 10207.50 | 0.141268        |
| 8      | 12047.40 | 0.152721        |
| 9      | 12913.20 | 0.067047        |
| 10     | 14952.50 | 0.136385        |
| 11     | 12862.70 | -0.162469       |
| 12     | 13429.50 | 0.042205        |

### 2. What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?
- Monthly revenue growth: How does Foodie-Fi's revenue increase or decrease by monthly? Are there any months that the number of customers increasing significantly?
- Customers growth: How many customers increase by monthly? How does the rate look like (x1.5, x2,... after each month)? 
- Conversion rate: How many customers keep using Foodie-Fi after trial? How does the rate look like (x1.5, x2,...after each month)?
- Churn rate: How many customers cancel the subscription by monthly? What plan they has used?

### 3. What are some key customer journeys or experiences that you would analyse further to improve customer retention?
- Customers who downgraded their plan
- Customers who upgraded from basic monthly to pro monthly or pro annual
- Customers who cancelled the subscription

### 4. If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?
- What is the primary reason for the cancellation? 
  + Price
  + Techinical issues
  + Customer support
  + Found an alternative
  + Others (please specify)
- Overall, how satisfied were you with the subscription? (Likert scale: Very Satisfied - Very Unsatisfied)
- Would you consider using our services in the future? (Likert scale: Very Satisfied - Very Unsatisfied)
- Would you recommend our company to a colleague, friend or family member? (Likert scale: Very Satisfied - Very Unsatisfied)

### 5. What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?
- From the exit survey, look for the most common reasons why customers cancelled the subscription
  + Price: increase the number of discounts in some seasons of a year, extend the trial time, or add more benefits to customers 
  + Service quality: work with the relevant department to fix the issue
  + Found an alternative: do some competitor analysis to see their competitive advantages over us
- To validate the effectiveness of those ideas, check:
  + Churn rate
  + Conversion rate