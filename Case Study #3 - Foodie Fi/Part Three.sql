with dataRecurtion as (
select s.customer_id,
		p.plan_id,
		p.plan_name,
		s.start_date payment_date,
		case when lead(s.start_date) over(partition by s.customer_id order by start_date) is null then '2020-12-31'
		else DATEADD(month,
		  DATEDIFF(MONTH, start_date, LEAD(s.start_date) OVER(PARTITION BY s.customer_id ORDER BY s.start_date)),start_date) 
		end last_date,
		p.price amount
from subscriptions s
join plans p
on s.plan_id = p.plan_id
where p.plan_id <> 0 and year(start_date) ='2020'
union all

select 
	customer_id,
	plan_id,
	plan_name,
	DATEADD(MONTH, 1, payment_date) AS payment_date,
    last_date,
	amount
from dataRecurtion
WHERE DATEADD(MONTH, 1, payment_date) <= last_date AND plan_name != 'pro annual'

)


select customer_id,plan_id,plan_name,payment_date,amount,ROW_NUMBER() over (partition by customer_id order by payment_date) payment_order
into payment
from dataRecurtion
where amount is not null
order by customer_id
