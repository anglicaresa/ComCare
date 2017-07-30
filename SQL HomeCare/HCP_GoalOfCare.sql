Declare @OrgName VarChar(128) = 'Home Care East'


SELECT
	J006.Organisation_Name
	,J001.Title
	,J001.Last_Name
	,J001.Given_Names
	,J001.Client_ID
	,J004.Description
	,J003.GOC_Defined_Date
	,J003.Outcome_Date
FROM
(
	Select Distinct
		SD.Client_ID
		,O.Organisation_Name
		--,SD.Service_Type_Code 
	from Service_Delivery SD
	join Period_of_Residency PR on PR.Person_ID = SD.Client_ID
	join Address A on A.Address_ID = PR.Address_ID
	Join Service_Provision SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
	Join Organisation O on Sp.Centre_ID = O.Organisation_ID
	Where 
		PR.To_Date is null 
		and PR.Display_Indicator  = 1
		and O.Organisation_Name in (@OrgName)
)J006
Inner Join
(
	Select     
		CL.Client_ID
		,P.Last_Name
		,P.Given_Names
		,P.Preferred_Name
		,T.Description 'Title'
	from Client CL
	Inner Join Person P on Cl.Client_ID = P.Person_ID
	Inner Join Title T on P.Title_Code = T.Title_Code
	where
		P.Deceased_Date is null
) J001 on J001.Client_ID = J006.Client_ID

LEFT OUTER JOIN dbo.FC_Client_Contract J002 ON J002.Client_ID = J001.Client_ID
LEFT OUTER JOIN dbo.FC_Client_Goal_of_Care J003 ON J003.Client_Contract_ID = J002.Client_Contract_ID
LEFT OUTER JOIN dbo.FC_Goal_of_Care_Type J004 ON J004.GOC_Type_ID = J003.GOC_Type_ID
LEFT OUTER JOIN dbo.Service_Delivery J005 ON J005.Client_ID = J001.Client_ID

WHERE
	1=1
	AND J004.Description IS not NULL 

GROUP BY
J006.Organisation_Name
,J001.Title
,J001.Last_Name
,J001.Given_Names
,J001.Client_ID
,J004.Description
,J003.GOC_Defined_Date
,J003.Outcome_Date
ORDER BY
1,2,3,4

