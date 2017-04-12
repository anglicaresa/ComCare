use ComCareProd

Declare @Client_ID_ AS INT
Set @Client_ID_ = 10019294
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------
SELECT
	J001.[Client_ID]
	,J003.[Organisation_Name]
FROM
(
	Select
		CL.Client_ID
	from [dbo].Client CL WITH(NOLOCK)
		Inner Join [dbo].Person P WITH(NOLOCK) on Cl.Client_ID = P.Person_ID
) J001

LEFT OUTER JOIN [dbo].[Service_Delivery] J002 ON J002.[Client_ID] = J001.[Client_ID]
INNER JOIN 
(
	Select 
		SD.Client_ID
		,O.Organisation_Name
		,SD.Service_Type_Code 
	from [dbo].Service_Delivery SD
		join [dbo].Period_of_Residency PR on PR.Person_ID = SD.Client_ID
		join [dbo].Address A on A.Address_ID = PR.Address_ID
		Join [dbo].Service_Provision SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
		Join [dbo].Organisation O on Sp.Centre_ID = O.Organisation_ID
	Where PR.To_Date is null and PR.Display_Indicator  = 1
) J003 ON J003.[Client_ID] = J002.[Client_ID] AND J003.[Service_Type_Code] = J002.[Service_Type_Code]

WHERE
J001.[Client_ID]=@Client_ID_
GROUP BY
J001.[Client_ID]
,J003.[Organisation_Name]

-----------------------------------------------------------------
-----------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--get Organisation_Name list, PROD
SELECT
J003.[Organisation_Name] as 'Organisation_Name'

FROM
(
	Select     
		CL.Client_ID
	from [dbo].Client CL WITH(NOLOCK)
	Inner Join [dbo].Person P WITH(NOLOCK) on Cl.Client_ID = P.Person_ID
) J001
LEFT OUTER JOIN [dbo].[Service_Delivery] J002 ON J002.[Client_ID] = J001.[Client_ID]

INNER JOIN 
(
	Select 
		SD.Client_ID
		,O.Organisation_Name
		,SD.Service_Type_Code 
	from [dbo].Service_Delivery SD
	join [dbo].Period_of_Residency PR on PR.Person_ID = SD.Client_ID
	join [dbo].Address A on A.Address_ID = PR.Address_ID
	Join [dbo].Service_Provision SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
	Join [dbo].Organisation O on Sp.Centre_ID = O.Organisation_ID
	--Where PR.To_Date is null and PR.Display_Indicator  = 1
) J003 ON J003.[Client_ID] = J002.[Client_ID] AND J003.[Service_Type_Code] = J002.[Service_Type_Code]
LEFT OUTER JOIN [dbo].[Service_Type] J004 ON J004.[Service_Type_Code] = J002.[Service_Type_Code]
WHERE
 1=1
GROUP BY
J003.[Organisation_Name]