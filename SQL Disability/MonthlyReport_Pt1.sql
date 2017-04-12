use ComCareProd
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--in train 
--[APPSQL-3\COMCAREPROD].[comcareprod]
--[appsql-3\TRAIN].[ComCareTRAIN]


Declare @Client_ID_ AS INT
Set @Client_ID_ = 10070013
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
SELECT Top 1
J002.[Client_ID] AS 'Client_ID'
,J002.[Title] AS 'Client_Title'
,J002.[Last_Name] AS 'Client_LastName'
,J002.[Preferred_Name] AS 'Client_PreferredName'
,J004.[Description] AS 'Contact_Type'
,J007.[Title] AS 'Contact_Title'
,J007.[Last_Name] AS 'Contact_LastName'
,J007.[Preferred_Name] AS 'Contact_PreferredName'
,J008.[Building_name] AS 'Contact_BuildingName'
,J008.[Location] AS 'Contact_Location'
,J008.[dwelling_number] AS 'Contact_DwellingNumber'
,J008.[Street] AS 'Contact_Street'
,J008.[suburb] AS 'Contact_Suburb'
,J008.[Post_Code] AS 'Contact_PostCode'
,J006.[Description] AS 'Client_CardType'
,J005.[Card_No] AS 'Client_CardNo'

FROM [dbo].[WI_Activity] J001
INNER JOIN 
(
	Select
		CL.Client_ID
		,P.Last_Name
		,P.Preferred_Name
		,T.Description as 'Title'
	from [dbo].Client CL WITH(NOLOCK)
		Inner Join [dbo].Person P WITH(NOLOCK) on Cl.Client_ID = P.Person_ID
		Inner Join [dbo].Title T on P.Title_Code = T.Title_Code
)

J002 ON J002.[Client_ID] = J001.[Client_ID]

LEFT OUTER JOIN [dbo].[Personal_Contact] J003 ON J003.[Person_ID] = J002.[Client_ID]
LEFT OUTER JOIN [dbo].[Personal_Contact_Type] J004 ON J004.[Personal_Contact_Type_Code] = J003.[Personal_Contact_Type_Code]
LEFT OUTER JOIN [dbo].[Card_Holder] J005 ON J005.[Person_ID] = J002.[Client_ID]
LEFT OUTER JOIN [dbo].[Card_Type] J006 ON J006.[Card_Type_ID] = J005.[Card_Type_ID]

INNER JOIN 
(
	Select
		P.Person_ID
		,P.Preferred_Name
		,P.Last_Name
		,T.Description as 'Title'
	from [dbo].Person P  WITH(NOLOCK)
		Inner Join [dbo].Title T on P.Title_Code = T.Title_Code
) 
J007 ON J007.[Person_ID] = J003.[Contact_ID]

LEFT OUTER JOIN [dbo].[Person_Current_Address_Phone] J008 ON J008.[Person_id] = J007.[Person_ID]

WHERE
	1=1
	AND J002.[Client_ID] = @Client_ID_
	--AND J002.[Client_ID] = 10071545
	--AND J004.[Description] IN(N'Father',N'Foster Parent',N'Grandparent',N'Guardian',N'Mother',N'Parent',N'Step Father',N'Step Mother')
	--AND J006.[Description]=N'NDIS Number'
GROUP BY
	J002.[Client_ID]
	,J002.[Title]
	,J002.[Last_Name]
	,J002.[Preferred_Name]
	,J004.[Description]
	,J007.[Title]
	,J007.[Last_Name]
	,J007.[Preferred_Name]
	,J008.[Building_name]
	,J008.[Location]
	,J008.[dwelling_number]
	,J008.[Street]
	,J008.[suburb]
	,J008.[Post_Code]
	,J006.[Description]
	,J005.[Card_No]

ORDER BY
	J002.[Client_ID]
	
	,Case
		WHEN J004.[Description] is null then J004.[Description]
		WHEN J004.[Description] = 'Mother' then '1'
		WHEN J004.[Description] = 'Father' then '2'
		WHEN J004.[Description] = 'Parent' then '3'
		WHEN J004.[Description] = 'Grandparent' then '4'
		WHEN J004.[Description] = 'Step Mother' then '5'
		WHEN J004.[Description] = 'Step Father' then '6'
		WHEN J004.[Description] = 'Guardian' then '7'
		WHEN J004.[Description] = 'Foster Parent' then '8'
		Else J004.[Description] END ASC
		
	,Case
		WHEN J006.[Description] = 'NDIS Number' Then '1'
		Else J006.[Description] END ASC

/*
select * from [dbo].[WI_Activity]
where Provider_ID <> 0
*/