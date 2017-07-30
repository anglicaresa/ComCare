Declare @OrgName varchar(128) = 'Home Care Barossa Yorke Peninsula'

--select * from dbo.Person_Communication_Point where person_id = 10012136

SELECT
	J001.Client_ID
	,J004.Phone
	,J005.Person_ID 'ServAdv_ProvID'
	,J005.Preferred_Name 'ServAdv_Preferred_Name'
	,J005.Last_Name 'ServAdv_Last_Name'
--	,J006.Communication_Point_Number
--	/*
	,case J007.Communication_Default_Ind 
		when 0 then 'No' 
		when 1 then 'Yes' 
		else null 
		end 'Communication_Default_Ind'
--		*/
	,J009.Organisation_Name
	,J001.Title
	,J001.Last_Name
	,J001.Preferred_Name
	,J004.Building_name
	,J004.Location
	,J004.dwelling_number
	,J004.Street
	,J004.suburb
	,J004.Post_Code
FROM
(
	Select     
		CL.Client_ID
		,P.Last_Name
		,P.Given_Names
		,P.Preferred_Name
		,CONVERT(datetime,P.Deceased_Date) Deceased_Date
		,T.Description as 'Title'
	from Client CL WITH(NOLOCK)
	Inner Join Person P WITH(NOLOCK) on Cl.Client_ID = P.Person_ID
	Inner Join Title T on P.Title_Code = T.Title_Code
) J001

LEFT OUTER JOIN dbo.Personal_Contact J002 ON J002.Person_ID = J001.Client_ID
LEFT OUTER JOIN dbo.Personal_Contact_Type J003 ON J003.Personal_Contact_Type_Code = J002.Personal_Contact_Type_Code
LEFT OUTER JOIN dbo.Person_Current_Address_Phone J004 ON J004.Person_id = J001.Client_ID

INNER JOIN 
(
	Select
		P.Person_ID
		,P.Preferred_Name
		,P.Last_Name
		,P.Given_Names
		,CONVERT(datetime,P.Deceased_Date) Deceased_Date
		,T.Description as 'Title'
	from Person P  WITH(NOLOCK)
	Inner Join Title T on P.Title_Code = T.Title_Code
) J005 ON J005.Person_ID = J002.Contact_ID

LEFT OUTER JOIN dbo.Person_Comm_Point_Type J006 ON J006.Person_ID = J005.Person_ID
LEFT OUTER JOIN dbo.Person_Communication_Point J007 ON J007.Communication_Point_Number = J006.Communication_Point_Number AND J007.Person_ID = J006.Person_ID
LEFT OUTER JOIN dbo.Service_Delivery J008 ON J008.Client_ID = J001.Client_ID

INNER JOIN 
(
	Select 
		SD.Client_ID
		,O.Organisation_Name
		,SD.Service_Type_Code
	from dbo.Service_Delivery SD
	join dbo.Period_of_Residency PR on PR.Person_ID = SD.Client_ID
	join dbo.Address A on A.Address_ID = PR.Address_ID
	Join dbo.Service_Provision SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
	Join dbo.Organisation O on Sp.Centre_ID = O.Organisation_ID
	Where 
	PR.To_Date is null 
	and PR.Display_Indicator  = 1
) J009 ON J009.Client_ID = J008.Client_ID AND J009.Service_Type_Code = J008.Service_Type_Code

WHERE
	1=1
	AND J001.Deceased_Date IS NULL
	AND J003.Description=N'Service Advisor'
	AND J009.Organisation_Name in (@OrgName)

GROUP BY
	J001.Client_ID
	,J004.Phone
	,J005.Person_ID
	,J005.Preferred_Name
	,J005.Last_Name
--	,J006.Communication_Point_Number
	,case J007.Communication_Default_Ind when 0 then 'No' when 1 then 'Yes' else null end
	,J009.Organisation_Name
	,J001.Title
	,J001.Last_Name
	,J001.Preferred_Name
	,J004.Building_name
	,J004.Location
	,J004.dwelling_number
	,J004.Street
	,J004.suburb
	,J004.Post_Code

ORDER BY
	J009.Organisation_Name
	,J005.Last_Name
	,J005.Preferred_Name
	,J005.Person_ID
	,J001.Last_Name
	,J001.Preferred_Name
	,J001.Client_ID

