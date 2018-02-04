declare @Start_Date date = cast('2017-07-01' as date)
declare @End_Date date = cast('2017-07-20' as date)


--/*
select distinct
	t1.employee_id
--	,t1.employee_name
--	,t2.full_date as pay_period_end_date
--	, t1.period_amount as gross 
	,sum(t1.period_amount)over(partition by t1.employee_id)'TotalInPeriod'
from [az-sqlbi01].dwhf_comcare.comcare.employee_payment_summary_fact t1
inner join 	[az-sqlbi01].dwhf_comcare.comcare.date_dim t2 on t1.pay_period_date_key = t2.date_key

where
	t2.full_date between @Start_Date and @End_Date
--	and t1.employee_id in (@Employee_ID)

	and t1.employee_id = 7412

--*/
/*
select distinct
	dateadd(day,-13,cast(t2.full_date as date)) 'pay_period_Start_date'
from [az-sqlbi01].dwhf_comcare.comcare.employee_payment_summary_fact t1
inner join 	[az-sqlbi01].dwhf_comcare.comcare.date_dim t2 on t1.pay_period_date_key = t2.date_key

select distinct
	cast(t2.full_date as date) 'pay_period_end_date'
from [az-sqlbi01].dwhf_comcare.comcare.employee_payment_summary_fact t1
inner join 	[az-sqlbi01].dwhf_comcare.comcare.date_dim t2 on t1.pay_period_date_key = t2.date_key
*/

--select top 1 * from [az-sqlbi01].dwhf_comcare.comcare.employee_payment_summary_fact t1