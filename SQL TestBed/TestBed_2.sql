
/*
select * from[dbo].PT_Package_Summary
where client_id = 10000025

select * from[dbo].Actual_Service_Charge_Item
where client_id = 10000025


select * from[dbo].FB_Client_CB_Transaction


select * from[dbo].FC_Account

select * from[dbo].FC_Transaction

select * from [dbo].PT_Package_Summary
where client_id = 10000025

select * from [dbo].PT_Program

select * from [dbo].PT_Package_Parameter

select * from [dbo].PT_Expense_Type 

select * from [dbo].PT_Expenses
--where Client_Contract_ID = 144


select * from [dbo].FC_Transaction --BAM this is the main one , FC_Account_ID - opperating account

select * from [dbo].FC_Account --FC_Account_ID Client_Contract_ID
where FC_Account_ID = 3262

select * from [dbo].FC_Client_Contract -- Client_Contract_ID yay link to client.
where Client_Contract_ID = 1088


Package_Summary_ID
Client_Contract_ID

client_ID
date
task
Actual service
opperating accout


select * from [dbo].FC_Area





select * from [dbo].FC_Funding_Care_Model --Funding_Care_Model_ID
select * from [dbo].FC_Funder_Contract --funder_Contract_ID
select * from [dbo].FC_Client_Contract --client_Contract_ID , client_ID
select * from [dbo].FC_Account --FC_Account_ID Client_Contract_ID
select * from [dbo].FC_Transaction --BAM this is the main one , FC_Account_ID - opperating account

select * from [dbo].Actual_Service
where client_ID =  10000049
*/

/*
------------------------------------------------------------------------------------
--DECLARE @StartDate AS DATETIME = '20160416 00:00:00.000'
--DECLARE @EndDate AS DATETIME = '20160501 00:00:00.000'

DECLARE @StartDate AS DATETIME = '20170314 00:00:00.000'
DECLARE @EndDate AS DATETIME = '20170314 00:00:00.000'

--PACKAGE ACTUALS!!!!!!!!!!!!!!!!!!

------------------------------------------------------------------------------------
Select
	J001.Description 'CareModel'
	,J002.Description 'funderContract'
	,J003.Client_ID
	,J005.Activity_Date
	,J005.Transaction_Source
	,J005.RN
	,J005.Estimated_Amount
	,J005.Actual_Amount
	,J005.Balance_After_Txn
	,J005.Source_Table
	,J006.Task_Type_Code
	,J007.Description 'Task_Type'
	,J006.Activity_Start_Time
	,J006.Visit_Duration
	,J006.Client_Not_Home
	,J006.Provider_ID
	,J005.Comments
	

From [dbo].FC_Funding_Care_Model J001
Left outer join [dbo].FC_Funder_Contract J002 on J002.Funding_Care_Model_ID = J001.Funding_Care_Model_ID
Left outer Join [dbo].FC_Client_Contract J003 on J003.funder_Contract_ID = J002.funder_Contract_ID

Left outer join [dbo].Actual_Service J006 on J006.Client_ID = J003.Client_ID 
Left outer join [dbo].Task_Type J007 on J007.Task_Type_code = J006.Task_Type_Code

Left outer join [dbo].FC_Account J004 on J004.client_Contract_ID = J003.client_Contract_ID

--Left outer join [dbo].FC_Transaction J005 on J005.FC_Account_ID = J004.FC_Account_ID and J006.Visit_Date = J005.Activity_Date

Left outer join 
(
	select --top 1
		*
		/*
		FC_T.FC_Account_ID 'FC_Account_ID'
		,FC_T.FC_Transaction_Type_ID 'FC_Transaction_Type_ID'
		,FC_T.Activity_Date 'Activity_Date'
		,FC_T.Transaction_Source 'Transaction_Source'
		,FC_T.Estimated_Amount 'Estimated_Amount'
		,FC_T.Actual_Amount 'Actual_Amount'
		,FC_T.Balance_After_Txn 'Balance_After_Txn'
		,FC_T.Source_Table 'Source_Table'
		,FC_T.Comments 'Comments'
		*/
		,ROW_NUMBER() over(
							partition by FC_T.FC_Account_ID, FC_T.Activity_Date
							order by 
							case
							when FC_T.Actual_Amount = 0.0 then 'zzzz'
							else 
							FC_T.Actual_Amount --desc
							end desc
						)'RN'
	from [dbo].FC_Transaction FC_T
	where 
		1=1
		and FC_T.FC_Transaction_Type_ID = 3
		and FC_T.Actual_Amount <> 0.0

)J005 on J005.FC_Account_ID = J004.FC_Account_ID and J006.Visit_Date = J005.Activity_Date


Where
	1=1
	and J001.Description = 'Home Care Package'
	and J005.Activity_Date between @StartDate and (DATEADD(s, 84599, @EndDate))
