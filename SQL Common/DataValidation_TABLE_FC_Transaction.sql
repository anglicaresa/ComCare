

select Distinct
		FC_CC.Client_ID 'Client_ID'
	,count(FC_CC.Client_ID)over(Partition by FC_CC.Client_ID) 'entryCount'
	,sum(FC_T.Actual_Amount)over(partition by FC_CC.Client_ID) 'Amount'
from [dbo].FC_Client_Contract FC_CC
Left outer join [dbo].FC_Account FC_A on FC_A.client_Contract_ID = FC_CC.client_Contract_ID
Left outer join 
(
	select
		FC_T.FC_Account_ID 'FC_Account_ID'
		,FC_T.Actual_Amount 'Actual_Amount'
	from dbo.FC_Transaction FC_T
)FC_T on FC_T.FC_Account_ID = FC_A.FC_Account_ID
order by Client_ID