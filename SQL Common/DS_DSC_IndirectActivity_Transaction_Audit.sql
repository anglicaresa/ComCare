--[appsql-3\TRAIN].[ComCareTRAIN]
--[APPSQL-3\COMCAREPROD].[comcareprod]
/*
----------------------------------------------------------
select * from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Actual_Service
where client_id = 10070303

select * from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Actual_Service_Charge_Item]
where client_id = 10070303

select * from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Client_Contract_Billing]
select * from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Contract_Billing_Group]
select * from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Task_Type]


select * FROM [APPSQL-3\COMCAREPROD].[comcareprod].dbo.WI_Activity
where provider_ID = 10012270
and Client_ID IS NOT NULL
order by Schedule_Time

select Activity_Date,Activity_Start_Time ,WI_Record_ID FROM [APPSQL-3\COMCAREPROD].[comcareprod].dbo.WI_Activity
where provider_ID = 10012270
and Client_ID IS NOT NULL
order by Schedule_Time

select * FROM [APPSQL-3\COMCAREPROD].[comcareprod].dbo.Actual_Service
where Provider_ID = 10012270
order by Visit_Date


where client_id is not null and SPPID = 1174

Contract_Billing_Group_ID
--*/


Declare @Client_ID_ as INT
set @Client_ID_ = 10081884

DECLARE @StartDate AS DATETIME
DECLARE @EndDate AS DATETIME
SET @StartDate = '20161218 00:00:00.000'
SET @EndDate = '20170101 00:00:00.000'

PRINT @StartDate
PRINT @EndDate

declare @Organisation VarChar(64) = 'Disabilities Children'

Declare @ContractType Table (ContractType varchar(64))

Insert INTO @ContractType 
select --top 2
	Description
from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FC_Funder_Contract]
where 
	1=1
	AND ((Description like 'DC %' and @Organisation = 'Disabilities Children')OR (Description like 'DA %' and @Organisation = 'Disabilities Adult'))
	and Description <> 'DC Individualised Services'
	and Description <> 'DC Day Activities'
	and Description <> 'DC Overnight Respite'
--	and Description <> 'DC Case Coordination Mt Gambier'
	and Description <> 'DC OATS'
-----------------------------------------
-----------------------------------------
--/*
select
	J001.Client_ID
	,J001.WiA_Provider_ID as 'Provider_ID'
--	,J001.WiA_SPPID
--	,J001.AcS_SPPID
--	,J001.WiA_Schedule_Sequence_No as 'Schedule_Sequence_No'
	,(Cast (J001.WiA_Schedule_Time as Datetime)) as 'Schedule_Visit_Time_Wi'	
	,J001.WiA_Scheduled_Duration 'Scheduled_Duration'
	,(Cast (J001.AcS_Activity_Start_Time as Datetime))  as 'Actual_Visit_Time_Wi'
	,J001.AcS_Visit_Duration as 'Actual_Duration'
	,J001.WiA_Schedule_Task_Type as 'Task_Type_Wi'
	,J004.[Description] as 'task_Description'
	,J001.Client_Not_Home
	,IIF (J002.Client_ID IS NULL, 0, 1) as 'Has_Charge_Item'
	,IIF (J001.Client_Not_Home IS NULL, 1, 0) as 'In_WiA_Only'
	,J002.Line_Description 'Charge_Item_Line_Description'
	,J002.Amount
	,IIF(J009.Organisation_Name = 'NDIA National Disability Insurance Agency', 'NDIS funded','Self Managed') as 'Funding_Type'
	,J011.Description as contract_type
	--*/
FROM 
(
	Select
		IIF(Ac_S.Activity_Start_Time IS NULL, 'FALSE', 'TRUE') as 'In_Actual_Service'
		,Wi_A.SPPID as 'WiA_SPPID'
		,Ac_S.Service_Prov_Position_ID as 'AcS_SPPID'
		,Wi_A.Activity_Start_Time 'WiA_Activity_Start_Time'
		,Wi_A.Activity_End_Time as 'WiA_Activity_End_Time'
		,Wi_A.Client_ID as 'Client_ID'
		,Wi_A.Provider_ID as 'WiA_Provider_ID'
		,Wi_A.Schedule_Sequence_No as 'WiA_Schedule_Sequence_No'
		,Wi_A.Schedule_Task_Type as 'WiA_Schedule_Task_Type'
		,Convert (DateTime, Wi_A.Schedule_Time) as 'WiA_Schedule_Time'
		,Ac_S.Activity_Start_Time as 'AcS_Activity_Start_Time'
		,Wi_A.Schedule_Duration as 'WiA_Scheduled_Duration'
		,Wi_A.Activity_ID as 'WiA_Activity_ID'
		,Ac_S.Visit_Duration as 'AcS_Visit_Duration'
		,Ac_S.Client_Not_Home as 'Client_Not_Home'
		,Ac_S.Visit_Date as 'AcS_Visit_Date'
		,Ac_S.Visit_No as 'Visit_No'
		,Ac_S.Task_Type_Code as 'Task_Type_Code'
		,Wi_A.[CAP_ID] as 'CAP_ID'
	from [APPSQL-3\COMCAREPROD].[comcareprod].dbo.WI_Activity Wi_A
	Left Outer Join [APPSQL-3\COMCAREPROD].[comcareprod].dbo.Actual_Service Ac_S 
	ON 
		1=1
		and Wi_A.Client_ID = Ac_S.Client_ID 
		and Wi_A.SPPID = Ac_S.Service_Prov_Position_ID
		and (Wi_A.Schedule_Time = Ac_S.Activity_Start_Time or Wi_A.Activity_Start_Time = Ac_S.Activity_Start_Time)
	where
		1=1
		and Wi_A.Cancellation_Date is NULL
		and Wi_A.Client_ID IS NOT NULL
)J001
--*/

