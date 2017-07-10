use ComCareProd
--select * from FC_Client_Contract where	client_ID = 10001360
--select * from [dbo].FC_Transaction where client_ID = 10001360
--select * from dbo.FC_Account where Client_Contract_ID = 1161
--select * from dbo.FC_Account where FC_Account_ID =3640
--select * from dbo.FC_Claim_History_Detail where Claim_History_Detail_ID = 18169
/*
select * from dbo.FC_Client_Contract where	client_ID = 10000049
select * from dbo.FC_Account  where (Client_Contract_ID = 1982 or Client_Contract_ID = 1507) and FC_Account_Type_ID = 1
select * from dbo.FC_Client_Supplement where (Client_Contract_ID = 1982 or Client_Contract_ID = 1507)
select * from dbo.FC_Supplement_Rate where 


select 
	FCFC.Description 
from dbo.FC_Funding_Care_Model FCCC 
Left outer Join dbo.FC_Funder_Contract FCFC	on FCFC.Funding_Care_Model_ID = FCCC.Funding_Care_Model_ID
where 
	FCCC.Description = 'Home Care Package'
*/
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
--	,J005.Override_Rate
	,J007.FC_Supplement_ID
	,J007.Supplement_Rate
	,J002.Description 'funderContract'
	,J003.Description 'CareModel'
from dbo.FC_Client_Contract J001
Left outer Join dbo.FC_Funder_Contract J002	on J002.funder_Contract_ID = J001.funder_Contract_ID
Left outer Join dbo.FC_Funding_Care_Model J003 on J003.Funding_Care_Model_ID = J002.Funding_Care_Model_ID
Left outer join dbo.FC_Account J004 on J004.client_Contract_ID = J001.client_Contract_ID and J004.FC_Account_Type_ID = 1
--/*
inner join 
(
	select
	*
	from dbo.FC_Client_Supplement CS
)J005 on 
	J005.client_Contract_ID = J004.client_Contract_ID

--*/
inner join dbo.Person J006 on J006.Person_ID = J001.Client_ID
Left outer join dbo.FC_Supplement_Rate J007 on J007.FC_Supplement_ID = J005.FC_Supplement_ID and J007.Program_Level_ID = J001.Program_Level_ID
where
	J003.Description  = 'Home Care Package'
--	and cast(J005.Transaction_Date as date) between @StartDate and @EndDate
	and J002.Description in (@FunderContract)
	--Debug
	and J001.Client_ID = 10000049
	and J007.Effective_To_Date is null
	and J001.Effective_To_Date is null

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
--	,J005.Override_Rate
	,J007.FC_Supplement_ID
	,J007.Supplement_Rate
	,J002.Description
	,J003.Description
--*/
order by
	1,3--,J005.FC_Transaction_ID * 1