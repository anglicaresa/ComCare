--[APPSQL-3\COMCAREPROD].[comcareprod]
--[appsql-3\TRAIN].[ComCareTRAIN]

Declare @Organisation_Name_ varchar(40)
set @Organisation_Name_ = 'Disabilities Children'




SELECT

	J017.[Organisation_Name] as 'Organisation_Name'
	,J001.[Client_ID] as 'Client_ID'
	,LAG(J001.[Client_ID]) Over 
	(Order by	J017.[Organisation_Name], J001.[Client_ID],J015.[Description]
				,CASE 
					WHEN J013.[Description] = 'Visit from a female provider' THEN '1'
					WHEN J013.[Description] = 'Visit from a male provider' THEN '2'
					ELSE J013.[Description] END ASC
	) as 'Pre_ID'
	,J001.[Title] as 'Title'
	,J001.[Last_Name] as 'Last_Name'
	,J001.[Preferred_Name] as 'Preferred_name'
	,J008.[Description] as 'Contact_type'
	,J010.[Phone] as 'Phone'
	,J011.[Building_name] as 'Building_name'
	,J011.[Location] as 'Location'
	,J011.[dwelling_number] as 'dwelling_number'
	,J011.[Street] as 'Street'
	,J011.[suburb] as 'suburb'
	,J011.[Post_Code] as 'Post_Code'
	,J001.[Birth_Date] as 'Birth_Date'
	,J001.[Gender] as 'Gender'
	,J015.[Description] as 'Service_Requested'
	,LAG(J015.[Description]) Over 
	(Order by	J017.[Organisation_Name], J001.[Client_ID],J015.[Description]
				,CASE 
					WHEN J013.[Description] = 'Visit from a female provider' THEN '1'
					WHEN J013.[Description] = 'Visit from a male provider' THEN '2'
					ELSE J013.[Description] END ASC
	) as 'Pre_Serv'
	,J002.[First_Visit_Requested_Date] as 'Requested_Date'
	,J002.[Referral_Date] as 'Referral_Date'
	,J021.[Description] as 'Diagnosis'
	,J013.[Description] as 'Characteristic'


FROM
(
	Select     
		CL.Client_ID,
		P.Last_Name,
		P.Preferred_Name as 'Preferred_Name',
		P.Salutation,
		P.Birth_Date,
		CONVERT(datetime,P.Deceased_Date) [Deceased_Date],
		G.Description as 'Gender',
		T.Description as 'Title'
	from [APPSQL-3\COMCAREPROD].[comcareprod].dbo.Client CL WITH(NOLOCK)

	Inner Join [APPSQL-3\COMCAREPROD].[comcareprod].dbo.Person P WITH(NOLOCK) on Cl.Client_ID = P.Person_ID
	Inner Join [APPSQL-3\COMCAREPROD].[comcareprod].dbo.Title T on P.Title_Code = T.Title_Code
	Left Outer Join [APPSQL-3\COMCAREPROD].[comcareprod].dbo.Gender G on P.Gender_Code = G.Gender_Code
) J001

LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Referral] J002 ON J002.[Client_ID] = J001.[Client_ID]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Person] J002Person ON J002Person.[Person_ID] = J002.[Client_ID]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Referral_Queue] J003 ON J003.[Client_ID] = J002.[Client_ID] AND J003.[Referral_No] = J002.[Referral_No]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Referral] J004 ON J004.[Client_ID] = J003.[Client_ID] AND J004.[Referral_No] = J003.[Referral_No]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Person] J004Person ON J004Person.[Person_ID] = J004.[Client_ID]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Referral_Queue] J005 ON J005.[Client_ID] = J004.[Client_ID] AND J005.[Referral_No] = J004.[Referral_No]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Referral_Status] J006 ON J006.[Status_ID] = J005.[Status_ID]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Personal_Contact] J007 ON J007.[Person_ID] = J001.[Client_ID]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Personal_Contact_Type] J008 ON J008.[Personal_Contact_Type_Code] = J007.[Personal_Contact_Type_Code]

