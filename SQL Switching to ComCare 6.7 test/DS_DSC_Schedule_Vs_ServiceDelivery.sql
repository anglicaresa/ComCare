--WI_Activity and the Activity_Work_Table

/*
select * from [dbo].WI_Activity
--where schedule_time is null-- and activity_Start_time is null
where Activity_ID = 1033221
select * from [dbo].Activity_work_Table
where provider_id = 10069512 and Service_Prov_Position_ID = 1320 --and Activity_Date = '2017-02-03 00:00:00.000' and Client_ID = 10077684


select * from [dbo].Wi_Activity_Event_Type

select 'not' where 1=1
*/
use ComCareDev

Declare @Client_ID_ as INT = 10077684
DECLARE @StartDate AS DATETIME
DECLARE @EndDate AS DATETIME
SET @StartDate = '20170101 00:00:00.000'
SET @EndDate = '20170314 00:00:00.000'
Declare @PyRl_Switch as INT = 1
Declare @Vis as INT = 2

declare @Organisation VarChar(64) = 'Disabilities Children'

Declare @ContractType Table (ContractType varchar(64))
Insert INTO @ContractType
select 'No Contract' where 1=1
 union
select 
	Description
from [dbo].[FC_Funder_Contract]
where 
	1=1
	AND ((Description like 'DC %' and @Organisation = 'Disabilities Children') OR (Description like 'DA %' and @Organisation = 'Disabilities Adult'))

--select * from @ContractType
-----------------------------------------
-----------------------------------------

Declare @Hide_Awt_Ent as Int = IIF(@Vis = 0, 0, 1)
Declare @Hide_NoAwt_Ent as int = IIF(@Vis = 1, 0, 1)

select
	J001.Client_ID
	,(J013.Preferred_Name + ' '+ J013.Last_Name) 'Client_Name'
	,J001.Provider_ID 'Provider_ID'
	,(J012.Preferred_Name + ' '+ J012.Last_Name) 'Provider_Name'
	,J001.In_Activity_work_Table
--	,J001.RN
	,(Cast (J001.WiA_Schedule_Time as Datetime)) 'Schedule_Visit_Time_Wi'	
	,J001.WiA_Scheduled_Duration 'Scheduled_Duration'
	,(Cast (J001.Awt_Activity_Start_Time as Datetime)) 'Awt_Activity_Start_Time'
	,J001.WiA_Schedule_Task_Type 'Task_Type_Wi'
	,J001.AwT_Actual_Service_Visit_No
	,J001.WiA_Activity_ID
	,J001.Awt_Activity_No
	,J004.[Description] 'task_Description'
	,IIF(J009.Organisation_Name = 'NDIA National Disability Insurance Agency', 'NDIS funded',IIF(J009.Client_ID IS NULL,'No Contract Billing','Self Managed')) 'Funding_Type'
	,IIF (J011.Description is NULL,'No Contract',J011.Description) 'contract_type'
--	,J011.[Funder_Contract_ID]
--	,J010.[CAP_ID]
--	,J001.[CAP_ID]
	,(Cast(J001.AwT_Date_Extract_for_Payroll as DateTime)) 'AwT_Date_Extract_for_Payroll'

FROM 
(
	Select
		IIF(Awt.Activity_Start_Time IS NULL, 'FALSE', 'TRUE') 'In_Activity_work_Table'
		,Wi_A.SPPID 'WiA_SPPID'
		,Awt.Service_Prov_Position_ID 'AcS_SPPID'
		,Wi_A.Activity_Start_Time 'WiA_Activity_Start_Time'
		,Wi_A.Activity_End_Time 'WiA_Activity_End_Time'
		,Wi_A.Client_ID 'Client_ID'
		,Wi_A.Provider_ID 'Provider_ID'
		,Wi_A.Schedule_Task_Type 'WiA_Schedule_Task_Type'
		,Convert (DateTime, Wi_A.Schedule_Time) 'WiA_Schedule_Time'
		,Awt.Activity_Start_Time 'Awt_Activity_Start_Time'
		,Awt.Actual_Service_Visit_No 'AwT_Actual_Service_Visit_No'
		,Wi_A.Schedule_Duration 'WiA_Scheduled_Duration'
		,Wi_A.Activity_ID 'WiA_Activity_ID'
		,Awt.Activity_Date 'AWT_Activity_Date'
		,Awt.Task_Type_Code 'Task_Type_Code'
		,Wi_A.[CAP_ID] 'CAP_ID'
		,Awt.Date_Extract_for_Payroll 'AwT_Date_Extract_for_Payroll'
		,Awt.Activity_No 'Awt_Activity_No'
		,Row_Number()Over(Partition by Wi_A.Activity_ID Order BY Awt.Task_Type_Code) 'RN'
	from dbo.WI_Activity Wi_A
	Left Outer Join dbo.Activity_work_Table Awt 
	ON 
		1=1
		and Wi_A.Client_ID = Awt.Client_ID 
		and Wi_A.SPPID = Awt.Service_Prov_Position_ID
		and Wi_A.Activity_Date = Awt.Activity_Date
		and Wi_A.Provider_ID = Awt.Provider_ID
		and Wi_A.Round_Allocation_ID = Awt.Allocated_Task_ID
	where
		1=1
		and Wi_A.Cancellation_Date is NULL
		and Wi_A.Client_ID IS NOT NULL
)J001

