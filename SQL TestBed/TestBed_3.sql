select 'No Contract' Description where 1=1
union
select
	Description
from [dbo].[FC_Funder_Contract]
where 
	1=1
	AND (Description like 'CHSP%' )
	
order by 1