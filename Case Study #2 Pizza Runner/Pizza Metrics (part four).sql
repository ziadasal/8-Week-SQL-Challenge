-------D. Pricing and Ratings
--1) If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - 
---how much money has Pizza Runner made so far if there are no delivery fees?
select sum(case when pizza_name='Meatlovers' then number_of_orders *12 else number_of_orders *10 end) total_cost
from(
select pn.pizza_name,count(pizza_name) number_of_orders
from customer_orders co
join pizza_names pn
on co.pizza_id = pn.pizza_id
join runner_orders ro
on co.order_id = ro.order_id
where distance!=0
group by pn.pizza_name
) as newTab


--2) What if there was an additional $1 charge for any pizza extras?-Add cheese is $1 extra
SELECT
    sum(
    CASE
        WHEN pn.pizza_name = 'Meatlovers' THEN
            CASE
                WHEN co.extras !=' ' THEN
                    12 +
                    (
                        LEN(co.extras) - LEN(REPLACE(co.extras, ',', '')) + 1
                    )  -- Add $1 for each extra
                    +
                    (
                        CASE
                            WHEN CHARINDEX('4', co.extras) > 0 THEN 1  -- Add $1 for cheese
                            ELSE 0
                        END
                    )
                ELSE 12  -- Meat Lovers without any extras
            END
        WHEN pn.pizza_name = 'Vegetarian' THEN
            CASE
                WHEN co.extras !=' ' THEN
                    10 +
                    (
                        LEN(co.extras) - LEN(REPLACE(co.extras, ',', '')) + 1
                    )  -- Add $1 for each extra
                    +
                    (
                        CASE
                            WHEN CHARINDEX('4', co.extras) > 0 THEN 1  -- Add $1 for cheese
                            ELSE 0
                        END
                    )
                ELSE 10  -- Vegetarian without any extras
            END
    END
    )AS total_revenue
FROM
    customer_orders co
JOIN
    pizza_names pn ON co.pizza_id = pn.pizza_id
JOIN
    runner_orders ro ON co.order_id = ro.order_id
WHERE
    ro.distance != 0;

--3) The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner,
--how would you design an additional table for this new dataset - generate a schema for this new table and 
--insert your own data for ratings for each successful customer order between 1 to 5.
-- Insert sample ratings data
CREATE TABLE RunnerRatings (
    rating_id INT PRIMARY KEY IDENTITY(1,1),
    order_id INT NOT NULL,
    customer_id INT NOT NULL,
    runner_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    rating_date DATETIME NOT NULL
);


INSERT INTO RunnerRatings (order_id, customer_id, runner_id, rating, rating_date)
VALUES
    (1, 101, 1, 4, '2020-01-01 18:10:00'),
    (2, 101, 1, 5, '2020-01-01 19:05:00'),
    (3, 102, 1, 3, '2020-01-02 23:55:00'),
    (3, 102, 2, 4, '2020-01-02 23:57:00'),
    (4, 103, 1, 2, '2020-01-04 13:30:00');

--4) Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
--customer_id
--order_id
--runner_id
--rating
--order_time
--pickup_time
--Time between order and pickup
--Delivery duration
--Average speed
--Total number of pizzas
select customer_id,order_id ,runner_id , avg(avg_rating) avg_rating,order_time,pickup_time ,duration, avg(avg_speed) avg_speed,count(pizza_id) number_pizza
from (
select co.customer_id,co.order_id ,ro.runner_id , rr.rating avg_rating ,co.order_time,ro.pickup_time ,duration,distance/DATEDIFF(MINUTE,order_time,pickup_time) avg_speed,co.pizza_id
from customer_orders co
join runner_orders ro
on co.order_id= ro.order_id
join RunnerRatings rr
on rr.runner_id = ro.runner_id )as newTab 
group by  customer_id,order_id ,runner_id ,order_time,pickup_time ,duration

--5) If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner
--is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over 
--after these deliveries?

WITH DeliveryCost AS (
    SELECT
        ro.order_id,
        SUM(
            CASE
                WHEN pn.pizza_name = 'Meatlovers' THEN 12
                WHEN pn.pizza_name = 'Vegetarian' THEN 10
                ELSE 0  
            END
        ) AS total_pizza_cost,
        ro.distance AS delivery_distance_km,
        ro.runner_id
    FROM
        runner_orders ro
    JOIN
        customer_orders co ON ro.order_id = co.order_id
    JOIN
        pizza_names pn ON co.pizza_id = pn.pizza_id
    WHERE
        ro.distance != 0
    GROUP BY
        ro.order_id, ro.distance, ro.runner_id
)
SELECT
    SUM(total_pizza_cost) - SUM(delivery_distance_km * 0.30) AS money_left_over
FROM
    DeliveryCost;

--------E. Bonus Questions
----If Danny wants to expand his range of pizzas - 
--how would this impact the existing data design? Write an INSERT statement to demonstrate 
---what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?

-- Step 1: Insert the new pizza name into the pizza_names table
INSERT INTO pizza_names (pizza_name)
VALUES ('Supreme');

-- Step 2: Insert any new toppings unique to the Supreme pizza into the pizza_toppings table (if needed)
-- For example, if 'Supreme' includes 'Olives' and 'Green Peppers' as new toppings:
INSERT INTO pizza_toppings (topping_name)
VALUES ('Olives'), ('Green Peppers');

-- Step 3: Insert the recipe for the Supreme pizza into the pizza_recipes table
-- Assuming 'Olives' and 'Green Peppers' have topping_ids 13 and 14, respectively:
INSERT INTO pizza_recipes (pizza_id, toppings)
VALUES (
    (SELECT pizza_id FROM pizza_names WHERE pizza_name = 'Supreme'), 
    '1, 2, 3, 4, 5, 6, 8, 10, 11, 12, 13, 14'
);