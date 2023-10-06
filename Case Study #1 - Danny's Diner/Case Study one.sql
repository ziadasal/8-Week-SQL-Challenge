CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');


--1) What is the total amount each customer spent at the restaurant?
select customer_id, sum(price) 'total amount' 
from sales S 
join menu M
on S.product_id = M.product_id
group by customer_id

--2) How many days has each customer visited the restaurant?
select customer_id, count(distinct order_date) 
from sales
group by customer_id


--3) What was the first item from the menu purchased by each customer?
select distinct customer_id, product_name , order_date 
from 
(select customer_id,order_date,product_id , DENSE_RANK() over(partition by customer_id order by order_date) ranking 
from sales) as newtable
join menu
on newtable.product_id = menu.product_id
where ranking=1

--4) What is the most purchased item on the menu and how many times was it purchased by all customers?
select top(1) product_name , count(S.product_id) 'number of purchased'
from sales S
join menu M
on S.product_id = M.product_id
group by (product_name)
order by 'number of purchased' desc
--5) Which item was the most popular for each customer?
select customer_id, product_name, number 'number of purchased'
from (
select customer_id, product_name ,count(sales.product_id) number,
	DENSE_RANK() over( partition by customer_id order by count(sales.product_id) desc ) ranking
from sales
join menu
on sales.product_id = menu.product_id
group by customer_id , product_name
) as newTable
where ranking = 1
--6) Which item was purchased first by the customer after they became a member?
select customer_id,product_name,order_date
from
(
select M.customer_id,product_name, order_date , M.join_date, DENSE_RANK() over(partition by S.customer_id order by order_date) Ranking
from members M
join sales S
on M.customer_id = S.customer_id
join menu MN
on S.product_id = MN.product_id
where order_date>join_date
) as newTable
where Ranking=1

--7) Which item was purchased just before the customer became a member?
select customer_id,product_name,order_date
from
(
select M.customer_id,product_name, order_date , M.join_date, DENSE_RANK() over(partition by S.customer_id order by order_date desc) Ranking
from members M
join sales S
on M.customer_id = S.customer_id
join menu MN
on S.product_id = MN.product_id
where order_date<join_date
) as newTable
where Ranking=1

--8) What is the total items and amount spent for each member before they became a member?
select customer_id ,count(newtable.product_id) total_items ,Sum(price) total_sales
from
(
select M.customer_id ,S.product_id
from members M
join sales S
on M.customer_id = S.customer_id
join menu MN
on S.product_id = MN.product_id
where order_date<join_date
) as newTable
join menu MN
on newTable.product_id = MN.product_id
group by customer_id


--9) If each $1 spent equates to 10 points and sushi has a 2x points multiplier -
-- how many points would each customer have?
select customer_id, sum(iif(product_name = 'sushi',price*20,price*10)) total_points
from sales
join menu
on sales.product_id = menu.product_id
group by customer_id
--10) In the first week after a customer joins the program (including their join date) 
-- they earn 2x points on all items, not just sushi - 
-- how many points do customer A and B have at the end of January?
select M.customer_id , 
sum(
	CASE
    WHEN MN.product_name = 'sushi' THEN 2 * 10 * MN.price
    WHEN S.order_date BETWEEN join_date AND DATEADD(day,6,join_date) THEN 2 * 10 * MN.price
    ELSE 10 * MN.price END
)AS points
from members M
join sales S
ON M.customer_id=S.customer_id
join menu MN 
ON S.product_id = MN.product_id
where order_date < '2021-02-01' and order_date>= join_date
group by M.customer_id


-----------Bonus Questions
--Join All The Things
select S.customer_id,S.order_date,MN.product_name,MN.price ,iif(join_date is null or join_date>order_date,'N','Y') membership
from members M
right join sales S
on M.customer_id = S.customer_id
 join menu MN
on S.product_id = MN.product_id
order by order_date
--Rank All The Things
select *,
Case 
	When membership = 'N' Then Null
	Else DENSE_RANK() over(partition by customer_id,membership order by order_date)
	End  ranking
from (
select S.customer_id,S.order_date,MN.product_name,MN.price ,iif(join_date is null or join_date>order_date,'N','Y') membership
from members M
right join sales S
on M.customer_id = S.customer_id
join menu MN
on S.product_id = MN.product_id
) as newTab