/*
select distinct
	t1.employee_id
	,t1.employee_name
	,t2.full_date as pay_period_end_date
	, t1.period_amount as gross 
from [az-sqlbi01].dwhf_comcare.comcare.employee_payment_summary_fact t1
inner join 	[az-sqlbi01].dwhf_comcare.comcare.date_dim t2 on t1.pay_period_date_key = t2.date_key
order by 
	2,3
*/
select distinct
	t2.full_date as pay_period_end_date
from [az-sqlbi01].dwhf_comcare.comcare.employee_payment_summary_fact t1
inner join 	[az-sqlbi01].dwhf_comcare.comcare.date_dim t2 on t1.pay_period_date_key = t2.date_key