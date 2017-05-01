
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
use ComCareProd

DECLARE @Start_Date AS DATETIME
DECLARE @End_Date AS DATETIME
DECLARE @OrgName AS Varchar(64)
SET @Start_Date = dateadd(day,-30,GETDATE())
SET @End_Date = GETDATE()

SET @OrgName = 'Home Care Extended North'

--SET @OrgName = 'Home Care East'
--SET @OrgName = 'Home Care North'
--SET @OrgName = 'Home Care South'
--SET @OrgName = 'Home Care West'
--SET @OrgName = 'Disabilities Children'


-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

SELECT
	IIF (J005.[Organisation_Name] = 'Home Care Barossa Yorke Peninsula', 'Home Care Extended North', J005.[Organisation_Name]) 'Organisation_Name'
	,J001.[Client_ID]
	,concat(J001.[Last_Name],', ',J001.[Preferred_Name]) 'Client_Name'
	,J006.[Description] 'Service_Type'
	,IIF(J002.To_Date is null,'Admission','Discharge')'Action'
	,convert(Datetime, J002.[From_Date]) 'From_Date'
	,convert(Datetime, J002.[To_Date]) 'To_Date'
	,J007.[Description] 'Service_Delivery_Outcome'
	,IIF
	(
		J003.Contact_Type = 'Service Advisor'
		,J008.[Person_ID]
		,Null
	)'Advisor_ID'
	,IIF
	(
		J003.Contact_Type = 'Service Advisor'
		,Concat(J008.Last_Name,', ',J008.Preferred_Name)
		,'Not On Record'
	) 'Service_Advisor_Name'

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

Left outer join
(
	select
		PC.Person_ID 'Person_ID'
		,PC.Contact_ID 'Contact_ID'
		,PCT.Description 'Contact_Type'
		,ROW_NUMBER()over
		(
			Partition by PC.Person_ID 
			order by 
				case 
					when PCT.Description = 'Service Advisor' then '1'
					else 'z'
				end
		)RN
	from [dbo].[Personal_Contact] PC 
	Inner Join [dbo].Personal_Contact_Type PCT ON PCT.Personal_Contact_Type_Code = PC.Personal_Contact_Type_Code

)J003 ON J003.Person_ID = J001.Client_ID

Left outer JOIN 
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
	AND (
			(cast(J002.From_Date as datetime) BETWEEN @Start_Date AND @End_Date) 
			or 
			(cast(J002.To_Date as datetime) BETWEEN @Start_Date AND @End_Date) 
		)
	and J003.RN = 1
	and IIF (J005.[Organisation_Name] = 'Home Care Barossa Yorke Peninsula', 'Home Care Extended North', J005.[Organisation_Name]) in (@OrgName)

Group by
	IIF (J005.[Organisation_Name] = 'Home Care Barossa Yorke Peninsula', 'Home Care Extended North', J005.[Organisation_Name])
	,J001.[Client_ID]
	,concat(J001.[Last_Name],', ',J001.[Preferred_Name])
	,J006.[Description]
	,convert(Datetime, J002.[From_Date])
	,convert(Datetime, J002.[To_Date])
	,J007.[Description]
	,IIF
	(
		J003.Contact_Type = 'Service Advisor'
		,J008.[Person_ID]
		,Null
	)
	,IIF
	(
		J003.Contact_Type = 'Service Advisor'
		,Concat(J008.Last_Name,', ',J008.Preferred_Name)
		,'Not On Record'
	)

ORDER BY
	IIF (J005.[Organisation_Name] = 'Home Care Barossa Yorke Peninsula', 'Home Care Extended North', J005.[Organisation_Name])
	,concat(J001.[Last_Name],', ',J001.[Preferred_Name])
	,J002.[From_Date]