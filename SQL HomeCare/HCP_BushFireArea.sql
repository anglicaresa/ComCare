Declare @OrgName varchar(128) = 'Home Care Barossa Yorke Peninsula'


SELECT
	J009.Organisation_Name
	,J001.Client_ID 
	,J001.Title
	,J001.Last_Name 'Client_Last_Name'
	,J001.Preferred_Name 'Client_Preferred_Name'
	,J010.Building_name
	,J010.Location
	,J010.dwelling_number
	,J010.Street
	,J010.suburb
	,J010.Post_Code
	,J011.Person_ID
	,J011.Preferred_Name 'Contact_Preferred_Name'
	,J011.Last_Name 'Contact_Last_Name'
	,J012.Phone
	,J007.Description 'contactType'
FROM
(
	Select     
		CL.Client_ID
	    ,P.Last_Name
	    ,P.Given_Names
	    ,P.Preferred_Name
		,T.Description 'Title'
	    ,P.Birth_Date
	    ,CONVERT(datetime,P.Deceased_Date) 'Deceased_Date'
	from Client CL WITH(NOLOCK)
	Inner Join Person P WITH(NOLOCK) on Cl.Client_ID = P.Person_ID
	Inner Join Title T on P.Title_Code = T.Title_Code
) J001

LEFT OUTER JOIN dbo.Person_Characteristic J002 ON J002.Person_ID = J001.Client_ID
LEFT OUTER JOIN dbo.Characteristic J003 ON J003.Characteristic_Code = J002.Characteristic_Code
LEFT OUTER JOIN dbo.Person_Alert J004 ON J004.Person_ID = J001.Client_ID
LEFT OUTER JOIN dbo.Alert_Type J005 ON J005.Alert_Type_ID = J004.Alert_Type_ID
LEFT OUTER JOIN dbo.Personal_Contact J006 ON J006.Person_ID = J001.Client_ID
LEFT OUTER JOIN dbo.Personal_Contact_Type J007 ON J007.Personal_Contact_Type_Code = J006.Personal_Contact_Type_Code
LEFT OUTER JOIN dbo.Service_Delivery J008 ON J008.Client_ID = J001.Client_ID

INNER JOIN 
(
	Select 
		SD.Client_ID
		,O.Organisation_Name
		,SD.Service_Type_Code 
	from Service_Delivery SD
	join Period_of_Residency PR on PR.Person_ID = SD.Client_ID
	join Address A on A.Address_ID = PR.Address_ID
	Join Service_Provision SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
	Join Organisation O on Sp.Centre_ID = O.Organisation_ID
	Where 
		PR.To_Date is null 
		and PR.Display_Indicator  = 1
) J009 ON J009.Client_ID = J008.Client_ID AND J009.Service_Type_Code = J008.Service_Type_Code

LEFT OUTER JOIN dbo.Person_Current_Address_Phone J010 ON J010.Person_id = J001.Client_ID

INNER JOIN 
(
	Select
		P.Person_ID
		,P.Preferred_Name
		,P.Last_Name
		,P.Given_Names
	from Person P  WITH(NOLOCK)
	Inner Join Title T on P.Title_Code = T.Title_Code
) J011 ON J011.Person_ID = J006.Contact_ID

LEFT OUTER JOIN dbo.Person_Current_Address_Phone J012 ON J012.Person_id = J011.Person_ID

WHERE
	1=1
	AND J001.Deceased_Date IS NULL
	AND  
	( 
		J003.Description = N'Bushfire vulnerable'
		OR J005.Description = N'High Bushfire Risk'
	)
	AND J007.Description IN (N'Emergency Contact',N'Friend/Neighbour',N'Next of Kin',N'Parent',N'Son or Daughter',N'Son-in-law or Daughter-in-law',N'Spouse/Partner',N'Step Mother')
	and J009.Organisation_Name in (@OrgName)

GROUP BY
	J009.Organisation_Name
	,J001.Client_ID
	,J001.Title
	,J001.Last_Name
	,J001.Preferred_Name
	,J010.Building_name
	,J010.Location
	,J010.dwelling_number
	,J010.Street
	,J010.suburb
	,J010.Post_Code
	,J011.Person_ID
	,J011.Preferred_Name
	,J011.Last_Name
	,J012.Phone
	,J007.Description 

ORDER BY
1,2,3
