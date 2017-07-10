use ComCareProd
--select * from FC_Client_Contract where	client_ID = 10001360
--select * from [dbo].FC_Transaction where client_ID = 10001360
--select * from dbo.FC_Account where Client_Contract_ID = 1161
--select * from dbo.FC_Account where FC_Account_ID =3640
--select * from dbo.FC_Claim_History_Detail where Claim_History_Detail_ID = 18169

select 
	FCFC.Description 
from dbo.FC_Funding_Care_Model FCCC 
Left outer Join dbo.FC_Funder_Contract FCFC	on FCFC.Funding_Care_Model_ID = FCCC.Funding_Care_Model_ID
where 
	FCCC.Description = 'Home Care Package'

DECLARE @StartDate AS DATE = '20160101 00:00:00.000'
DECLARE @EndDate AS DATE = '20170601 00:00:00.000'
Declare @FunderContract as Varchar(128) = 'Northern Care at Home'

---------------------------------------------------------------------------------------------------------------------------

select
	J001.Client_ID 'Client_ID'
	,Concat(J006.Preferred_Name,' ',J006.Last_Name)'ClientName'
	,J001.Client_Contract_ID
	,J001.Effective_From_Date
	,J001.Effective_To_Date
	,J001.Program_Level_ID
	,J001.Amount_Transferred_In
	,J001.Amount_Transferred_Out
	,J004.FC_Account_ID 'FC_Account_ID'
	,J005.Transaction_Date 'Transaction_Date'
	,J005.FC_Transaction_ID
	,J005.Comments 'Line_Description'
	,J005.Source_Table 'Source_Table'
	,J005.Source_Record_Key 'Source_Record_Key'
	,(J005.Actual_Amount * 1.0) 'Amount'
	,J005.Activity_Type 'Activity_Type'
	,J002.Description 'funderContract'
	,J003.Description 'CareModel'
from dbo.FC_Client_Contract J001
Left outer Join dbo.FC_Funder_Contract J002	on J002.funder_Contract_ID = J001.funder_Contract_ID
Left outer Join dbo.FC_Funding_Care_Model J003 on J003.Funding_Care_Model_ID = J002.Funding_Care_Model_ID
Left outer join dbo.FC_Account J004 on J004.client_Contract_ID = J001.client_Contract_ID and J004.FC_Account_Type_ID = 1

inner join 
(
	select
		FC_T.FC_Account_ID 'FC_Account_ID'
		,cast(FC_T.FC_Transaction_Type_ID as int) 'FC_Transaction_Type_ID'
		,FC_T.Activity_Date 'Transaction_Date'
		,FC_T.Transaction_Source 'Transaction_Source'
		,FC_T.Estimated_Amount 'Estimated_Amount'
		,FC_T.Actual_Amount 'Actual_Amount'
		,FC_T.Balance_After_Txn 'Balance_After_Txn'
		,FC_T.Source_Table 'Source_Table'
		,FC_T.Source_Record_Key 'Source_Record_Key'
		,FC_T.Comments 'Comments'
		,FC_T.FC_Transaction_ID 'FC_Transaction_ID'
		,FC_T.Activity_Type 'Activity_Type'
	from [dbo].FC_Transaction FC_T
	where 
		1=1
		and (
				FC_T.FC_Transaction_Type_ID = 5 
				or FC_T.FC_Transaction_Type_ID = 8
				or FC_T.FC_Transaction_Type_ID = 9
			)

)J005 on 
	J005.FC_Account_ID = J004.FC_Account_ID
--	and 1=iif(J005.Source_Table = 'FC_Client_Contract' and J005.Source_Record_Key = J001.Client_Contract_ID,1,1)

inner join dbo.Person J006 on J006.Person_ID = J001.Client_ID

where
	J003.Description  = 'Home Care Package'
	and cast(J005.Transaction_Date as date) between @StartDate and @EndDate
	and J002.Description in (@FunderContract)
	--Debug
--	and J001.Client_ID = 10019136

--/*
Group by
	J001.Client_ID
	,Concat(J006.Preferred_Name,' ',J006.Last_Name)
	,J001.Client_Contract_ID
	,J001.Effective_From_Date
	,J001.Effective_To_Date
	,J001.Program_Level_ID
	,J001.Amount_Transferred_In
	,J001.Amount_Transferred_Out
	,J004.FC_Account_ID
	,J005.Transaction_Date
	,J005.FC_Transaction_ID
	,J005.Comments
	,J005.Source_Table
	,J005.Source_Record_Key
	,(J005.Actual_Amount * 1.0)
	,J005.Activity_Type
	,J002.Description
	,J003.Description
--*/
order by
	1,3,J005.FC_Transaction_ID * 1
