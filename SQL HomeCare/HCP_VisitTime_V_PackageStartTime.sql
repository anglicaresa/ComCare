use ComCareProd
/*
--@Organisation 
select 
	J101.Organisation_name 
	,J101.Organisation_ID
from dbo.organisation J101
where
	1=1
	and Organisation_Type_Code = 1
	and (
			J101.Organisation_name like 'Home Care%'
			or J101.Organisation_name like 'Disabilitie%'
		)
	and J101.Organisation_name <> 'Disabilities Adult'

--*/
/*

select * from dbo.Funding_Program 
select * from dbo.FC_Contract_Area_Product
select * from dbo.FC_Area_Covered
select * from dbo.FC_Funder_Contract_GL_Mapping
select * from dbo.Task_Type
select * from dbo.Service_Provision_Position
select * from dbo.Service_Type
select * from dbo.FC_Transaction
select * from dbo.service_delivery where client_id = 10022806
--*/
--select top 1 * from dbo.Actual_Service
------------------------------------------------------------
--select * from dbo.service_delivery where client_id = 10022806

declare @Organisation Varchar(128) = 'Home Care North'
declare @StartDate date = cast('2017-01-01' as date)
declare @EndDate date = cast('2017-03-31' as date)
declare @ChargeItemTest int = 0

