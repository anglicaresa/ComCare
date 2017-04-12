/***********************************************************
RESOLVED QUERY Table:CLIEN
Process Time:			00:00:00.515 
SQL Execution Time:		00:00:00.992 
Get Data Time:		00:00:01.055 
***********************************************************/
DECLARE @BD_Start_Date AS DATETIME
DECLARE @BD_End_Date AS DATETIME
DECLARE @InternOrgName AS Varchar(60)
SET @BD_Start_Date = dateadd(day,datediff(day,14,GETDATE()),0)
SET @BD_End_Date = dateadd(day,datediff(day,0,GETDATE()),0)
SET @InternOrgName = 'Home Care South'
PRINT @BD_Start_Date
PRINT @BD_End_Date

SELECT
J003.[Organisation_Name] as 'Organisation_Name'
,DATEPART(month, J001.[Birth_Date]) AS Month
,DATEPART(day, J001.[Birth_Date]) AS Day
,J001.[Birth_Date] AS 'Birth_Date'
,J001.[Client_ID]
,J001.[Title]
,J001.[Given_Names]
,J001.[Preferred_Name]
,J001.[Last_Name]
,J004.[Description] AS 'Service'
,J005.[Building_name]
,J005.[Location]
,J005.[dwelling_number]
,J005.[Street]
,J005.[suburb]
,J005.[Post_Code]
FROM
(
Select     CL.Client_ID,
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
	    CONVERT(datetime,P.Deceased_Date) [Deceased_Date],
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
) J001
LEFT OUTER JOIN [appsql-3\comcareprod].[comcareprod].[dbo].[Service_Delivery] J002 ON J002.[Client_ID] = J001.[Client_ID]
INNER JOIN (
Select SD.Client_ID, O.Organisation_Name, SD.Service_Type_Code from [appsql-3\comcareprod].[comcareprod].[dbo].Service_Delivery SD
join [appsql-3\comcareprod].[comcareprod].[dbo].Period_of_Residency PR on PR.Person_ID = SD.Client_ID
join [appsql-3\comcareprod].[comcareprod].[dbo].Address A on A.Address_ID = PR.Address_ID
Join [appsql-3\comcareprod].[comcareprod].[dbo].Service_Provision SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
Join [appsql-3\comcareprod].[comcareprod].[dbo].Organisation O on Sp.Centre_ID = O.Organisation_ID
Where PR.To_Date is null and PR.Display_Indicator  = 1
) J003 ON J003.[Client_ID] = J002.[Client_ID] AND J003.[Service_Type_Code] = J002.[Service_Type_Code]
LEFT OUTER JOIN [appsql-3\comcareprod].[comcareprod].[dbo].[Service_Type] J004 ON J004.[Service_Type_Code] = J002.[Service_Type_Code]
LEFT OUTER JOIN [appsql-3\comcareprod].[comcareprod].[dbo].[Person_Current_Address_Phone] J005 ON J005.[Person_id] = J001.[Client_ID]
WHERE
 1=1
 AND J001.[Deceased_Date] IS NULL
 AND J002.[To_Date] IS NULL
 AND J003.[Organisation_Name] in (@InternOrgName)
 AND
	(
		DATEADD(year, DATEDIFF(year, J001.[Birth_Date], @BD_Start_Date), J001.[Birth_Date]) BETWEEN @BD_Start_Date AND @BD_End_Date
	    OR 
		DATEADD(year, DATEDIFF(year, J001.[Birth_Date], @BD_End_Date), J001.[Birth_Date]) BETWEEN @BD_Start_Date AND @BD_End_Date
	)


GROUP BY
J003.[Organisation_Name]
,DATEPART(month, J001.[Birth_Date])
,DATEPART(day, J001.[Birth_Date])
,J001.[Birth_Date]
,J001.[Client_ID]
,J001.[Title]
,J001.[Given_Names]
,J001.[Preferred_Name]
,J001.[Last_Name]
,J004.[Description]
,J005.[Building_name]
,J005.[Location]
,J005.[dwelling_number]
,J005.[Street]
,J005.[suburb]
,J005.[Post_Code]

ORDER BY
1,2,3