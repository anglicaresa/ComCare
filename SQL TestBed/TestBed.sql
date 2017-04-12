use asadwh;
declare @Code int;
set @Code= 1 --@RAC_Site

SELECT
J007.Description as Shift_Type
,J002.[Provider_ID] as Provider_ID
,J002.[Given_Names] as Given_Name
,J002.[Last_Name] as Last_Name
,J004.[Centre_ID] as Centre_ID
 ,J004.[Centre] as Organisation_Name
,J001.[Absence_Code] as Absence
,J006.[Description] as Provider_Classification
,J005.[Generated_Provider_Code] as Round_Code
,J009.[Description] as Team_Name
,convert(date,J001.[Activity_Date]) as Date
,max( convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
			case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
				when 1 
				then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
				else convert(varchar,datepart(minute,J001.schedule_time)) 
			end ) as Start_Time
,max( convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
			case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
				when 1 
				then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
				else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
			end) as End_Time
,J001.Schedule_Time as Time
,J001.[Schedule_Duration] as Schedule_Duration
FROM
[appsql-3\comcareprod].[comcareprod].dbo.[WI_Activity] J001
INNER JOIN (
Select
		Prov.Provider_ID,
		prov.ComCare_Provider_No,
		prov.Employee_No,
		prov.Creation_Date,
		prov.Creator_User_Name,
		prov.Last_Modified_Date,
		Prov.Last_Modified_User_Name,
		Prov.Trainer,
		P.Preferred_Name,
		P.Last_Name,
		P.Given_Names,
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
from [appsql-3\comcareprod].[comcareprod].dbo.Provider Prov WITH(NOLOCK)
Inner Join [appsql-3\comcareprod].[comcareprod].dbo.Person P WITH(NOLOCK) on Prov.Provider_ID = P.Person_ID
Inner Join [appsql-3\comcareprod].[comcareprod].dbo.Title T on P.Title_Code = T.Title_Code
Left Outer Join [appsql-3\comcareprod].[comcareprod].dbo.Gender G on P.Gender_Code = G.Gender_Code
Left Outer Join [appsql-3\comcareprod].[comcareprod].dbo.Country C on P.Country_Code = C.Country_Code
Left Outer Join [appsql-3\comcareprod].[comcareprod].dbo.Language L on P.Language_Code = L.Language_Code
Left Outer Join [appsql-3\comcareprod].[comcareprod].dbo.Employment_Status ES on P.Employment_Status_ID = ES.Employment_Status_ID
Left Outer Join [appsql-3\comcareprod].[comcareprod].dbo.Marital_Status MS on P.Marital_Status_ID = MS.Marital_Status_ID
Left Outer Join [appsql-3\comcareprod].[comcareprod].dbo.Interpreter_Status INS on P.Interpreter_Status_ID = INS.Interpreter_Status_ID
Left Outer Join [appsql-3\comcareprod].[comcareprod].dbo.Ethnicity_Classification EC on P.Ethnicity_Class_Code = EC.Ethnicity_Class_Code
) J002 ON J002.[Provider_ID] = J001.[Provider_ID]
LEFT OUTER JOIN [appsql-3\comcareprod].[comcareprod].dbo.Provider_Contract J003 ON J003.[Provider_ID] = J002.[Provider_ID]
LEFT OUTER JOIN (
SELECT C.Centre_ID,C.Centre_Code, O.Organisation_Name [Centre] from [appsql-3\comcareprod].[comcareprod].dbo.Centre C	
JOIN [appsql-3\comcareprod].[comcareprod].dbo.Organisation O ON C.Centre_ID = O.Organisation_ID
) J004 ON J004.[Centre_ID] = J003.[Organisation_ID]
LEFT OUTER JOIN [appsql-3\comcareprod].[comcareprod].dbo.Service_Provision_Position J005 ON J005.[Service_Prov_Position_ID] = J001.[SPPID]
LEFT OUTER JOIN [appsql-3\comcareprod].[comcareprod].dbo.Provider_Classification J006 ON J006.[Provider_Class_Code] = J005.[Provider_Class_Code]
LEFT OUTER JOIN [appsql-3\comcareprod].[comcareprod].dbo.Shift J007 ON J007.[Shift_Code] = J005.[Shift_Code]
INNER JOIN [appsql-3\comcareprod].[comcareprod].dbo.[Team_Position] J008 ON J008.[Service_Prov_Position_ID] = J005.[Service_Prov_Position_ID]
LEFT OUTER JOIN [appsql-3\comcareprod].[comcareprod].dbo.[Service_Delivery_Work_Team] J009 ON J009.[Centre_ID] = J008.[Centre_ID] AND J009.[Team_No] = J008.[Team_No]
WHERE

J004.[Centre_ID] = @Code and
J006.Provider_Class_Code in(@Provider_Classification)
and J001.[Activity_Date] BETWEEN @Start_Date AND @End_Date
 and J001.[Schedule_Duration] is not null
 and J003.Effective_date_to is null

GROUP BY
J007.Description
,J002.[Last_Name]
,J005.[Generated_Provider_Code]
,J004.[Centre_ID]
,J001.[Absence_Code]
,J006.[Description]
,J009.[Description]
,J001.Schedule_Time
 ,J004.[Centre]
,convert(date,J001.[Activity_Date])
,J002.[Provider_ID]
,J002.[Given_Names]
,(CONVERT(datetime,Scheduled_Visit_End_Time))
,J001.[Schedule_Duration]
ORDER BY
Time,Last_Name