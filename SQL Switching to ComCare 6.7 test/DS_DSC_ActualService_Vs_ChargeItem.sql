--[appsql-3\TRAIN].[ComCareTRAIN]
--[APPSQL-3\COMCAREPROD].[comcareprod]
/*
----------------------------------------------------------
select * from [dbo].Actual_Service
where client_id = 10070303

select * from [dbo].[Actual_Service_Charge_Item]
where client_id = 10070303

select * from [dbo].[FB_Client_Contract_Billing]

select * from [dbo].[FB_Contract_Billing_Group]
select * from [dbo].[Task_Type]

Contract_Billing_Group_ID

select * from [dbo].FC_Funder_Contract
select * from [dbo].FC_Funder_Contract_Billing
Funder_Contract_ID
select * from [dbo].FB_Contract_Billing
4
--*/

Use ComCareDev

declare @Organisation VarChar(64) = 'Disabilities Children'
Declare @Client_ID_ as INT
set @Client_ID_ = 10072693

DECLARE @StartDate AS DATETIME 
DECLARE @EndDate AS DATETIME
SET @StartDate = '20170215 00:00:00.000'
SET @EndDate = '20170315 00:00:00.000'

PRINT @StartDate
PRINT @EndDate

Declare @ContractType Table (ContractType varchar(64))
Insert INTO @ContractType 

select 'No Contract' Description where 1=1

union

select --top 2
	Description
from [dbo].[FC_Funder_Contract]
where 
	1=1
	AND ((Description like 'DC %' and @Organisation = 'Disabilities Children')
	OR (Description like 'DA %' and @Organisation = 'Disabilities Adult'))
--	and Description <> 'DC Individualised Services'
--	and Description <> 'DC Day Activities'
--	and Description <> 'DC Overnight Respite'
--	and Description <> 'DC Case Coordination Mt Gambier'
--	and Description <> 'DC OATS'
-----------------------------------------
-----------------------------------------
--/*
select
	J001.Client_ID
--	,(Cast (cast(J001.Visit_Date as date) as Datetime) + Cast (Cast (J001.Visit_Time as Time) as Datetime)) as 'Schedule_Visit_Time'
	,IIF(J033.WiA_Schedule_TimeKILL = 'true', null, Cast (J033.Schedule_Time as Datetime)) 'Schedule_Visit_Time'
--	,J033.Wi_Record_ID
--	,J033.WiA_Schedule_TimeKILL
--	,(Cast (J001.Activity_Start_Time as Datetime))  as 'Actual_Visit_Time'
	,(Cast (cast(J001.Visit_Date as date) as Datetime) + Cast (Cast (J001.Visit_Time as Time) as Datetime)) 'Actual_Visit_Time'
	,IIF (J011.Description is NULL,'No Contract',J011.Description) as contract_type
--	,J009.Contract_Billing_ID
--	,J001.Visit_No
	,J001.Client_Not_Home
	,J001.Provider_ID
	,J033.Scheduled_Duration	
	,J001.Visit_Duration as 'Actual_Duration'
	,J004.[Description]
	,IIF (J002.Client_ID IS NULL, 0, 1) as 'Has_Charge_Item'
	,J002.Line_Description 'Charge_Item_Line_Description'
	,J002.Amount
	,IIF(J009.Organisation_Name = 'NDIA National Disability Insurance Agency', 'NDIS funded',IIF(J009.Client_ID IS NULL,'No Contract Billing','Self Managed')) as 'Funding_type'
--	,J001.Service_Prov_Position_ID



	--*/
from [dbo].Actual_Service J001
--*/

Left outer Join
(
	select 
		ACSI.Client_ID	
		,ACSI.Visit_Date
		,ACSI.Visit_No
		,ACSI.Provider_ID
		,ACSI.Service_Prov_Position_ID
		,ACSI.Amount
		,ACSI.Line_Description

	from [dbo].[Actual_Service_Charge_Item] ACSI

)J002 ON 
			J002.Client_ID = J001.Client_ID 
			and J002.Visit_Date = J001.Visit_Date 
			and J002.Visit_No = J001.Visit_No 
			and J002.Service_Prov_Position_ID = J001.Service_Prov_Position_ID

left outer join
(
	select
		Wi_A.Client_ID
		,Wi_A.Wi_Record_ID 'Wi_Record_ID'
		,Wi_A.Activity_Date
		,Wi_A.SPPID
		,Wi_A.Schedule_Time 'Schedule_Time'
		,Wi_A.Schedule_Duration 'Scheduled_Duration'
		,Wi_A.ReSchedule 'ReSchedule'
		,Wi_A.Activity_Start_time 'Activity_Start_time'
		,iif(Wi_A.ReSchedule is not null and Wi_A.Activity_Start_time is not null, 'True', 'Flase') 'WiA_Schedule_TimeKILL'
		,AWT.Allocated_Task_ID 'Allocated_Task_ID'
		,Wi_A.Round_Allocation_ID 'Round_Allocation_ID'
	from [dbo].wi_activity Wi_A
	left outer join [dbo].activity_work_table AWT on AWT.Allocated_Task_ID = Wi_A.Round_Allocation_ID and AWT.activity_date = Wi_A.activity_date
)J033 ON 
		J033.Client_ID = J001.Client_ID 
		and J033.Activity_Date = J001.Visit_Date 
		and J033.SPPID = J001.Service_Prov_Position_ID 
		and (J001.Allocated_Task_ID = J033.Allocated_Task_ID or J001.Allocated_Task_ID = J033.Round_Allocation_ID)
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
left outer join [dbo].[Task_Type] J004 on J004.Task_Type_Code = J001.Task_Type_Code
left outer join [dbo].[Service_Delivery] J005 ON J001.[Client_ID] = J005.[Client_ID]

