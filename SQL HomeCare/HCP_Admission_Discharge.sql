
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
use ComCareProd

DECLARE @Start_Date AS DATETIME
DECLARE @End_Date AS DATETIME
DECLARE @OrgName AS Varchar(64)
SET @Start_Date = dateadd(day,datediff(day,14,GETDATE()),0)
SET @End_Date = dateadd(day,datediff(day,0,GETDATE()),0)
SET @OrgName = 'Home Care Barossa Yorke Peninsula'
PRINT @Start_Date
PRINT @End_Date

-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

SELECT
	IIF (J005.[Organisation_Name] = 'Home Care Barossa Yorke Peninsula', 'Home Care Extended North', J005.[Organisation_Name]) as 'Organisation_Name'
	,J001.[Client_ID]
	,J001.[Last_Name]
	,J001.[Preferred_Name]
	,J006.[Description] as 'Service_Type'
	,convert(Datetime, J002.[From_Date])as 'From_Date'
	,convert(Datetime, J002.[To_Date]) as 'To_Date'
	,J007.[Description] as 'Service_Delivery_Outcome'
	,J008.[Person_ID]
	,J008.[Preferred_Name]
	,J008.[Last_Name]

FROM
(
	Select     
		CL.Client_ID
		,P.Last_Name
		,P.Preferred_Name
		,T.Description as 'Title'
	from [dbo].Client CL WITH(NOLOCK)
		Inner Join [dbo].Person P WITH(NOLOCK) on Cl.Client_ID = P.Person_ID
		Inner Join [dbo].Title T on P.Title_Code = T.Title_Code
) J001

LEFT OUTER JOIN [dbo].[Service_Delivery] J002 ON J002.[Client_ID] = J001.[Client_ID]
LEFT OUTER JOIN [dbo].[Personal_Contact] J003 ON J003.[Person_ID] = J001.[Client_ID]
LEFT OUTER JOIN [dbo].[Personal_Contact_Type] J004 ON J004.[Personal_Contact_Type_Code] = J003.[Personal_Contact_Type_Code]

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
	Where
		PR.To_Date is null and PR.Display_Indicator  = 1
) J005 ON J005.[Client_ID] = J002.[Client_ID] AND J005.[Service_Type_Code] = J002.[Service_Type_Code]

LEFT OUTER JOIN [dbo].[Service_Type] J006 ON J006.[Service_Type_Code] = J002.[Service_Type_Code]
LEFT OUTER JOIN [dbo].[Service_Delivery_Outcome] J007 ON J007.[Serv_Del_Outcome_Code] = J002.[Serv_Del_Outcome_Code]

INNER JOIN [dbo].Person J008 ON J008.[Person_ID] = J003.[Contact_ID]

WHERE
	1=1
	AND J002.[From_Date] BETWEEN @Start_Date AND @End_Date
	AND J004.[Description]= N'Service Advisor'
	AND J005.[Organisation_Name] in (@OrgName)

ORDER BY
	J005.[Organisation_Name]
	,J008.[Last_Name]
	,J008.[Preferred_Name]
	,J008.[Person_ID]
	,J001.[Last_Name]
	,J001.[Preferred_Name]
	,J001.[Client_ID]
	,J002.[From_Date]