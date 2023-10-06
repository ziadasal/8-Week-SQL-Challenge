# 🍜 Case Study #1: Danny's Diner
![Image](https://8weeksqlchallenge.com/images/case-study-designs/1.png)

## 📚 Table of Contents
- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Questions and Solutions](#questions-and-solutions)

Please note that all the information regarding the case study has been sourced from the following link: [here](https://8weeksqlchallenge.com/case-study-1/).

---

## Business Task
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent, and also which menu items are their favorite.

---

## Entity Relationship Diagram
![ER Diagram](https://user-images.githubusercontent.com/81607668/127271130-dca9aedd-4ca9-4ed8-b6ec-1e1920dca4a8.png)

---

### 1. What is the total amount each customer spent at the restaurant?
```sql
SELECT customer_id, SUM(price) AS 'total amount' 
FROM sales S 
JOIN menu M ON S.product_id = M.product_id
GROUP BY customer_id
```

**Answer:**
| customer_id | total amount |
| ----------- | ------------ |
| A           | 76           |
| B           | 74           |
| C           | 36           |

- Customer A spent $76.
- Customer B spent $74.
- Customer C spent $36.

---

### 2. How many days has each customer visited the restaurant?
```sql
SELECT customer_id, COUNT(DISTINCT order_date) AS visit_count 
FROM sales
GROUP BY customer_id
```

**Answer:**
| customer_id | visit_count |
| ----------- | ----------- |
| A           | 4           |
| B           | 6           |
| C           | 2           |

- Customer A visited 4 times.
- Customer B visited 6 times.
- Customer C visited 2 times.

---

### 3. What was the first item from the menu purchased by each customer?
```sql
SELECT DISTINCT customer_id, product_name, order_date 
FROM (
    SELECT customer_id, order_date, product_id, DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS ranking 
    FROM sales
) AS newtable
JOIN menu ON newtable.product_id = menu.product_id
WHERE ranking = 1
```

**Answer:**
| customer_id | product_name |
| ----------- | ------------ |
| A           | curry        |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |

- Customer A placed an order for both curry and sushi simultaneously, making them the first items in the order.
- Customer B's first order is curry.
- Customer C's first order is ramen.

---

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
```sql
SELECT TOP(1) product_name, COUNT(S.product_id) AS 'number of purchased'
FROM sales S
JOIN menu M ON S.product_id = M.product_id
GROUP BY product_name
ORDER BY 'number of purchased' DESC
```

**Answer:**
| most purchased | product_name |
| -------------- | ------------ |
| 8              | ramen        |

- The most purchased item on the menu is ramen, which was purchased 8 times.

---

### 5. Which item was the most popular for each customer?
```sql
SELECT customer_id, product_name, number 'number of purchased'
FROM (
    SELECT customer_id, product_name, COUNT(sales.product_id) AS number,
        DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(sales.product_id) DESC) AS ranking
    FROM sales
    JOIN menu ON sales.product_id = menu.product_id
    GROUP BY customer_id, product_name
) AS newTable
WHERE ranking = 1
```

**Answer:**
| customer_id | product_name | number of purchased |
| ----------- | ------------ | ------------------- |
| A           | ramen        | 3                   |
| B           | sushi        | 2                   |
| B           | curry        | 2                   |
| B           | ramen        | 2                   |
| C           | ramen        | 3                   |

- Customer A and C's favorite item is ramen.
- Customer B enjoys all items on the menu.

---

### 6. Which item was purchased first by the customer after they became a member?
```sql
SELECT customer_id, product_name, order_date
FROM (
    SELECT M.customer_id, product_name, order_date, M.join_date, DENSE_RANK() OVER(PARTITION BY S.customer_id ORDER BY order_date) AS ranking
    FROM members M
    JOIN sales S ON M.customer_id = S.customer_id
    JOIN menu MN ON S.product_id = MN.product_id
    WHERE order_date > join_date
) AS newTable
WHERE Ranking = 1
```

**Answer:**
| customer_id | product_name |
| ----------- | ------------ |
| A           | ramen        |
| B           | sushi        |

- Customer A's first order as a member is ramen.
- Customer B's first order as a member is sushi.

---

### 7. Which item was purchased just before the customer became a member?
```sql
SELECT customer_id, product_name, order_date
FROM (
    SELECT M.customer_id, product_name, order_date, M.join_date, DENSE_RANK() OVER(PARTITION BY S.customer_id ORDER BY order_date DESC) AS ranking
    FROM members M
    JOIN sales S ON M.customer_id = S.customer_id
    JOIN menu MN ON S.product_id = MN.product_id
    WHERE order_date < join_date
) AS newTable
WHERE Ranking = 1
```

**Answer:**
| customer_id | product_name | order_date |
| ----------- | ------------ | ---------- |
| A           | sushi        | 2021-01-01 |
| A           | curry        | 2021-01-01 |
| B           | sushi        | 2021-01-04 |

- Customer A's last order before becoming a member is sushi and curry.
- Customer B's last order before becoming a member is sushi.

---

### 8. What is the total number of items and amount spent for each member before they became a member?
```sql
SELECT customer_id, COUNT(newtable.product_id) AS total_items, SUM(price) AS total_sales
FROM (
    SELECT M.customer_id, S.product_id
    FROM members M
    JOIN sales S ON M.customer_id = S.customer_id
    JOIN menu MN ON S.product_id = MN.product_id
    WHERE order_date < join_date
) AS newTable
JOIN menu MN ON newTable.product_id = MN.product_id
GROUP BY customer_id
```

**Answer:**
| customer_id | total_items | total_sales |
| ----------- | ----------- | ----------- |
| A           | 2           | 25          |
| B           | 3           | 

40          |

Before becoming members,
- Customer A spent $25 on 2 items.
- Customer B spent $40 on 3 items.

---

### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?
```sql
SELECT customer_id, SUM(IIF(product_name = 'sushi', price * 20, price * 10)) AS total_points
FROM sales
JOIN menu ON sales.product_id = menu.product_id
GROUP BY customer_id
```

**Answer:**
| customer_id | total_points |
| ----------- | ------------ |
| A           | 860          |
| B           | 940          |
| C           | 360          |

- Total points for Customer A is $860.
- Total points for Customer B is $940.
- Total points for Customer C is $360.

---

### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?
```sql
SELECT M.customer_id, 
       SUM(
           CASE
               WHEN MN.product_name = 'sushi' THEN 2 * 10 * MN.price
               WHEN S.order_date BETWEEN join_date AND DATEADD(DAY, 6, join_date) THEN 2 * 10 * MN.price
               ELSE 10 * MN.price
           END
       ) AS points
FROM members M
JOIN sales S ON M.customer_id = S.customer_id
JOIN menu MN ON S.product_id = MN.product_id
WHERE order_date < '2021-02-01' AND order_date >= join_date
GROUP BY M.customer_id
```

**Answer:**
| customer_id | total_points |
| ----------- | ------------ |
| A           | 1020         |
| B           | 320          |

- Total points for Customer A is 1,020.
- Total points for Customer B is 320.

---

## BONUS QUESTIONS

### Join All The Things

### Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)
```sql
SELECT S.customer_id, S.order_date, MN.product_name, MN.price, IIF(join_date IS NULL OR join_date > order_date, 'N', 'Y') AS membership
FROM members M
RIGHT JOIN sales S ON M.customer_id = S.customer_id
JOIN menu MN ON S.product_id = MN.product_id
ORDER BY order_date
```

**Answer:**
| customer_id | order_date | product_name | price | member |
| ----------- | ---------- | ------------ | ----- | ------ |
| A           | 2021-01-01 | sushi        | 10    | N      |
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-02-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-07 | ramen        | 12    | N      |

---

### Rank All The Things

### Danny requires further information about the `ranking` of customer products, but he purposely does not need the ranking for non-member purchases so he expects null `ranking` values for the records when customers are not yet part of the loyalty program.

```sql
SELECT *,
       CASE
           WHEN membership = 'N' THEN NULL
           ELSE DENSE_RANK() OVER(PARTITION BY customer_id, membership ORDER BY order_date)
       END AS ranking
FROM (
    SELECT S.customer_id, S.order_date, MN.product_name, MN.price, IIF(join_date IS NULL OR join_date > order_date, 'N', 'Y') AS membership
    FROM members M
    RIGHT JOIN sales S ON M.customer_id = S.customer_id
    JOIN menu MN ON S.product_id = MN.product_id
) AS newTab
```

**Answer:**
| customer_id | order_date | product_name | price | member | ranking |
| ----------- | ---------- | ------------ | ----- | ------ | ------- |
| A           | 2021-01-01 | sushi        | 10    | N      | NULL    |
| A           | 2021-01-01 | curry        | 15    | N      | NULL    |
| A           | 2021-01-07 | curry        | 15    | Y      | 1       |
| A           | 2021-01-10 | ramen        | 12    | Y      | 2       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| B           | 2021-01-01 | curry        | 15    | N      | NULL    |
| B           | 2021-01-02 | curry        | 15    | N      | NULL    |
| B           | 2021-01-04 | sushi        | 10    | N      | NULL    |
| B           | 2021-01-11 | sushi        | 10    | Y      | 1       |
| B           | 2021-01-16 | ramen        | 12    | Y      | 2       |
| B           | 2021-02-01 | ramen        | 12    | Y      | 3       |
| C           | 2021-01-01 | ramen        | 12    | N      | NULL    |
| C           | 2021-01-01 | ramen        | 12    | N      | NULL    |
| C           | 2021-01-07 | ramen        | 12    | N      | NULL    |

---