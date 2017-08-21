select Distinct
	J001.Client_ID
	,Count(J001.Client_ID)over(Partition by J001.Client_ID)'EntryCount'
	,Sum(J001.Amount)over(Partition by J001.Client_ID)'amount'
from dbo.Actual_Service_Charge_Item J001
Order by J001.Client_ID