--	and J005.Actual_Amount <> 0.0
--	and J005.Activity_Date is null
	and J003.Client_ID = 10057147
	and J005.RN < 2
--	/*
group by
	J001.Description
	,J002.Description
	,J003.Client_ID
	,J005.Activity_Date
	,J005.Transaction_Source
	,J005.RN
	,J005.Estimated_Amount
	,J005.Actual_Amount
	,J005.Balance_After_Txn
	,J005.Source_Table
	,J006.Task_Type_Code
	,J007.Description
	,J006.Activity_Start_Time
	,J006.Visit_Duration
	,J006.Client_Not_Home
	,J006.Provider_ID
	,J005.Comments
--	*/
order by
	J003.Client_id
	,2
	,J005.Activity_Date
	,J006.Activity_Start_Time
--*/

use ComCareProd


/*
DECLARE @tags NVARCHAR(400) = 'clothing,road,,touring,bike'  

SELECT *  
FROM splitNew(@tags, ',')  

*/


DECLARE @StartDate AS DATETIME = '20170104 00:00:00.000'
DECLARE @EndDate AS DATETIME = '20170104 00:00:00.000'
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

Select
	J001.Description 'CareModel'
	,J002.Description 'funderContract'
	,J003.Client_ID
	,J005.Activity_Date
	,J005.Transaction_Source
--	,J005.RN
--	,J005.Estimated_Amount
	,J005.Actual_Amount
--	,J005.Balance_After_Txn
	,J005.Source_Table
	,J005.Source_Record_Key
	,J006.Task_Type_Code
--	,J007.Description 'Task_Type'
	,J006.Activity_Start_Time
	,J006.Visit_Duration
	,J006.Client_Not_Home
	,J006.Provider_ID
	,J005.Comments
	

From [dbo].FC_Funding_Care_Model J001
Left outer join [dbo].FC_Funder_Contract J002 on J002.Funding_Care_Model_ID = J001.Funding_Care_Model_ID
Left outer Join [dbo].FC_Client_Contract J003 on J003.funder_Contract_ID = J002.funder_Contract_ID

Left outer join [dbo].Actual_Service J006 on J006.Client_ID = J003.Client_ID 
Left outer join [dbo].Task_Type J007 on J007.Task_Type_code = J006.Task_Type_Code

Left outer join [dbo].FC_Account J004 on J004.client_Contract_ID = J003.client_Contract_ID

--Left outer join [dbo].FC_Transaction J005 on J005.FC_Account_ID = J004.FC_Account_ID and J006.Visit_Date = J005.Activity_Date

Left outer join 
(
	select --top 1
		FC_T.FC_Account_ID 'FC_Account_ID'
		,FC_T.FC_Transaction_Type_ID 'FC_Transaction_Type_ID'
		,FC_T.Activity_Date 'Activity_Date'
		,FC_T.Transaction_Source 'Transaction_Source'
		,FC_T.Estimated_Amount 'Estimated_Amount'
		,FC_T.Actual_Amount 'Actual_Amount'
		,FC_T.Balance_After_Txn 'Balance_After_Txn'
		,FC_T.Source_Table 'Source_Table'
		,FC_T.Source_Record_Key 'Source_Record_Key'
		,FC_T.Comments 'Comments'
		,ROW_NUMBER() over(
							partition by FC_T.FC_Account_ID, FC_T.Activity_Date
							order by 
							case
							when FC_T.Actual_Amount = 0.0 then 'zzzz'
							else 
							FC_T.Actual_Amount --desc
							end desc
						)'RN'
	from [dbo].FC_Transaction FC_T
	where 
		1=1
		and FC_T.FC_Transaction_Type_ID = 3
		and FC_T.Actual_Amount <> 0.0

)J005 on J005.FC_Account_ID = J004.FC_Account_ID and J006.Visit_Date = J005.Activity_Date


Where
	1=1
	and J001.Description = 'Home Care Package'
	and J005.Activity_Date between @StartDate and (DATEADD(s, 84599, @EndDate))
--	and J005.Actual_Amount <> 0.0
--	and J005.Activity_Date is null
--	and J003.Client_ID = 10001360
	and J005.RN < 2
--	/*
group by
	J001.Description
	,J002.Description
	,J003.Client_ID
	,J005.Activity_Date
	,J005.Transaction_Source
	,J005.RN
	,J005.Estimated_Amount
	,J005.Actual_Amount
	,J005.Balance_After_Txn
	,J005.Source_Table
	,J005.Source_Record_Key
	,J006.Task_Type_Code
	,J007.Description
	,J006.Activity_Start_Time
	,J006.Visit_Duration
	,J006.Client_Not_Home
	,J006.Provider_ID
	,J005.Comments
--	*/
order by
	J003.Client_id
	,J005.Activity_Date
	,J006.Activity_Start_Time