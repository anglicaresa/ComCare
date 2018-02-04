
/*
select * from dbo.FC_Client_Contract
*/
--select * from dbo.FC_Funder_Contract Funder_Contract_ID
Declare @OrgName VarChar(128) = 'Home Care East'
Declare @Filt_Funder int = 2

select * from
(
	SELECT Distinct
		J006.Organisation_Name
		,J001.Title
		,J001.Last_Name
		,J001.Given_Names
		,J001.Client_ID
		,J003.Objective
		,J003.GOC_Defined_Date
		,J007.Description 'Status'
		,iif(J008.Description like 'CHSP %','yes','no') 'CHSP'
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
	Left outer join dbo.FC_Goal_Of_Care_Status J007 on J007.GOC_Status_ID = J003.GOC_Status_ID
	Left outer join dbo.FC_Funder_Contract J008 on J008.Funder_Contract_ID = J002.Funder_Contract_ID
	WHERE
		1=1
		AND J004.Description IS not NULL 
)t1
	Where
	1 = Case
		when @Filt_Funder = 0  then 1
		when @Filt_Funder = 1 and t1.CHSP = 'no' then 1
		when @Filt_Funder = 2 and t1.CHSP = 'yes' then 1
		else 0
		end
ORDER BY
1,3,4,5

------------------------------------------------------------------------------------------------------------------------------
--Goal of care INDIVIDUAL
declare @Client_ID int = 10015595


SELECT Distinct
	J001.Title
	,J001.Last_Name
	,J001.Given_Names
	,J001.Client_ID
	,J004.Description 'Type'
	,J003.GOC_Defined_Date
	,J003.Outcome_Date
	,J007.Description 'Status'
	,J003.Objective
	,J003.How_This_Will_Be_Achieved
	,J003.How_Was_It_Achieved
	,J003.Outcome_Details

FROM
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
		CL.Client_ID = @Client_ID

) J001

LEFT OUTER JOIN dbo.FC_Client_Contract J002 ON J002.Client_ID = J001.Client_ID
LEFT OUTER JOIN dbo.FC_Client_Goal_of_Care J003 ON J003.Client_Contract_ID = J002.Client_Contract_ID
LEFT OUTER JOIN dbo.FC_Goal_of_Care_Type J004 ON J004.GOC_Type_ID = J003.GOC_Type_ID
LEFT OUTER JOIN dbo.Service_Delivery J005 ON J005.Client_ID = J001.Client_ID
Left outer join dbo.FC_Goal_Of_Care_Status J007 on J007.GOC_Status_ID = J003.GOC_Status_ID
--Left outer join dbo.FC_Funder_Contract J008 on J008.Funder_Contract_ID = J002.Funder_Contract_ID
WHERE
	1=1
	AND J004.Description IS not NULL 


ORDER BY
1,2,3,4