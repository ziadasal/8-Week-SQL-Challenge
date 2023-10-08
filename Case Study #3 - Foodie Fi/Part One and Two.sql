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
