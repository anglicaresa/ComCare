/*
select * from dbo.WI_Activity where cast(Activity_Date as date) = '2017-07-19' and Schedule_Task_Type = 'PCHCP'
*/

Declare @StartDate Date = '2017-07-19'
Declare @EndDate Date = '2017-07-20'

Declare @OrgName VarChar(128) = 'Home Care East'

SELECT
	J004.Organisation_Name
	,J005.Provider_ID
	,J005.Last_Name
	,J005.Preferred_Name
	,J007.Description 'TaskDescription'
--	,J003.Service_Type_Code
	,J001.Schedule_Task_Type
	,J001.Activity_Date
FROM
( 
	select 
		WIA.Provider_ID
		,WIA.Schedule_Task_Type
		,Cast(WIA.Activity_Date as date)'Activity_Date'
		,WIA.Client_ID
	from dbo.WI_Activity WIA where cast(WIA.Activity_Date as date) between @StartDate and @EndDate
)J001

--LEFT OUTER JOIN dbo.Service_Delivery J003 ON J003.Client_ID = J001.Client_ID

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
) J004 ON J004.Client_ID = J001.Client_ID --AND J004.Service_Type_Code = J003.Service_Type_Code

INNER JOIN 
(
	Select
		Prov.Provider_ID
		,P.Preferred_Name
		,P.Last_Name
	from dbo.Provider Prov
	Inner Join dbo.Person P on Prov.Provider_ID = P.Person_ID
) J005 ON J005.Provider_ID = J001.Provider_ID

--LEFT OUTER JOIN dbo.Service_Type J006 ON J006.Service_Type_Code = J003.Service_Type_Code
Left outer join dbo.Task_Type J007 on J007.Task_Type_Code = J001.Schedule_Task_Type
WHERE
	1=1
	and J004.Organisation_Name in (@OrgName)

GROUP BY
J004.Organisation_Name
,J005.Provider_ID
,J005.Last_Name
,J005.Preferred_Name
,J007.Description
--,J003.Service_Type_Code
,J001.Schedule_Task_Type
,J001.Activity_Date

ORDER BY
	J004.Organisation_Name
	,J005.Last_Name
	,J005.Preferred_Name
	,J001.Activity_Date
	,J007.Description