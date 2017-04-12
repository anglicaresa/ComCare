
SELECT
J003.[Organisation_Name] as 'Organisation_Name'

FROM
(
	Select     
		CL.Client_ID
	from [appsql-3\comcareprod].[comcareprod].[dbo].Client CL WITH(NOLOCK)
	Inner Join [appsql-3\comcareprod].[comcareprod].[dbo].Person P WITH(NOLOCK) on Cl.Client_ID = P.Person_ID
) J001
LEFT OUTER JOIN [appsql-3\comcareprod].[comcareprod].[dbo].[Service_Delivery] J002 ON J002.[Client_ID] = J001.[Client_ID]

INNER JOIN 
(
	Select 
		SD.Client_ID
		,O.Organisation_Name
		,SD.Service_Type_Code 
	from [appsql-3\comcareprod].[comcareprod].[dbo].Service_Delivery SD
	join [appsql-3\comcareprod].[comcareprod].[dbo].Period_of_Residency PR on PR.Person_ID = SD.Client_ID
	join [appsql-3\comcareprod].[comcareprod].[dbo].Address A on A.Address_ID = PR.Address_ID
	Join [appsql-3\comcareprod].[comcareprod].[dbo].Service_Provision SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
	Join [appsql-3\comcareprod].[comcareprod].[dbo].Organisation O on Sp.Centre_ID = O.Organisation_ID
	--Where PR.To_Date is null and PR.Display_Indicator  = 1
) J003 ON J003.[Client_ID] = J002.[Client_ID] AND J003.[Service_Type_Code] = J002.[Service_Type_Code]
LEFT OUTER JOIN [appsql-3\comcareprod].[comcareprod].[dbo].[Service_Type] J004 ON J004.[Service_Type_Code] = J002.[Service_Type_Code]
WHERE
 1=1
GROUP BY
J003.[Organisation_Name]
