--[appsql-3\TRAIN].[ComCareTRAIN]
--[APPSQL-3\COMCAREPROD].[comcareprod]


/*
select * from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[WI_Activity]
select top 1 * from [appsql-3\comcareprod].[comcareprod].[dbo].[Person_Current_Address_Phone]
select * from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Characteristic]
select * from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Service_Type]
select * from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Service_delivery]
select * from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Marital_Status]
select * from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].WI_Activity_Event_Type
select * from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Service_Delivery]
select * from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Actual_Service
select * from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Task_Type -- connects task_Type_ID and Service_Type_ID

select * from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Task_Schedule_Allocation -- the golden bullet

select * from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Person_Current_Address_Phone]
where person_id = 10071094

*/

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--in Prod 
 declare @serviceTable Table (serv varchar(128))
 insert into @serviceTable values
	('DA Assistance to access community')
	,('DA Assistance with Daily Life')
	,('DA Adults Outreach')
	,('DA Assistance with Self-care Activities')
	,('DA Assistance in a Shared Living Arrangement')
	,('DA Case Coordination')
	,('DA Group Based Community')
	,('DA Improved Daily Living Skills')
	,('DA Improved Learning')
	,('DA Improved Living Arrangements')
	,('DA Improved Life Choices')
	,('DA Improved Relationships')
	,('DA Adult Individual Support')
	,('DA Increased Social and Community Participation')
	,('DA Intake')
	,('DA Supported Independent Living ')
	,('DA Transport')

Declare @Client_ID_ AS INT
--Set @Client_ID_ = 10069826
Set @Client_ID_ = 10074726

Declare @ServiceType varchar(60)

set @ServiceType = 'DC Assistance to Access Community'

Declare @Organisation_Name_ varchar(40)
set @Organisation_Name_ = 'Disabilities Children'
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
SELECT

J001.[Client_ID] AS 'Client_ID'
,LAG(J001.[Client_ID]) Over 
	(Order by J001.[Client_ID]) as 'Pre_ID'
,J001.[Title] AS 'Client_Title'
,J001.[Last_Name] AS 'Client_LastName'
,J001.[Preferred_Name] AS 'Client_PreferredName'
,CONVERT(date,J001.[Birth_Date]) AS 'Birth_Date'
,J001.[Gender] as 'Gender'
,J013.[Service_Type] as 'Service_Type'
,J012.[Description] as 'Diagnosis'
,count(J012.[Description]) over(partition by J001.[Client_ID],J013.[Service_Type]) 'DiagnosisCount'
,convert(Varchar(16) ,J008.[Phone]) AS 'Contact_Phone_Number'
,J002.[Building_name] AS 'BuildingName'
,J002.[Location] AS 'Location'
,J002.[dwelling_number] AS 'DwellingNumber'
,J002.[Street] AS 'Street'
,J002.[suburb] AS 'Suburb'
,J002.[Post_Code] AS 'PostCode'
,J015.[MF_Provider] as 'M/F_Provider'
,convert(Varchar(16) ,J002.[Phone]) as 'alt_Phone'
,J001.[Ethnicity] as 'Ethnicity'
,Convert(int ,(Count(J013.[Service_Type]) Over (Partition by J001.[Client_ID], J012.[Description]))) as 'ServiceCount'

FROM 
(
	Select     
		CL.Client_ID
		,P.Last_Name
		,P.Given_Names
		,EC.Description as 'Ethnicity' 
		,P.Preferred_Name
		,P.Birth_Date
		,CONVERT(date,P.Deceased_Date) as Deceased_Date
		,G.Description as 'Gender'
		,T.Description as 'Title'
	from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Client CL WITH(NOLOCK)
		Inner Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Person] P WITH(NOLOCK) on Cl.[Client_ID] = P.[Person_ID]
		Inner Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Title] T on P.[Title_Code] = T.[Title_Code]
		Left Outer Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Ethnicity_Classification] EC on P.[Ethnicity_Class_Code] = EC.[Ethnicity_Class_Code]
		Left Outer Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Gender] G on P.[Gender_Code] = G.[Gender_Code]
) J001

LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Person_Current_Address_Phone] J002 ON J002.[Person_id] = J001.[Client_ID]

left outer join
(
	Select
		PC.[Person_ID]
		,PC.[Contact_ID]
		,PCT.[Description]
		,ROW_NUMBER() Over
		(
			Partition BY PC.[Person_ID] Order By
				Case
					WHEN PCT.[Description] = 'Mother' then '1'
					WHEN PCT.[Description] = 'Father' then '2'
					WHEN PCT.[Description] = 'Parent' then '3'
					WHEN PCT.[Description] = 'Grandparent' then '4'
					WHEN PCT.[Description] = 'Step Mother' then '5'
					WHEN PCT.[Description] = 'Step Father' then '6'
					WHEN PCT.[Description] = 'Guardian' then '7'
					WHEN PCT.[Description] = 'Foster Parent' then '8'
					WHEN PCT.[Description] = 'Other relative' then '9'
					WHEN PCT.[Description] is null then '10'
					Else PCT.[Description] END ASC
		) AS 'RN' 	
	From [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Personal_Contact] PC
	Left outer Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Personal_Contact_Type] PCT ON PCT.[Personal_Contact_Type_Code] = PC.[Personal_Contact_Type_Code] 
)J003 on J003.[Person_ID] = J001.[Client_ID]

