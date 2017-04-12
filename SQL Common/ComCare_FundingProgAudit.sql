--[dbo].
/*
select * from [dbo].[Funding_Program]
select * from [dbo].[Service_Delivery]
select * from [dbo].[FC_Funder_Contract] 
select * from [dbo].[FC_Client_Contract]
select * from [dbo].[FB_Client_Contract_Billing]
select * from [dbo].[Organisation]
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
		CL.Client_ID AS 'Client_ID',
	    CONVERT(date,P.Deceased_Date) as 'Deceased_Date'
	from [dbo].Client CL WITH(NOLOCK)
		Inner Join [dbo].Person P WITH(NOLOCK) on Cl.Client_ID = P.Person_ID
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
AND
(
	(
	Case 
		when J008.[Organisation_Name]='Home Care West' then 'West'
		when J008.[Organisation_Name]='Home Care South' then 'South'
		when J008.[Organisation_Name]='Home Care North' then 'North'
		when J008.[Organisation_Name]='Home Care East' then 'East'
		when J008.[Organisation_Name]='Home Care Barossa Yorke Peninsula' then 'Barossa Yorke Peninsula'
		else 'nothing'
		end
	)
!=
	(
	Case 
		when J003.[Description]='HCP West' then 'West'
		when J003.[Description]='HCP South' then 'South'
		when J003.[Description]='HCP North' then 'North'
		when J003.[Description]='HCP East' then 'East'
		when J003.[Description]='HCP Barossa Yorke Peninsula' then 'Barossa Yorke Peninsula'
		else 'nothing'
		end
	)
)

AND J001.Deceased_Date IS NULL
And J006.Billing_End_Date IS NULL
and J004.end_Date_of_Claim IS NULL
and J002.To_Date IS NULL

--AND J002.[From_Date] > '20160401 00:00:00.000'
and J006.Billing_Start_Date > '20160101 00:00:00.000'
and J004.Start_Date_of_Claim > '20160101 00:00:00.000'
--and LEFT(J003.[Description],3) = 'HCP'

and LEFT(J007.[Description],4) != 'CHSP'
and LEFT(J005.[Description],4) != 'CHSP'
and LEFT(J003.[Description],4) != 'CHSP'

and
(
	(J003.[Description] != (LEFT(J005.[Description], LEN(J003.[Description]))) and LEFT(J005.[Description],4) != 'CHSP' and LEFT(J003.[Description],4) != 'CHSP' and LEFT(J007.[Description],4) != 'CHSP')

	OR (J003.[Description] != (LEFT(J007.[Description], LEN(J003.[Description]))) and LEFT(J005.[Description],4) != 'CHSP' and LEFT(J003.[Description],4) != 'CHSP' and LEFT(J007.[Description],4) != 'CHSP')

	OR (J005.[Description] != (LEFT(J007.[Description], LEN(J005.[Description]))) and LEFT(J005.[Description],4) != 'CHSP' and LEFT(J003.[Description],4) != 'CHSP' and LEFT(J007.[Description],4) != 'CHSP')
	
)

or

-------------------------------------------------------------
		(
			IIF
			(
				J003.[Description] = 'HCP Barossa Yorke Peninsula' and J007.[Description] = 'Northern Extended Aged Care at Home'
				,'Northern Extended Aged '
				,IIF
				(
					((J003.[Description] = 'HCP East') and (J005.[Description] = 'Central Eastern Care at Home'))
					,'Cent'
					,IIF
					(
					1=1
					--and LEFT(J007.[Description],4) != 'CHSP'
					--and LEFT(J005.[Description],4) != 'CHSP'
					--and LEFT(J003.[Description],4) != 'CHSP'
						,Right
						( 
							J003.[Description]
							,(Len(J003.[Description])-4) 
						)
						,'blah' 
					)
				)
			)
			!= 
			iif
			(
				1=1
				--and LEFT(J007.[Description],4) != 'CHSP'
				--and LEFT(J005.[Description],4) != 'CHSP'
				--and LEFT(J003.[Description],4) != 'CHSP'
				,LEFT
				(
					J007.[Description]
					,( Len(J003.[Description])-4 )
				)
				,'halb'
			)
		)
---------------------------------------------------------------


AND J001.[Client_ID] = 10020999

GROUP BY
J001.[Client_ID]
,J008.[Organisation_Name]
,J003.[Description]
,J005.[Description]
,J007.[Description]
ORDER BY
1,2,3
