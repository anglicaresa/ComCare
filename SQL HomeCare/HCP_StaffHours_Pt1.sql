
use ComCareProd

Declare @Begin_Date as datetime
Declare @End_Date as datetime
Declare @OrganisationName as Varchar(60)
set @Begin_Date = '20161101 00:00:00.000'
set @End_Date = '20161115 00:00:00.000'
set @OrganisationName = 'Home Care Barossa Yorke Peninsula'
/*
------------------------------------------------------------------
*/


SELECT

J005.[Provider_ID]
--,LAG(J005.[Provider_ID]) Over (Order by	J004.[Organisation_Name], J005.[Provider_ID]) as 'prev_provID'
,J005.[Title]
,J005.[Last_Name]
,J005.[Preferred_Name]
,J001.[Activity_Date]
,J001.[Schedule_Duration]
,iif(J001.[Activity_Duration] is null, 0, J001.[Activity_Duration]) as 'Activity_Duration'
,J004.[Organisation_Name]

FROM [dbo].[WI_Activity] J001
INNER JOIN [dbo].[Client] J002 on J002.[Client_ID] = J001.[Client_ID]
LEFT OUTER JOIN [dbo].[Service_Delivery] J003 ON J003.[Client_ID] = J002.[Client_ID]

INNER JOIN 
(
	Select 
		SD.[Client_ID]
		,O.[Organisation_Name]
		,SD.[Service_Type_Code]
	from [dbo].[Service_Delivery] SD
		join [dbo].[Period_of_Residency] PR on PR.[Person_ID] = SD.[Client_ID]
		join [dbo].[Address] A on A.[Address_ID] = PR.[Address_ID]
		Join [dbo].[Service_Provision] SP on A.[Suburb_ID] = SP.[Suburb_ID] and SP.[Service_Type_Code] = SD.[Service_Type_Code]
		Join [dbo].[Organisation] O on Sp.[Centre_ID] = O.[Organisation_ID]
	Where PR.[To_Date] is null and PR.[Display_Indicator]  = 1
) J004 ON J004.[Client_ID] = J003.[Client_ID] AND J004.[Service_Type_Code] = J003.[Service_Type_Code]

INNER JOIN 
(
	Select
		Prov.[Provider_ID]
		,P.[Preferred_Name]
		,P.[Last_Name]
		,T.[Description] as 'Title'
	from [dbo].[Provider] Prov WITH(NOLOCK)
		Inner Join [dbo].[Person] P WITH(NOLOCK) on Prov.[Provider_ID] = P.[Person_ID]
		Inner Join [dbo].[Title] T on P.[Title_Code] = T.[Title_Code]
) J005 ON J005.[Provider_ID] = J001.[Provider_ID]

WHERE
1=1
 --AND J001.[Activity_Date] BETWEEN @Begin_Date AND @End_Date
 --and J004.[Organisation_Name] in (@OrganisationName)
 and J005.[Provider_ID] = 10012215

GROUP BY
J005.[Provider_ID]
,J005.[Title]
,J005.[Last_Name]
,J005.[Preferred_Name]
,J001.[Activity_Date]
,J001.[Schedule_Duration]
,iif(J001.[Activity_Duration] is null, 0, J001.[Activity_Duration])
,J004.[Organisation_Name]

ORDER BY
J005.[Provider_ID]
,J004.[Organisation_Name]