------------------------------------------------------------
Select * from
(
	select 
		J006.Organisation_Name 'Organisation_Name'
		,J001.Client_ID 'Client_ID'
		,J007.Description 'ServiceType'
		,cast(J005.From_Date as datetime) 'From_Date'
		,cast(J005.To_Date as datetime) 'To_Date'
		,cast(J001.Activity_Start_Time as datetime)'Activity_Start_Time'
		,J008.Description 'TaskType'
		,J001.Provider_ID 'Provider_ID'
		,J088.Funding_Prog_Code 'Funding_Prog_Code'
		,J001.CAP_ID 'CAP_ID'
		,J001.Est_Visit_Charge 'Est_Visit_Charge'
		,J004.Description 'FundingProgram'
		,IIF (cast(J001.Activity_Start_Time as datetime) between cast(J005.From_Date as datetime) and IIF(J005.To_Date is null, dateadd (d, 30, GetDate()), cast(J005.To_Date as DateTime)),'In','Out')'ContractState'
		,ROW_NUMBER()
			over
			(
				partition by 
					J001.Client_ID, J001.Activity_Start_Time, J001.Task_Type_Code 
				order by case
					when cast(J001.Activity_Start_Time as datetime) between cast(J005.From_Date as datetime) and IIF(J005.To_Date is null, dateadd (d, 1, GetDate()), cast(J005.To_Date as DateTime)) then 1
					else '2'
				end
		)'RN'

	From
	(
		select
			A_S.Client_ID
			,iif
			(
				A_S.Activity_Start_Time is null
				,A_S.Visit_Date + Cast(A_S.Visit_time as time)
				,A_S.Activity_Start_Time
			)'Activity_Start_Time'
			,A_S.Provider_ID
			,A_S.Funding_Prog_Code
			,A_S.CAP_ID
			,A_S.Task_Type_Code
			,A_S.Service_Prov_Position_ID
			,A_S.Visit_Date
			,A_S.Visit_Time
			,A_S.Visit_No
			,A_S.Est_Visit_Charge
		From dbo.Actual_Service A_S
		where
		A_S.Visit_Date Between @StartDate and @EndDate
	)J001


	Left outer Join 
	(
		select --top 1
			FC_AP.CAP_ID
			,FC_AP.Funding_Prog_Code
		from dbo.FC_Contract_Area_Product FC_AP
	)J088 on J088.CAP_ID = J001.CAP_ID

	Left outer Join dbo.FC_Product_Mapping J002 on J002.Task_Type_Code = J001.Task_Type_Code
	Left outer Join dbo.Funding_Program J004 on J004.Funding_Prog_Code = J088.Funding_Prog_Code
	Left outer join dbo.Task_Type J008 on J008.Task_Type_Code = J001.Task_Type_Code
	Left outer Join dbo.Service_Delivery J005 
		on 
			J005.Funding_Prog_Code = J088.Funding_Prog_Code 
			and J005.Client_ID = J001.Client_ID
			and J005.Service_Type_Code = J008.Service_Type_Code

	Left outer join dbo.Service_Provision_Position J010 on J010.Service_Prov_Position_ID = J001.Service_Prov_Position_ID
	Left outer join dbo.Organisation J006 on J006.Organisation_ID = J010.Centre_ID


	Left outer join dbo.Service_Type J007 on J007.Service_Type_Code = J008.Service_Type_Code
	/*
	Left outer join
	(
		select 
			ACSI.Client_ID	
			,ACSI.Visit_Date
			,ACSI.Visit_No
			,ACSI.Service_Prov_Position_ID
		from dbo.Actual_Service_Charge_Item ACSI
	)J009
		ON 
			J009.Client_ID = J001.Client_ID 
			and J009.Visit_Date = J001.Visit_Date 
			and J009.Visit_No = J001.Visit_No 
			and J009.Service_Prov_Position_ID = J001.Service_Prov_Position_ID
	--*/
	--/*
	Left outer Join
	(
		select
			FC_CC.Client_ID 'Client_ID'
			,FC_T.Visit_Date 'Visit_Date'
			,FC_T.Comments 'Line_Description'
			,cast ((select Text from dbo.Split(FC_T.Source_Record_Key, '/') where Record_Number = 3) as int) 'Visit_No'
			,cast ((select Text from dbo.Split(FC_T.Source_Record_Key, '/') where Record_Number = 5) as int) 'Service_Prov_Position_ID'
			,cast ((select Text from dbo.Split(FC_T.Source_Record_Key, '/') where Record_Number = 4) as int) 'Provider_ID'
			,(FC_T.Actual_Amount * -1.0) 'Amount'
			,FC_FC.Description 'funderContract'
			,FC_FCM.Description 'CareModel'
		from [dbo].FC_Client_Contract FC_CC
		Left outer Join [dbo].FC_Funder_Contract FC_FC	on FC_FC.funder_Contract_ID = FC_CC.funder_Contract_ID
		Left outer Join [dbo].FC_Funding_Care_Model FC_FCM on FC_FCM.Funding_Care_Model_ID = FC_FC.Funding_Care_Model_ID
		Left outer join [dbo].FC_Account FC_A on FC_A.client_Contract_ID = FC_CC.client_Contract_ID

		Left outer join 
		(
			select
				FC_T.FC_Account_ID 'FC_Account_ID'
				,FC_T.FC_Transaction_Type_ID 'FC_Transaction_Type_ID'
				,FC_T.Activity_Date 'Visit_Date'
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
									FC_T.Actual_Amount
									end desc
								)'RN'
			from [dbo].FC_Transaction FC_T
			where 
				1=1
				and FC_T.FC_Transaction_Type_ID = 3
				and FC_T.Actual_Amount <> 0.0
				and FC_T.Source_Table = 'Actual_Service'
				and FC_T.Activity_Date between @StartDate and @EndDate

		)FC_T on FC_T.FC_Account_ID = FC_A.FC_Account_ID

	)J009 ON 
			J009.Client_ID = J001.Client_ID 
			and J009.Visit_Date = J001.Visit_Date 
			and J009.Visit_No = J001.Visit_No
			and J009.Service_Prov_Position_ID = J001.Service_Prov_Position_ID
			and J009.Provider_ID = J001.Provider_ID
	--*/
	where
		1=1
		and J006.Organisation_Name In (@Organisation)
--		and J001.Client_ID = 10020550
		and 1 = iif( J009.Client_ID is null, 1, @ChargeItemTest)
--		and J009.Client_ID is null
)t1
where 
	1=1
	and t1.RN = 1
	and t1.ContractState = 'Out'
	and t1.Activity_Start_Time between @StartDate and @EndDate

Group by
	t1.Organisation_Name
	,t1.Client_ID
	,t1.ServiceType 
	,t1.From_Date
	,t1.To_Date
	,t1.Activity_Start_Time
	,t1.TaskType 
	,t1.Provider_ID
	,t1.Funding_Prog_Code
	,t1.CAP_ID
	,t1.Est_Visit_Charge
	,t1.FundingProgram
	,t1.ContractState
	,t1.RN

order by
	t1.Organisation_Name
	,t1.Client_ID
	,t1.ServiceType 
	,t1.Activity_Start_Time
	,t1.ContractState
	,t1.RN