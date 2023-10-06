----C. Ingredient Optimisation
--1) What are the standard ingredients for each pizza?
SELECT
    pr.pizza_id,
    pt.topping_name
FROM
    pizza_recipes pr
CROSS APPLY
    STRING_SPLIT(CONVERT(NVARCHAR(MAX), pr.toppings), ',') AS split_toppings
JOIN
    pizza_toppings pt
ON
    pt.topping_id = TRY_CAST(split_toppings.value AS INT);


--2) What was the most commonly added extra?
Select top 1 convert(nvarchar(max),pt.topping_name) 'most commonly', count(convert(nvarchar(max),pt.topping_name)) 'number of using'
From customer_orders co
Cross Apply
	string_split(convert(nvarchar(max),co.extras),',') As split_extra
Join 
	pizza_toppings pt
On 
	pt.topping_id = TRY_CAST(split_extra.value As INT)
group by convert(nvarchar(max),pt.topping_name)

--3) What was the most common exclusion?
select top 1 * from 
(
select convert(nvarchar(max),pt.topping_name) 'most common exclusion', count(convert(nvarchar(max),pt.topping_name)) number_of_using
from customer_orders co
Cross Apply
	string_split(convert(nvarchar(max),co.exclusions),',') as splitted_exclustion
join pizza_toppings pt
on pt.topping_id = TRY_CAST(splitted_exclustion.value as int)
group by CONVERT(nvarchar(max),pt.topping_name) 
)as newTab
order by number_of_using desc
--4) Generate an order item for each record in the customers_orders table in the format of one of the following:
--Meat Lovers
--Meat Lovers - Exclude Beef
--Meat Lovers - Extra Bacon
--Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
select co.* ,SUBSTRING(pizza_name,0,5)+' Lovers '+ iif(convert(nvarchar(max),pt.topping_name) is not NULL, '- Exclusion '+convert(nvarchar(max),pt.topping_name) ,'')+ iif(convert(nvarchar(max),pt2.topping_name) is not NULL, ' - Extra '+convert(nvarchar(max),pt2.topping_name) ,'')
from customer_orders co
join pizza_names pn
on co.pizza_id = pn.pizza_id
Cross Apply
	string_split(convert(nvarchar(max),co.exclusions),',') as splitted_exclustion
left join pizza_toppings pt
on pt.topping_id = TRY_CAST(splitted_exclustion.value as int)
Cross Apply 
	string_split(convert(nvarchar(max),co.extras),',') as splitted_extra
left join pizza_toppings pt2
on pt2.topping_id = TRY_CAST(splitted_extra.value as int)
--5) Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
--For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
--6) What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?