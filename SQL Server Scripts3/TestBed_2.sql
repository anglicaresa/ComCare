--/*
select
	J001.Client_ID
	,(Cast (cast(J001.Visit_Date as date) as Datetime) + Cast (Cast (J001.Visit_Time as Time) as Datetime)) as 'Schedule_Visit_Time'
	,(Cast (J001.Activity_Start_Time as Datetime))  as 'Actual_Visit_Time'
--	,J001.Visit_No
	,J001.Client_Not_Home
	,J001.Provider_ID
	,J001.Scheduled_Duration	
	,J001.Visit_Duration as 'Actual_Duration'
	,J004.[Description]
	,IIF (J002.Client_ID IS NULL, 0, 1) as 'Has_Charge_Item'
	,J002.Line_Description 'Charge_Item_Line_Description'
	,J002.Amount
	,IIF(J009.Organisation_Name = 'NDIA National Disability Insurance Agency', 'NDIS funded','Self Managed') as 'Funding_type'

	--*/
from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Actual_Service J001
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

	from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Actual_Service_Charge_Item] ACSI

)J002 ON J002.Client_ID = J001.Client_ID and J002.Visit_Date = J001.Visit_Date and J002.Visit_No = J001.Visit_No and J002.Service_Prov_Position_ID = J001.Service_Prov_Position_ID
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
Inner Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Task_Type] J004 on J004.Task_Type_Code = J001.Task_Type_Code

Inner JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Service_Delivery] J005 ON J001.[Client_ID] = J005.[Client_ID]

INNER JOIN 
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
					WHEN O.[Organisation_Name] = 'Disabilities Children' THEN '1'
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

left outer Join
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
--*/
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

Where 
	1=1
--	and J001.Client_ID = @Client_ID_
	and J006.[Organisation_Name] = 'Disabilities Children'
	and J006.RN < 2
	and J009.RN < 2
	and J001.Visit_Date between @StartDate and (cast (@EndDate as DateTime) + cast ('18991230 23:59:59.998' as DateTime))
	and J009.ContractBillingGroup <> 'DCSI'

Group by
	J001.Client_ID
	,(Cast (cast(J001.Visit_Date as date) as Datetime) + Cast (Cast (J001.Visit_Time as Time) as Datetime))
	,(Cast (J001.Activity_Start_Time as Datetime))
	,J001.Visit_No
	,J001.Client_Not_Home
	,J001.Provider_ID
	,J001.Scheduled_Duration	
	,J001.Visit_Duration
	,J004.[Description]	
	,IIF (J002.Client_ID IS NULL, 0, 1)
	,J002.Line_Description
	,J002.Amount
	,IIF(J009.Organisation_Name = 'NDIA National Disability Insurance Agency', 'NDIS funded','Self Managed')

order by
1,2