left outer JOIN
(
	Select
		P.Person_ID
		,P.Preferred_Name
		,P.Last_Name
		,T.Description as 'Title'
	from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Person P  WITH(NOLOCK)
		Inner Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Title] T on P.[Title_Code] = T.[Title_Code]
) J007 ON J007.[Person_ID] = J003.[Contact_ID]

LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Person_Current_Address_Phone]J008 ON J008.[Person_id] = J007.[Person_ID]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Service_Delivery] J009 ON J009.[Client_ID] = J001.[Client_ID]

INNER JOIN
(
	Select 
		SD.Client_ID
		,O.Organisation_Name
		,SD.Service_Type_Code 
	from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Service_Delivery SD
		join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Period_of_Residency PR on PR.Person_ID = SD.Client_ID
		join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Address A on A.Address_ID = PR.Address_ID
		Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Service_Provision SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
		Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Organisation O on Sp.Centre_ID = O.Organisation_ID
	Where PR.To_Date is null and PR.Display_Indicator  = 1
) J010 ON J010.[Client_ID] = J009.[Client_ID] AND J010.[Service_Type_Code] = J009.[Service_Type_Code]

LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Diagnosis] J011 ON J011.[Client_ID] = J001.[Client_ID]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Diagnosis_Category] J012 ON J012.[Diagnosis_Category_Code] = J011.[Diagnosis_Category_Code]

Inner Join
(
	Select
		SD.[Client_ID]
		,iif(ST.Description = 'OATS', ST_ALT.[Task_Description], ST.Description) as 'Service_Type'
	From [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Service_Delivery] SD
		left outer join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Service_Type] ST On ST.[Service_Type_Code] = SD.[Service_Type_Code]
		left outer join 
		(
			select
				tt.[Description] as 'Task_Description'
				,tt.[Service_Type_Code] as 'Service_Type_Code'
				,tt.[task_type_code] as 'Task_Type_Code'
				,ROW_NUMBER() Over
				(
					Partition BY tt.[Service_Type_Code] Order By tt.[Task_Type_Code] ASC
				) as 'RN'
			from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Task_Type tt
		)ST_ALT On ST_ALT.[Service_Type_Code] = SD.[Service_Type_Code]
	Where 
	1=1
	AND SD.To_Date IS NULL
	AND ST_ALT.RN = 1
	OR ST.Description = 'OATS'
)J013 on J013.[Client_ID] = J001.[Client_ID]

LEFT OUTER JOIN 
(
	select
		PC.[Person_ID] AS 'Person_ID'
		,C.[Description] as 'CL_LGBTI'
	From [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Person_Characteristic] PC
	inner join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Characteristic] C ON C.[Characteristic_Code] = PC.[Characteristic_Code]
	where
	1=1
	and C.[Description] = 'Identify as LGBTI'
)J014 on J014.[Person_ID] = J001.[Client_ID]

left outer JOIN 
(
	select
		PC.[Person_ID] AS 'Person_ID'
		,C.[Description] as 'MF_Provider'
		,ROW_NUMBER() Over
		(
			Partition BY PC.[Person_ID] Order By
				Case
					WHEN C.[Description] = 'Visit from a female provider' then '1'
					WHEN C.[Description] = 'Visit from a male provider' then '2'
					else C.[Description] END ASC
		) AS 'RN'
	From [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Person_Characteristic] PC
	left outer join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Characteristic] C ON C.[Characteristic_Code] = PC.[Characteristic_Code]
)J015 on J015.[Person_ID] = J001.[Client_ID]


WHERE
	1=1
	and J010.[Organisation_Name] = @Organisation_Name_

	and ( IIF( J003.RN IS NULL, 1, J003.RN ) = 1 )
	and ( IIF( J015.RN IS NULL, 1, J015.RN ) = 1 )

	and J001.[Deceased_Date] IS NULL
--	and J013.[Service_Type] IN (@ServiceType)
	and J001.Client_ID = @Client_ID_
	-- NOTE service date = null is inside the subquiry

GROUP BY
J001.[Client_ID]
,J001.[Title]
,J001.[Last_Name]
,J001.[Preferred_Name]
,CONVERT(date,J001.[Birth_Date])
,J001.[Gender]
,J013.[Service_Type]
,J012.[Description]
,convert(Varchar(16) ,J008.[Phone])
,J002.[Building_name]
,J002.[Location]
,J002.[dwelling_number]
,J002.[Street]
,J002.[suburb]
,J002.[Post_Code] 
,J015.[MF_Provider]
,convert(Varchar(16) ,J002.[Phone])
,J001.[Ethnicity]
--,Count(J013.[Service_Type]) Over (Partition by J001.[Client_ID])

ORDER BY
	J001.[Client_ID]
