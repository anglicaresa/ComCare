
--select distinct Activity_type from FC_Transaction
--select Description from dbo.FC_Transaction_Type
--use ComCareProd
--/*
declare @TransactionType table(Type VarChar(128))

insert into @TransactionType
	select 
		FC_TT1.Description
	from dbo.FC_Transaction_Type FC_TT1 
	where 
	1=1
	and FC_TT1.Description = 'Administrative Overheads'
--*/


declare @Client_ID int = 10063049
declare @FiltIncomeTested int = 1


Declare @FunderContract_ID Table 
(
	Description Varchar(128)
	,Funder_Contract_ID int
)
insert into @FunderContract_ID
select
	J002.Description
	,J002.Funder_Contract_ID
from dbo.FC_Client_Contract J001
Left outer Join dbo.FC_Funder_Contract J002	on J002.funder_Contract_ID = J001.funder_Contract_ID
where J001.Client_ID = @Client_ID and J001.End_Date_of_Claim is null

--select * from @FunderContract_ID

--------------<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<here down
select --distinct
	J001.Client_ID
	,Concat(J006.Last_Name,', ',J006.Preferred_Name)'ClientName'
	,J005.*
from dbo.FC_Client_Contract J001
Left outer Join dbo.FC_Funder_Contract J002	on J002.funder_Contract_ID = J001.funder_Contract_ID
Left outer Join dbo.FC_Funding_Care_Model J003 on J003.Funding_Care_Model_ID = J002.Funding_Care_Model_ID
Left outer join dbo.FC_Account J004 on J004.client_Contract_ID = J001.client_Contract_ID

Left outer join 
(
	select --distinct
		FC_T.FC_Account_ID 'FC_Account_ID'
		,FC_TT.Description 'Transaction_Type'
		,FC_T.Transaction_Source 'Transaction_Source'
		,FC_T.Actual_Amount 'Actual_Amount'
		,FC_T.Balance_After_Txn 'Balance_After_Txn'
		,FC_T.Comments 'Comments'
		,FC_T.Activity_Date
		,Cast(Concat(Cast(Year(FC_T.Activity_Date) as VarChar(4)),'-',Cast(Datepart(MM,FC_T.Activity_Date) as VarChar(4)),'-01')as date) 'Activity_Period'
		,FC_T.Exported_Date
		,FC_T.Creation_Date 'TransationDate'
		,FCP.Period_Start_Date
--		,SUM(FC_T.Actual_Amount)'TotalAmountSum'
		,case
			 when FC_T.Activity_Type = 'A' then 'Added'
			 when FC_T.Activity_Type = 'C' then 'Changed'
			 when FC_T.Activity_Type = 'D' then 'Deleted'
			 when FC_T.Activity_Type = 'G' then 'Generated'
			 when FC_T.Activity_Type = 'T' then 'Transfer'
			else null
		end 'Activity_Type'
	from dbo.FC_Transaction FC_T
	left outer join dbo.FC_Transaction_Type FC_TT on FC_T.FC_Transaction_Type_ID = FC_TT.FC_Transaction_Type_ID
	left outer join dbo.FC_Funding_Care_Model_Period FCP on FCP.Funding_Care_Model_Period_ID = FC_T.Funding_Care_Model_Period_ID
	where 
		1=1
)J005 on J005.FC_Account_ID = J004.FC_Account_ID
left outer join dbo.Person J006 on J006.Person_ID = J001.Client_ID
left outer join dbo.FC_Account_Type J007 on J007.FC_Account_Type_ID = J004.FC_Account_Type_ID
where
	1=1
	and J001.Client_ID = @Client_ID
	--and J005.Transaction_Type in (@TransactionType)
--	and J005.Transaction_Type in (select * from @TransactionType)

	and 1 = IIF( J005.Comments like '%Income Tested%', 1, @FiltIncomeTested)
	and J007.Description ='Operating Account'
--	and J002.Funder_Contract_ID in (@FunderContract_ID)
	and J002.Funder_Contract_ID in (select Funder_Contract_ID from @FunderContract_ID)
--	and J005.Exported_Date is not null

--	
--/*
order by
J005.TransationDate
,J005.Activity_Date
--*/