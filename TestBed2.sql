Declare @Client_ID_ AS INT
Set @Client_ID_ = 10019294


SELECT
	J001.[Client_ID]
	,J003.[Organisation_Name]
FROM
(
Select
CL.Client_ID
from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Client CL WITH(NOLOCK)
Inner Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Person P WITH(NOLOCK) on Cl.Client_ID = P.Person_ID
) J001

LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Service_Delivery] J002 ON J002.[Client_ID] = J001.[Client_ID]

INNER JOIN 
(
Select SD.Client_ID, O.Organisation_Name, SD.Service_Type_Code 
from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Service_Delivery SD
join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Period_of_Residency PR on PR.Person_ID = SD.Client_ID
join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Address A on A.Address_ID = PR.Address_ID
Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Service_Provision SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Organisation O on Sp.Centre_ID = O.Organisation_ID
Where PR.To_Date is null and PR.Display_Indicator  = 1
) J003 ON J003.[Client_ID] = J002.[Client_ID] AND J003.[Service_Type_Code] = J002.[Service_Type_Code]

WHERE
J001.[Client_ID]=@Client_ID_
GROUP BY
J001.[Client_ID]
,J003.[Organisation_Name]

