# 🍕 Case Study #2 Pizza Runner

## Solution - C. Ingredient Optimisation

### 1. What are the standard ingredients for each pizza?
```sql
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
```

Answer:
  |pizza_id|	topping_name|
  |--------|-------------|
  |1	|Bacon|
  |1	|BBQ Sauce|
  |1	|Beef|
  |1	|Cheese|
  |1	|Chicken|
  |1	|Mushrooms|
  |1	|Pepperoni|
  |1	|Salami|
  |2	|Cheese|
  |2	|Mushrooms|
  |2	|Onions|
  |2	|Peppers|
  |2	|Tomatoes|
  |2	|Tomato Sauce|

### 2. What was the most commonly added extra?

```sql
Select top 1 convert(nvarchar(max),pt.topping_name) 'most commonly', count(convert(nvarchar(max),pt.topping_name)) 'number of using'
From customer_orders co
Cross Apply
	string_split(convert(nvarchar(max),co.extras),',') As split_extra
Join 
	pizza_toppings pt
On 
	pt.topping_id = TRY_CAST(split_extra.value As INT)
group by convert(nvarchar(max),pt.topping_name)
```

**Solution**

|most commonly|number of using|
|-------------|---------------|
|Bacon| 4|

### 3. What was the most common exclusion?

'''sql
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
'''

**Solution**

|most common exclusion|number_of_using|
|---------------------|---------------|
|Bacon| 4|

### 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
- Meat Lovers
- Meat Lovers - Exclude Beef
- Meat Lovers - Extra Bacon
- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

### 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients

### 6. For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

### 7. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?