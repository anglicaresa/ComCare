--[appsql-3\comcareprod].[comcareprod].[dbo].
--[appsql-3\TRAIN].[ComCareTRAIN].[dbo].
/*
Select * From [appsql-3\TRAIN].[ComCareTRAIN].[dbo].[Service_Delivery] 
*/
SELECT
	J002.[Client_ID]
	,J006.[Description]
	,J005.[Card_No]
	,J003.[From_Date]
	,J003.[To_Date]
	,J010.[Description]
	,J001.[Schedule_Duration]
	,J001.[Activity_Date]
	--,(CONVERT(datetime,Schedule_Time))
	,J012.[Rate]
FROM [appsql-3\TRAIN].[ComCareTRAIN].[dbo].[WI_Activity] J001
INNER JOIN 
(
	Select     
		CL.Client_ID
	from [appsql-3\TRAIN].[ComCareTRAIN].[dbo].[Client] CL WITH(NOLOCK)
		Inner Join [appsql-3\TRAIN].[ComCareTRAIN].[dbo].Person P WITH(NOLOCK) on Cl.Client_ID = P.Person_ID
) J002 ON J002.[Client_ID] = J001.[Client_ID]


LEFT OUTER JOIN [appsql-3\TRAIN].[ComCareTRAIN].[dbo].[Service_Delivery] J003 ON J003.[Client_ID] = J002.[Client_ID]

INNER JOIN 
(
	Select 
		SD.Client_ID
		,O.Organisation_Name
		,SD.Service_Type_Code 
	from [appsql-3\TRAIN].[ComCareTRAIN].[dbo].Service_Delivery SD
		join [appsql-3\TRAIN].[ComCareTRAIN].[dbo].Period_of_Residency PR on PR.Person_ID = SD.Client_ID
		join [appsql-3\TRAIN].[ComCareTRAIN].[dbo].Address A on A.Address_ID = PR.Address_ID
		Join [appsql-3\TRAIN].[ComCareTRAIN].[dbo].Service_Provision SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
		Join [appsql-3\TRAIN].[ComCareTRAIN].[dbo].Organisation O on Sp.Centre_ID = O.Organisation_ID
	Where PR.To_Date is null and PR.Display_Indicator  = 1
) 
J004 ON J004.[Client_ID] = J003.[Client_ID] AND J004.[Service_Type_Code] = J003.[Service_Type_Code]

LEFT OUTER JOIN [appsql-3\TRAIN].[ComCareTRAIN].[dbo].[Card_Holder] J005 ON J005.[Person_ID] = J002.[Client_ID]
LEFT OUTER JOIN [appsql-3\TRAIN].[ComCareTRAIN].[dbo].[Card_Type] J006 ON J006.[Card_Type_ID] = J005.[Card_Type_ID]
LEFT OUTER JOIN [appsql-3\TRAIN].[ComCareTRAIN].[dbo].[FC_Client_Contract] J007 ON J007.[Client_ID] = J002.[Client_ID]
Left Outer JOIN [appsql-3\TRAIN].[ComCareTRAIN].[dbo].[FB_Client_Contract_Billing] J008 ON J008.[Client_ID] = J007.[Client_ID] AND J008.[Funder_Contract_ID] = J007.[Funder_Contract_ID] AND J008.[Billing_Start_Date] between J007.[Effective_From_Date] and J007.[Effective_To_Date]
LEFT OUTER JOIN [appsql-3\TRAIN].[ComCareTRAIN].[dbo].[FB_Client_Contract_Bill_Item] J009 ON J009.[Client_CB_ID] = J008.[Client_CB_ID]
LEFT OUTER JOIN [appsql-3\TRAIN].[ComCareTRAIN].[dbo].[FB_Contract_Billing_Item] J010 ON J010.[Contract_Billing_Item_ID] = J009.[Contract_Billing_Item_ID]
LEFT OUTER JOIN [appsql-3\TRAIN].[ComCareTRAIN].[dbo].[FC_Account] J011 ON J011.[Client_Contract_ID] = J007.[Client_Contract_ID]
LEFT OUTER JOIN [appsql-3\TRAIN].[ComCareTRAIN].[dbo].[FC_Transaction] J012 ON J012.[FC_Account_ID] = J011.[FC_Account_ID]

WHERE
	1=1
	AND J004.[Organisation_Name]=N'Disabilities Children'
--	AND J001.[Activity_Date] BETWEEN '20160801 00:00:00.000' AND '20160814 23:59:59.998'
--	AND J001.Schedule_Time  BETWEEN '20160801 00:00:00.000' AND '20160814 23:59:59.998'
GROUP BY
	J002.[Client_ID]
	,J006.[Description]
	,J005.[Card_No]
	,J003.[From_Date]
	,J003.[To_Date]
	,J010.[Description]
	,J001.[Schedule_Duration]
	,J001.[Activity_Date]
	,J012.[Rate]

