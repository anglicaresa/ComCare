--[appsql-3\TRAIN].[ComCareTRAIN]
--[APPSQL-3\COMCAREPROD].[comcareprod]
/*



select * FROM [APPSQL-3\COMCAREPROD].[comcareprod].dbo.task_type
where
Service_Type_code = 'oats'

select * FROM [APPSQL-3\COMCAREPROD].[comcareprod].dbo.WI_Activity
where
Client_ID = 10071612
AND (Schedule_Time BETWEEN (dateadd(day,datediff(day,7,GETDATE()),0)) AND dateadd(day,datediff(day,0,GETDATE()),0)) 
AND Cancellation_Date is not null

select * FROM [APPSQL-3\COMCAREPROD].[comcareprod].dbo.Scheduling_Activity
where
Round_Allocation_ID = 62036

select * FROM [APPSQL-3\COMCAREPROD].[comcareprod].dbo.Task_Type
where 
Task_Type_Code = 'AWDASA'

select * FROM [APPSQL-3\COMCAREPROD].[comcareprod].dbo.Schedule_Allocation_Time

*/
DECLARE @Start_Date AS DATETIME
DECLARE @End_Date AS DATETIME
DECLARE @Organisation_Name_ AS Varchar(60)
SET @Start_Date = dateadd(day,datediff(day,7,GETDATE()),0)
SET @End_Date = dateadd(day,datediff(day,0,GETDATE()),0)
SET @Organisation_Name_ = 'Disabilities Children'
PRINT @Start_Date
PRINT @End_Date

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

SELECT        
J004.Organisation_Name
,J002.Client_ID
, J002.Title
,J002.Last_Name
,J002.Preferred_Name
,CONVERT(datetime, J002.Birth_Date) as 'Birth_Date'
,J005.Building_name
,J005.Location
,J005.dwelling_number
,J005.Street
,J005.suburb
,J005.Post_Code
,J006.Description
,CONVERT(datetime, J001.Schedule_Time) AS Schedule_Time
,Case
	when (J001.Client_Not_Home <> 0) then 'Client not home'
	when (J001.Cancellation_Date IS NOT NULL) then 'Cancelled visit'
	else ''
end
 as CancelType

FROM [APPSQL-3\COMCAREPROD].[comcareprod].dbo.WI_Activity J001 
INNER JOIN
(
	SELECT
		CL.Client_ID
		,P.Last_Name
		,P.Preferred_Name
		,P.Birth_Date
		,CONVERT(datetime, P.Deceased_Date) AS 'Deceased_Date'
		,T.Description AS 'Title'

	FROM [APPSQL-3\COMCAREPROD].[comcareprod].dbo.Client CL WITH (NOLOCK) 
		INNER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].dbo.Person P WITH (NOLOCK) ON CL.Client_ID = P.Person_ID 
		INNER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].dbo.Title T ON P.Title_Code = T.Title_Code 
)J002 ON J002.Client_ID = J001.Client_ID

INNER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].dbo.Service_Delivery J003 ON J003.Client_ID = J002.Client_ID

INNER JOIN
(
	SELECT        
		SD.Client_ID
		, O.Organisation_Name
		, SD.Service_Type_Code
	FROM [APPSQL-3\COMCAREPROD].[comcareprod].dbo.Service_Delivery SD 
		INNER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].dbo.Period_of_Residency PR ON PR.Person_ID = SD.Client_ID 
		INNER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].dbo.Address A ON A.Address_ID = PR.Address_ID 
		INNER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].dbo.Service_Provision SP ON A.Suburb_ID = SP.Suburb_ID AND SP.Service_Type_Code = SD.Service_Type_Code 
		INNER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].dbo.Organisation O ON SP.Centre_ID = O.Organisation_ID
    WHERE
		(PR.To_Date IS NULL) 
		AND (PR.Display_Indicator = 1)
)J004 ON J004.Client_ID = J002.Client_ID AND J004.Service_Type_Code = J003.Service_Type_Code
 
Inner Join [APPSQL-3\COMCAREPROD].[comcareprod].dbo.Person_Current_Address_Phone J005 ON J005.Person_id = J002.Client_ID 
Inner Join [APPSQL-3\COMCAREPROD].[comcareprod].dbo.Task_Type J006 ON J006.Task_Type_Code = J001.Schedule_Task_Type

WHERE
1=1					
AND ((J001.Client_Not_Home <> 0) OR (J001.Cancellation_Date IS NOT NULL))
AND (J001.Schedule_Time BETWEEN (@Start_Date) AND (@End_Date)) 
AND J004.Organisation_Name IN (@Organisation_Name_)
AND (J002.Deceased_Date IS NULL)
--AND J001.Client_ID = 10071612

GROUP BY 
	J004.Organisation_Name
	,J002.Client_ID
	,J002.Title
	,J002.Last_Name
	,J002.Preferred_Name
	,J002.Birth_Date
	,J005.Building_name
	,J005.Location
	,J005.dwelling_number
	,J005.Street
	,J005.suburb
	,J005.Post_Code
	,J006.Description
	,CONVERT(datetime, J001.Schedule_Time)
	,Case
		when (J001.Client_Not_Home <> 0) then 'Client not home'
		when (J001.Cancellation_Date IS NOT NULL) then 'Cancelled visit'
		else ''
	end

ORDER BY
1,2,14
