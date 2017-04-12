/***********************************************************
RESOLVED QUERY Table:PerCha
Process Time:			00:00:00.004 
SQL Execution Time:		00:00:00.051 
Get Data Time:		00:00:00.051 
***********************************************************/
--database to use in this case AnglicareSA Data Whare House
--use [ASADWH];

--primary table?
--select * from [appsql-3\comcareprod].[comcareprod].[dbo].[Person]

select
	J004.[Organisation_Name],
	J005.[Description],
	J002.[Client_ID]

FROM [appsql-3\comcareprod].[comcareprod].[dbo].[Person_Characteristic] J001 
LEFT OUTER JOIN 
(
	Select     
		CL.Client_ID,
		P.Last_Name,
		P.Given_Names,
		CL.URN,
		RE.Description as 'Religion',
		PBS.Description as 'Pension Benefit Status',
		CRS.Description as 'Carer Residency Status',
		CL.Registration_Date,
		CL.Creation_Date,
		Cl.Creator_User_Name,
		Cl.Last_Modified_Date,
		Cl.Last_Modified_User_Name,
		EC.Description as 'Ethnicity' ,
		CAT.Description as 'Carer Avaliability Type',
		P.Preferred_Name,
		P.Salutation,
		P.Birth_Date,
		CONVERT(datetime, P.Deceased_Date) [Deceased_Date],
		P.Estimated_DOB_Flag,
		P.Dummy_PID,
		P.Source_System,
		P.Source_System_Person_ID,
		G.Description as 'Gender',
		T.Description as 'Title',
		C.Description as 'Country',
		L.Description as 'Language',
		ES.Description as 'Employment Status',
		MS.Description as 'Marital Status',
		INS.Description as 'Interpreter Status'

	from [appsql-3\comcareprod].[comcareprod].[dbo].Client CL WITH(NOLOCK)
	Inner Join [appsql-3\comcareprod].[comcareprod].[dbo].Person P WITH(NOLOCK) on Cl.Client_ID = P.Person_ID
	Inner Join [appsql-3\comcareprod].[comcareprod].[dbo].Title T on P.Title_Code = T.Title_Code
	Left Outer Join [appsql-3\comcareprod].[comcareprod].[dbo].Carer_Availability_Type CAT on CL.Carer_Availability_Type_Code = CAT.Carer_Availability_Type_Code
	Left Outer Join [appsql-3\comcareprod].[comcareprod].[dbo].Ethnicity_Classification EC on P.Ethnicity_Class_Code = EC.Ethnicity_Class_Code
	Left Outer Join [appsql-3\comcareprod].[comcareprod].[dbo].Religion RE on CL.Religion_Code = RE.Religion_Code
	Left Outer Join [appsql-3\comcareprod].[comcareprod].[dbo].Carer_Residency_Status CRS on CL.Carer_Residency_Status_Code = CRS.Carer_Residency_Status_Code
	Left Outer Join [appsql-3\comcareprod].[comcareprod].[dbo].Pension_Benefit_Status PBS on Cl.Pension_Benefit_Status_Code = PBS.Pension_Benefit_Status_Code
	Left Outer Join [appsql-3\comcareprod].[comcareprod].[dbo].Living_Arrangement LA on Cl.Living_Arrangement_Type_Code = LA.Living_Arrangement_Type_Code
	Left Outer Join [appsql-3\comcareprod].[comcareprod].[dbo].Gender G on P.Gender_Code = G.Gender_Code
	Left Outer Join [appsql-3\comcareprod].[comcareprod].[dbo].Country C on P.Country_Code = C.Country_Code
	Left Outer Join [appsql-3\comcareprod].[comcareprod].[dbo].Language L on P.Language_Code = L.Language_Code
	Left Outer Join [appsql-3\comcareprod].[comcareprod].[dbo].Employment_Status ES on P.Employment_Status_ID = ES.Employment_Status_ID
	Left Outer Join [appsql-3\comcareprod].[comcareprod].[dbo].Marital_Status MS on P.Marital_Status_ID = MS.Marital_Status_ID
	Left Outer Join [appsql-3\comcareprod].[comcareprod].[dbo].Interpreter_Status INS on P.Interpreter_Status_ID = INS.Interpreter_Status_ID
) 

J002 ON J002.[Client_ID] = J001.[Person_ID]
LEFT OUTER JOIN [appsql-3\comcareprod].[comcareprod].[dbo].[Service_Delivery] J003 ON J003.[Client_ID] = J002.[Client_ID]
INNER JOIN 
(
	Select 
		SD.Client_ID, 
		O.Organisation_Name, 
		SD.Service_Type_Code 
	from [appsql-3\comcareprod].[comcareprod].[dbo].Service_Delivery SD
	join [appsql-3\comcareprod].[comcareprod].[dbo].Period_of_Residency PR on PR.Person_ID = SD.Client_ID
	join [appsql-3\comcareprod].[comcareprod].[dbo].Address A on A.Address_ID = PR.Address_ID
	Join [appsql-3\comcareprod].[comcareprod].[dbo].Service_Provision SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
	Join [appsql-3\comcareprod].[comcareprod].[dbo].Organisation O on Sp.Centre_ID = O.Organisation_ID
	Where PR.To_Date is null and PR.Display_Indicator  = 1
) 

J004 ON J004.[Client_ID] = J003.[Client_ID] AND J004.[Service_Type_Code] = J003.[Service_Type_Code]
LEFT OUTER JOIN [appsql-3\comcareprod].[comcareprod].[dbo].[Characteristic] J005 ON J005.[Characteristic_Code] = J001.[Characteristic_Code]
WHERE
 1=1
 AND  1=1
 
GROUP BY
J004.[Organisation_Name]
,J005.[Description]
,J002.[Client_ID]

ORDER BY
1,2

