
--select distinct Activity_type from FC_Transaction
--select Description from dbo.FC_Transaction_Type

declare @TransactionType table(Type VarChar(128))
insert into @TransactionType
	select 
		TT.Description 
	from dbo.FC_Transaction_Type TT 
	where 1=1



declare @Client_ID int = 10104433
declare @FiltIncomeTested int = 1

select 
	J001.Client_ID
	,Concat(J006.Last_Name,', ',J006.Preferred_Name)'ClientName'
	,J005.*

from [dbo].FC_Client_Contract J001
Left outer Join [dbo].FC_Funder_Contract J002	on J002.funder_Contract_ID = J001.funder_Contract_ID
Left outer Join [dbo].FC_Funding_Care_Model J003 on J003.Funding_Care_Model_ID = J002.Funding_Care_Model_ID
Left outer join [dbo].FC_Account J004 on J004.client_Contract_ID = J001.client_Contract_ID

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
where
	1=1
	and J001.Client_ID = @Client_ID
	--and J005.Transaction_Type in (@TransactionType)
	and J005.Transaction_Type in (select * from @TransactionType)

order by
J005.Activity_Date
,J005.TransationDate