left outer join 
(
	Select 
		SD.[Client_ID]
		,O.[Organisation_Name]
		,SD.[Service_Type_Code]
--		,SD.[From_Date]
--		,SD.[To_Date]
		,ROW_NUMBER ()
			over 
			(
				Partition by SD.[Client_ID] Order by
					CASE
					WHEN O.[Organisation_Name] = @Organisation THEN '1'
					ELSE O.[Organisation_Name] END ASC
			) AS 'RN'
	from [dbo].[Service_Delivery] SD
		join [dbo].[Period_of_Residency] PR on PR.Person_ID = SD.Client_ID
		join [dbo].[Address] A on A.Address_ID = PR.Address_ID
		Join [dbo].[Service_Provision] SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
		Join [dbo].[Organisation] O on Sp.Centre_ID = O.Organisation_ID
	Where PR.To_Date is null and PR.Display_Indicator  = 1
) J006 ON J006.[Client_ID] = J001.[Client_ID] AND J006.[Service_Type_Code] = J005.[Service_Type_Code]


-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
--/*

left outer Join
(
	select
		CCB.[Client_ID] 'Client_ID'
		,Org.[Organisation_Name] 'Organisation_Name'
		,CBG.[Description] 'ContractBillingGroup'
		,CCB.Contract_Billing_ID 'Contract_Billing_ID'
		,ROW_NUMBER ()
			over 
			(
				Partition by CCB.[Client_ID] Order by
					CASE
					WHEN Org.[Organisation_Name] = 'NDIA National Disability Insurance Agency' THEN '1'
					ELSE Org.[Organisation_Name] END ASC
			) 'RN'
	from [dbo].[FB_Client_Contract_Billing] CCB
		left outer join [dbo].[FB_Contract_Billing_Group] CBG on CBG.[Contract_Billing_Group_ID] = CCB.[Contract_Billing_Group_ID]
		left outer Join [dbo].[FB_Client_Contract_Billed_To] CCBT on CCBT.[Client_CB_ID] = CCB.[Client_CB_ID]
		left outer Join [dbo].[FB_Client_CB_Split] CCBS on CCBS.[Client_Contract_Billed_To_ID] = CCBT.[Client_Contract_Billed_To_ID]
		left outer Join [dbo].[Organisation] Org on CCBS.[Organisation_ID] = Org.[Organisation_ID]

)J009 on J009.[Client_ID] = J001.[Client_ID]


left outer join [dbo].[FC_Contract_Area_Product] J010 ON J010.[CAP_ID] = J001.[CAP_ID]
left outer join [dbo].[FC_Funder_Contract] J011 ON J011.[Funder_Contract_ID] = J010.[Funder_Contract_ID]
--*/
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

Where 
	1=1
--	and J001.Client_ID = @Client_ID_
	and J006.[Organisation_Name] = @Organisation
	and (J006.RN < 2 or J006.RN is NULL)
	and (J009.RN < 2 or J009.rn is null)
	and cast (J001.Visit_Date as datetime) between cast (@StartDate as datetime) and (DATEADD(s, 84599, cast (@EndDate as datetime)))
	and (J009.ContractBillingGroup <> 'DCSI' or J009.ContractBillingGroup is null)
	AND (IIF (J011.Description is NULL,'No Contract',J011.Description) in (select * from @ContractType))
--	and (IIF (J011.Description is NULL,'No Contract',J011.Description) in (@ContractType))
--	and J009.Client_ID is null
--	and J033.Visit_No2 <> J033.Visit_No

Group by
	J001.Client_ID
--	,(Cast (cast(J001.Visit_Date as date) as Datetime) + Cast (Cast (J001.Visit_Time as Time) as Datetime))
	,IIF(J033.WiA_Schedule_TimeKILL = 'true', null, Cast (J033.Schedule_Time as Datetime))
--	,J033.Wi_Record_ID
--	,J033.WiA_Schedule_TimeKILL
--	,(Cast (J001.Activity_Start_Time as Datetime))
	,(Cast (cast(J001.Visit_Date as date) as Datetime) + Cast (Cast (J001.Visit_Time as Time) as Datetime))
	,IIF (J011.Description is NULL,'No Contract',J011.Description)
	,J009.Contract_Billing_ID
--	,J001.Visit_No
	,J001.Client_Not_Home
	,J001.Provider_ID
	,J033.Scheduled_Duration	
	,J001.Visit_Duration
	,J004.[Description]
	,IIF (J002.Client_ID IS NULL, 0, 1)
	,J002.Line_Description
	,J002.Amount
	,IIF(J009.Organisation_Name = 'NDIA National Disability Insurance Agency', 'NDIS funded',IIF(J009.Client_ID IS NULL,'No Contract Billing','Self Managed'))
	,J001.Service_Prov_Position_ID
	,J009.RN


order by

1,2,3

--10069723
/*
custom filter list
--------------------------------------------------------------------------------
*/

/*
Declare @BillContFilt table (filt varchar(64))
insert into @BillContFilt values ('NDIS funded'),('Self Managed'),('No Contract Billing')
select * from @BillContFilt
*/