--charge Item test.
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

	from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Actual_Service_Charge_Item] ACSI

)J002 ON J002.Client_ID = J001.Client_ID and J002.Visit_Date = J001.AcS_Visit_Date and J002.Visit_No = J001.Visit_No and J002.Service_Prov_Position_ID = J001.AcS_SPPID
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
Left outer Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Task_Type] J004 on J004.Task_Type_Code = J001.WiA_Schedule_Task_Type--J001.Task_Type_Code

Left Outer Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Service_Delivery] J005 ON J001.[Client_ID] = J005.[Client_ID]

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
			) AS 'RN'
	from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Service_Delivery] SD
		join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Period_of_Residency] PR on PR.Person_ID = SD.Client_ID
		join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Address] A on A.Address_ID = PR.Address_ID
		Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Service_Provision] SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
		Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Organisation] O on Sp.Centre_ID = O.Organisation_ID
	Where PR.To_Date is null and PR.Display_Indicator  = 1
) J006 ON J006.[Client_ID] = J001.[Client_ID] AND J006.[Service_Type_Code] = J005.[Service_Type_Code]


-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
--/*

--Funding type
Left outer Join
(
	select
		--top 1
		CCB.[Client_ID] as 'Client_ID'
		,Org.[Organisation_Name] as 'Organisation_Name'
		,CBG.[Description] as 'ContractBillingGroup'
		,ROW_NUMBER ()
			over 
			(
				Partition by CCB.[Client_ID] Order by
					CASE
					WHEN Org.[Organisation_Name] = 'NDIA National Disability Insurance Agency' THEN '1'
					ELSE Org.[Organisation_Name] END ASC
			) AS 'RN'
	from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Client_Contract_Billing] CCB
		left outer join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Contract_Billing_Group] CBG on CBG.[Contract_Billing_Group_ID] = CCB.[Contract_Billing_Group_ID]
		left outer Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Client_Contract_Billed_To] CCBT on CCBT.[Client_CB_ID] = CCB.[Client_CB_ID]
		left outer Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Client_CB_Split] CCBS on CCBS.[Client_Contract_Billed_To_ID] = CCBT.[Client_Contract_Billed_To_ID]
		left outer Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Organisation] Org on CCBS.[Organisation_ID] = Org.[Organisation_ID]

)J009 on J009.[Client_ID] = J001.[Client_ID]

Left Outer Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FC_Contract_Area_Product] J010 ON J010.[CAP_ID] = J001.[CAP_ID]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FC_Funder_Contract] J011 ON J011.[Funder_Contract_ID] = J010.[Funder_Contract_ID]
--*/
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

Where 
	1=1
--	and J001.Client_ID = @Client_ID_
	and J006.[Organisation_Name] = @Organisation
	and J006.RN < 2
	and J009.RN < 2
	and J001.WiA_Schedule_Time between @StartDate and (DATEADD(s, 84599, @EndDate))
	and J009.ContractBillingGroup != 'DCSI'
	and J001.Client_ID IS NOT NULL

	AND J011.Description in (select * from @ContractType)
--	and J011.Description in (@ContractType)

Group by
	J001.Client_ID
	,J001.WiA_Provider_ID
--	,J001.WiA_SPPID
--	,J001.AcS_SPPID
--	,J001.WiA_Schedule_Sequence_No
	,(Cast (J001.WiA_Schedule_Time as Datetime))
	,J001.WiA_Scheduled_Duration
	,(Cast (J001.AcS_Activity_Start_Time as Datetime))
	,J001.AcS_Visit_Duration
	,J001.WiA_Schedule_Task_Type
	,J004.[Description]
	,J001.Client_Not_Home
	,IIF (J002.Client_ID IS NULL, 0, 1)
	,IIF (J001.Client_Not_Home IS NULL, 1, 0)
	,J002.Line_Description
	,J002.Amount
	,IIF(J009.Organisation_Name = 'NDIA National Disability Insurance Agency', 'NDIS funded','Self Managed')
	,J011.Description

order by
	J001.Client_ID
	,J001.WiA_Schedule_Time
	,J001.WiA_Provider_ID