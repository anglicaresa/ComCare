/*


select * from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[WI_Activity] --Activity_ID, SPPID
where 
Client_ID IS NOT NULL
and Client_ID = 10073000
and [Activity_Date] = '20161215 00:00:00.000'
--and Activity_start_time is null
order by Activity_Date

select * from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].activity_work_table
where
1=1

--and Client_ID = 10073000
and [Activity_Date] = '20161215 00:00:00.000'
and Activity_Duration is not null
and Schedule_Time is null

order by Activity_Date


--*/

--/*

Declare @Begin_Date as datetime
Declare @End_Date as datetime
Declare @Client_ID as Int
Declare @OrgName as VarChar(64)
set @Begin_Date = '20161205 00:00:00.000'
set @End_Date = '20161215 23:59:59.998'
--set @Client_ID = 10072849
--set @Client_ID = 10071413
--set @Client_ID = 10073000
set @Client_ID = 10071677
set @OrgName = 'Disabilities Children'

SELECT
	J002.[Client_ID]
	,J002.[Title]
	,J002.[Preferred_Name]
	,J002.[Last_Name]
	,J001.[Activity_Date]
--	,J001.[Schedule_Time]
--	,J013.[Schedule_Time]
	,J008.[Description]
	,format(J001.[Schedule_Duration]/60,'0.#0') as 'Schedule_Duration'
--	,J013.[Activity_Duration]
--	,J013.[InSchedule]
	,J010.[Description] as 'UOM'
	,J009.[Standard_Rate]
	,J009.[Surcharge_Saturday]
	,J009.[Surcharge_Sunday]
	,J009.[Surcharge_Public_Holiday]
	,J009.[Surcharge_Wkday_After_Hr]
	------------------------------------------------------------------
	/*
	,J001.[Schedule_Task_Type]
	,J006.[task_type_code]
	,J007.[Product_Mapping_ID]
	,J008.[Contract_Billing_Item_ID]
	*/
	------------------------------------------------------------------
	
FROM [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[WI_Activity] J001
INNER JOIN 
(
	Select     
		CL.Client_ID
	    ,P.Last_Name
	    ,P.Given_Names
	    ,P.Preferred_Name
	    ,CONVERT(datetime,P.Deceased_Date) [Deceased_Date]
	    ,T.Description as 'Title'
		,CB.Contract_Billing_ID
		,CBI.Contract_Billing_Item_ID
	from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Client CL WITH(NOLOCK)
		Inner Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Person P WITH(NOLOCK) on Cl.Client_ID = P.Person_ID
		Inner Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Title T on P.Title_Code = T.Title_Code
		left outer join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].FB_Client_Contract_Billing CB on CB.[Client_ID] = CL.[Client_ID]
		left outer join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].FB_Client_Contract_Bill_Item CBI on CBI.[Client_CB_ID] = CB.[Client_CB_ID]
) J002 ON J002.[Client_ID] = J001.[Client_ID]

LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FC_Product_Mapping] J006 ON J006.[task_type_code] = J001.[Schedule_Task_Type]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Contract_Billing_Item_UOM] J007 ON J007.[Product_Mapping_ID] = J006.[Product_Mapping_ID]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Contract_Billing_Item] J008 ON J008.[Contract_Billing_Item_ID] = J007.[Contract_Billing_Item_ID]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Contract_Billing_Rate] J009 ON J009.[Contract_Billing_Item_ID] = J007.[Contract_Billing_Item_ID]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Unit_of_Measure] J010 ON J010.[UOM_Code] = J009.[UOM_Code]

--Organisation filtering Primary.
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Service_Delivery] J011 WITH(NOLOCK) ON J011.[Client_ID] = J001.[Client_ID]

INNER JOIN 
(
	Select 
		SD.Client_ID
		,O.Organisation_Name as 'Organisation_Name'
		,SD.Service_Type_Code 
	from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Service_Delivery SD WITH(NOLOCK)
		join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Period_of_Residency PR WITH(NOLOCK) on PR.Person_ID = SD.Client_ID
		join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Address A on A.Address_ID = PR.Address_ID
		Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Service_Provision SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
		Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Organisation O on Sp.Centre_ID = O.Organisation_ID
	Where PR.To_Date is null and PR.Display_Indicator  = 1
) J012 ON J012.[Client_ID] = J011.[Client_ID] AND J012.[Service_Type_Code] = J011.[Service_Type_Code]
/*
Left outer join 
(
	select
		awt.[Client_ID] as 'Client_ID'
		,awt.[Activity_Duration] as 'Activity_Duration'
		,awt.[Activity_Date] as  'Activity_Date'
--		,awt.[Schedule_Time] as'Schedule_Time'
		,iif((awt.[Schedule_Time] is null),awt.Activity_Start_Time,awt.[Schedule_Time]) as 'Schedule_Time'
	from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[activity_work_table] awt WITH(NOLOCK)
	where
	1=1
	and awt.Activity_Duration is not null
) J013 on J013.[Client_ID] = J001.[Client_ID] and J001.[Schedule_Time] = J013.[Schedule_Time]
--) J013 on J013.[Client_ID] = J001.[Client_ID] and J013.[Schedule_Time] is null
*/
WHERE
	1 = 1
	and J001.[Activity_Date] BETWEEN @Begin_Date AND @End_Date
	and J012.[Organisation_Name] in (@OrgName)
	and J002.[Client_ID] in (@Client_ID)
	and J008.[Description] <> 'Montrose'
	and J001.Cancellation_Date is null
	and J002.Contract_Billing_Item_ID=J008.Contract_Billing_Item_ID

GROUP BY
	J002.[Client_ID]
	,J002.[Title]
	,J002.[Preferred_Name]
	,J002.[Last_Name]
	,J001.[Activity_Date]
--	,J001.[Schedule_Time]
--	,J013.[Schedule_Time]
	,J008.[Description]
	,J001.[Schedule_Duration]
--	,J013.[Activity_Duration]
--	,J013.[InSchedule]
	,J010.[Description]
	,J009.[Standard_Rate]
	,J009.[Surcharge_Saturday]
	,J009.[Surcharge_Sunday]
	,J009.[Surcharge_Public_Holiday]
	,J009.[Surcharge_Wkday_After_Hr]
	-------------------------------------------------------
	/*
	,J001.[Schedule_Task_Type]
	,J006.[task_type_code]
	,J007.[Product_Mapping_ID]
	,J008.[Contract_Billing_Item_ID]
	*/
	-------------------------------------------------------

order by
J002.[Client_ID]
,J001.[Activity_Date]

--*/