INNER JOIN 
(
	Select
		P.Person_ID,
		P.Preferred_Name,
		P.Last_Name,
		P.Salutation,
		P.Birth_Date,
		CONVERT(datetime,P.Deceased_Date) [Deceased_Date],
		G.Description as 'Gender',
		T.Description as 'Title'
	from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Person P  WITH(NOLOCK)
	Inner Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Title T on P.Title_Code = T.Title_Code
	Left Outer Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Gender G on P.Gender_Code = G.Gender_Code

) J009 ON J009.[Person_ID] = J007.[Contact_ID]

LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Person_Current_Address_Phone] J010 ON J010.[Person_id] = J009.[Person_ID]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Person_Current_Address_Phone] J011 ON J011.[Person_id] = J001.[Client_ID]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Person_Characteristic] J012 ON J012.[Person_ID] = J001.[Client_ID]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Characteristic] J013 ON J013.[Characteristic_Code] = J012.[Characteristic_Code]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Service_Requested] J014 ON J014.[Client_ID] = J002.[Client_ID] AND J014.[Referral_No] = J002.[Referral_No]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Service_Type] J015 ON J015.[Service_Type_Code] = J014.[Service_Type_Code]
INNER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Service_Delivery] J016 ON J016.[Client_ID] = J002.[Client_ID] AND J016.[Referral_No] = J002.[Referral_No]

INNER JOIN 
(
	Select SD.Client_ID, O.Organisation_Name, SD.Service_Type_Code from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Service_Delivery SD
	join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Period_of_Residency PR on PR.Person_ID = SD.Client_ID
	join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Address A on A.Address_ID = PR.Address_ID
	Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Service_Provision SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
	Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Organisation O on Sp.Centre_ID = O.Organisation_ID
	Where PR.To_Date is null and PR.Display_Indicator  = 1

) J017 ON J017.[Client_ID] = J016.[Client_ID] AND J017.[Service_Type_Code] = J016.[Service_Type_Code]

INNER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Service_Delivery] J018 ON J018.[Client_ID] = J004.[Client_ID] AND J018.[Referral_No] = J004.[Referral_No]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Service_Delivery_Diagnosis] J019 ON J019.[Service_Delivery_ID] = J018.[Service_Delivery_ID]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Diagnosis] J020 ON J020.[Diagnosis_ID] = J019.[Diagnosis_ID]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Diagnosis_Category] J021 ON J021.[Diagnosis_Category_Code] = J020.[Diagnosis_Category_Code]

WHERE
	 1=1
	 AND J017.[Organisation_Name] IN (@Organisation_Name_)
	 AND J006.[Description] IN(N'New Referral',N'Pending')
	 AND J008.[Description] IN(N'Father',N'Guardian',N'Mother',N'Parent')

GROUP BY
	J001.[Client_ID]
	,J001.[Title]
	,J001.[Last_Name]
	,J001.[Preferred_Name]
	,J008.[Description]
	,J010.[Phone]
	,J011.[Building_name]
	,J011.[Location]
	,J011.[dwelling_number]
	,J011.[Street]
	,J011.[suburb]
	,J011.[Post_Code]
	,J001.[Birth_Date]
	,J001.[Gender]
	,J015.[Description]
	,J013.[Description]
	,J002.[First_Visit_Requested_Date]
	,J002.[Referral_Date]
	,J017.[Organisation_Name]
	,J021.[Description]
ORDER BY
J017.[Organisation_Name]
,J001.[Client_ID]
,J015.[Description]
,CASE 
	WHEN J013.[Description] = 'Visit from a female provider' THEN '1'
	WHEN J013.[Description] = 'Visit from a male provider' THEN '2'
	ELSE J013.[Description] END ASC
