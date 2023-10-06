-- Begin a transaction for data integrity
BEGIN TRANSACTION;

-- Declare a table variable to store the updated rows
DECLARE @UpdatedOrders TABLE (
    order_id INT,
    customer_id INT,
    pizza_id INT,
    exclusions NVARCHAR(MAX),
    extras NVARCHAR(MAX),
    order_time DATETIME
);

-- Update the main table with cleaned data and capture the updated rows
UPDATE co
SET 
    co.exclusions = ISNULL(NULLIF(ct.exclusions, 'null'), ' '),
    co.extras = ISNULL(NULLIF(ct.extras, 'null'), ' ')
OUTPUT
    INSERTED.order_id,
    INSERTED.customer_id,
    INSERTED.pizza_id,
    INSERTED.exclusions,
    INSERTED.extras,
    INSERTED.order_time
INTO @UpdatedOrders
FROM customer_orders AS co
JOIN customer_orders AS ct ON co.order_id = ct.order_id
WHERE ct.exclusions IS NOT NULL OR ct.extras IS NOT NULL;

-- Commit the transaction
COMMIT TRANSACTION;
--------------------------------------------------------------
-- Begin a transaction for data integrity
BEGIN TRANSACTION;

-- Update the main table with cleaned data
UPDATE ro
SET 
    pickup_time = CASE WHEN ISNULL(rt.pickup_time, '') = 'null' THEN ' ' ELSE rt.pickup_time END,
    distance = CASE
        WHEN ISNULL(rt.distance, '') = 'null' THEN ' '
        WHEN rt.distance LIKE '%km' THEN RTRIM(REPLACE(rt.distance, 'km', ''))
        ELSE rt.distance
    END,
    duration = CASE
        WHEN ISNULL(rt.duration, '') = 'null' THEN ' '
        WHEN rt.duration LIKE '%mins' THEN RTRIM(REPLACE(rt.duration, 'mins', ''))
        WHEN rt.duration LIKE '%minute' THEN RTRIM(REPLACE(rt.duration, 'minute', ''))
        WHEN rt.duration LIKE '%minutes' THEN RTRIM(REPLACE(rt.duration, 'minutes', ''))
        ELSE rt.duration
    END,
    cancellation = CASE WHEN ISNULL(rt.cancellation, '') = 'null' THEN ' ' ELSE rt.cancellation END
FROM runner_orders AS ro
JOIN (
    SELECT
        order_id,
        CASE
            WHEN ISNULL(pickup_time, '') = 'null' THEN ' '
            ELSE pickup_time
        END AS pickup_time,
        CASE
            WHEN ISNULL(distance, '') = 'null' THEN ' '
            WHEN distance LIKE '%km' THEN RTRIM(REPLACE(distance, 'km', ''))
            ELSE distance
        END AS distance,
        CASE
            WHEN ISNULL(duration, '') = 'null' THEN ' '
            WHEN duration LIKE '%mins' THEN RTRIM(REPLACE(duration, 'mins', ''))
            WHEN duration LIKE '%minute' THEN RTRIM(REPLACE(duration, 'minute', ''))
            WHEN duration LIKE '%minutes' THEN RTRIM(REPLACE(duration, 'minutes', ''))
            ELSE duration
        END AS duration,
        CASE
            WHEN ISNULL(cancellation, '') = 'null' THEN ' '
            ELSE cancellation
        END AS cancellation
    FROM runner_orders
) AS rt
ON ro.order_id = rt.order_id;

-- Commit the transaction
COMMIT TRANSACTION;
------------------------------------------------------------
-- Alter the pickup_time column to DATETIME
ALTER TABLE runner_orders
ALTER COLUMN pickup_time DATETIME;

-- Alter the distance column to FLOAT
ALTER TABLE runner_orders
ALTER COLUMN distance FLOAT;

-- Alter the duration column to INT
ALTER TABLE runner_orders
ALTER COLUMN duration INT;

