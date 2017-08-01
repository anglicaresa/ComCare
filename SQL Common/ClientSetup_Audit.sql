declare @Org_name Varchar(128) = 'Disabilities Children'
/*
select * from [dbo].[Funding_Program]
select * from [dbo].[Service_Delivery]
select * from [dbo].[FC_Funder_Contract] 
select * from [dbo].[FC_Client_Contract]
select * from [dbo].[FB_Client_Contract_Billing]
select * from [dbo].[Organisation]
select * from [dbo].Person
*/
use ComCareProd

SELECT
J001.[Client_ID]
,J008.[Organisation_Name] as 'DeliveryCentre'
,J003.[Description] as 'ServDel_FundProg'
,J005.[Description] as 'CliCon_FundProg'
--,J005.[Funder_Contract_ID] as 'Funder_Contract_ID'
,J007.[Description] as 'BilCon_FundProg'
--,J007.[Funder_Contract_ID] as 'Funder_Contract_ID'
FROM
(
	Select     
		CL.Client_ID AS 'Client_ID'
		,P.Deceased_Date
		,P.Preferred_Name
		,P.Last_Name
	from dbo.Client CL
		Inner Join dbo.Person P on Cl.Client_ID = P.Person_ID
) J001

LEFT OUTER JOIN [dbo].[Service_Delivery] J002 ON J002.[Client_ID] = J001.[Client_ID]
LEFT OUTER JOIN [dbo].[Funding_Program] J003 ON J003.[Funding_Prog_Code] = J002.[Funding_Prog_Code]

LEFT OUTER JOIN [dbo].[FC_Client_Contract] J004 ON J004.[Client_ID] = J001.[Client_ID]
LEFT OUTER JOIN [dbo].[FC_Funder_Contract] J005 ON J005.[Funder_Contract_ID] = J004.[Funder_Contract_ID] 

LEFT OUTER JOIN [dbo].[FB_Client_Contract_Billing] J006 ON J006.[Client_ID] = J001.[Client_ID]
LEFT OUTER JOIN [dbo].[FC_Funder_Contract] J007 ON J007.[Funder_Contract_ID] = J006.[Funder_Contract_ID]-- and J007.[Funder_Contract_ID] = J004.[Funder_Contract_ID] 

INNER JOIN 
(
	Select 
		SD.Client_ID
		,O.Organisation_Name as 'Organisation_Name'
		,SD.Service_Type_Code  as 'Service_Type_Code'
	from [dbo].Service_Delivery SD
		join [dbo].Period_of_Residency PR on PR.Person_ID = SD.Client_ID
		join [dbo].[Address] A on A.Address_ID = PR.Address_ID
		Join [dbo].Service_Provision SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
		Join [dbo].Organisation O on Sp.Centre_ID = O.Organisation_ID
	Where PR.To_Date is null and PR.Display_Indicator  = 1
) J008 ON J008.[Client_ID] = J002.[Client_ID] AND J008.[Service_Type_Code] = J002.[Service_Type_Code]

WHERE
	1=1
	and J008.Organisation_Name in (@Org_name)
	AND J001.Deceased_Date IS NULL
	And J006.Billing_End_Date IS NULL
	and J004.end_Date_of_Claim IS NULL
	and J002.To_Date IS NULL
	--Debug
	and J001.Client_ID = 10069222

GROUP BY
J001.[Client_ID]
,J008.[Organisation_Name]
,J003.[Description]
,J005.[Description]
,J007.[Description]
ORDER BY
1,2,3