Left outer Join [dbo].[Task_Type] J004 on J004.Task_Type_Code = J001.WiA_Schedule_Task_Type

--get Organisation
Left Outer Join [dbo].[Service_Delivery] J005 ON J001.[Client_ID] = J005.[Client_ID]
Left outer JOIN 
(
	Select 
		SD.[Client_ID]
		,O.[Organisation_Name]
		,SD.[Service_Type_Code]
		,ROW_NUMBER ()
			over 
			(
				Partition by SD.[Client_ID] Order by
					CASE
					WHEN O.[Organisation_Name] = @Organisation THEN '1'
					ELSE O.[Organisation_Name] END ASC
			) 'RN'
	from [dbo].[Service_Delivery] SD
		join [dbo].[Period_of_Residency] PR on PR.Person_ID = SD.Client_ID
		join [dbo].[Address] A on A.Address_ID = PR.Address_ID
		Join [dbo].[Service_Provision] SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
		Join [dbo].[Organisation] O on Sp.Centre_ID = O.Organisation_ID
	Where PR.To_Date is null and PR.Display_Indicator  = 1
) J006 ON J006.[Client_ID] = J001.[Client_ID] AND J006.[Service_Type_Code] = J005.[Service_Type_Code]

--Get Funding type
Left outer Join
(
	select
		CCB.[Client_ID] 'Client_ID'
		,Org.[Organisation_Name] 'Organisation_Name'
		,CBG.[Description] 'ContractBillingGroup'
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

Left Outer Join [dbo].[FC_Contract_Area_Product] J010 ON J010.[CAP_ID] = J001.[CAP_ID]
LEFT OUTER JOIN [dbo].[FC_Funder_Contract] J011 ON J011.[Funder_Contract_ID] = J010.[Funder_Contract_ID]

Inner Join [dbo].Person J012 ON J012.Person_ID = J001.Provider_ID
Inner Join [dbo].Person J013 ON J013.Person_ID = J001.Client_ID
--select top 1 * from [dbo].Person
Where 
	1=1
	and J001.Client_ID Is Not Null
	and J006.[Organisation_Name] = @Organisation 
	and (J006.RN < 2 or J006.RN is null)
	and (J009.RN < 2 or J009.RN is null)
	and J001.WiA_Schedule_Time between @StartDate and (DATEADD(s, 84599, @EndDate))
	and (J009.ContractBillingGroup <> 'DCSI' or J009.ContractBillingGroup is null)
--	/*
	and 1 = IIF
			(
				J001.AwT_Date_Extract_for_Payroll IS NOT NULL
				,@PyRl_Switch
				,1
			)

	and 1 = IIF
			(
				In_Activity_work_Table = 'True'
				,@Hide_Awt_Ent
				,@Hide_NoAwt_Ent
			)
--	*/
	AND (IIF (J011.Description is NULL,'No Contract',J011.Description) in (select * from @ContractType))
--	and (IIF (J011.Description is NULL,'No Contract',J011.Description) in (@ContractType))
--	and J009.Client_ID is null
--/*
Group by
	J001.Client_ID
	,(J013.Preferred_Name + ' '+ J013.Last_Name)
	,J001.Provider_ID
	,(J012.Preferred_Name + ' '+ J012.Last_Name)
	,J001.In_Activity_work_Table
	,(Cast (J001.WiA_Schedule_Time as Datetime))
	,J001.WiA_Scheduled_Duration
	,(Cast (J001.Awt_Activity_Start_Time as Datetime))
	,J001.WiA_Schedule_Task_Type
	,J001.AwT_Actual_Service_Visit_No
	,J001.WiA_Activity_ID
	,J001.Awt_Activity_No
	,J004.[Description]
	,IIF(J009.Organisation_Name = 'NDIA National Disability Insurance Agency', 'NDIS funded',IIF(J009.Client_ID IS NULL,'No Contract Billing','Self Managed'))
	,IIF (J011.Description is NULL,'No Contract',J011.Description)
--	,J011.[Funder_Contract_ID]
--	,J010.[CAP_ID]
--	,J001.[CAP_ID]
	,(Cast(J001.AwT_Date_Extract_for_Payroll as DateTime))
--*/
order by
	J001.Client_ID
	,J001.WiA_Schedule_Time
	,J001.Provider_ID

