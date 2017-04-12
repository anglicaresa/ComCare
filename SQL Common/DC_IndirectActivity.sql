use ComCareProd

declare @stringDate varchar(32) = '2017-03-01'
declare @stringDate2 varchar(32) = '2017-03-31'
declare @Start_Date date = convert(date, @stringDate)
declare @End_Date date = convert(date, @stringDate2)

declare @Organisation VarChar(64) = 'Disabilities Children'

select
	J001.Provider_ID
	,J002.Preferred_Name
	,J002.Last_Name
	,cast(J001.Activity_Start_Time as datetime) 'Activity_Start_Time'
	,(J001.Activity_Duration / 60.0) 'Duration (H)'
	,J003.Description 'Activity'
	,J006.Organisation_Name 'Delivery Centre'
	,J005.Description 'Team'
from dbo.WI_Activity J001
inner join dbo.Person J002 on J002.Person_ID = J001.Provider_ID

inner join dbo.Indirect_Activity_Type J003 on J003.Indirect_Activity_Type_Code = J001.Internal_Task_Code
inner join [dbo].[Service_Provision_Position] J004 on J004.Service_Prov_Position_ID = J001.SPPID
inner join [dbo].[Service_Delivery_Work_Team] J005 on J005.Team_No = J004.Team_No and J005.Centre_ID = J004.Centre_ID
inner join [dbo].Organisation J006 on J006.Organisation_ID = J004.Centre_ID

where
	1=1
	and J001.Activity_Date between @Start_Date and @End_Date
	and J001.Provider_ID <> 0
	and J001.Provider_ID is not null
	and J001.Internal_Task_Code <> 0
	and J001.Internal_Task_Code is not null
	and J006.Organisation_Name = @Organisation
--	and J001.Activity_Start_Time is not null




/*
select * from dbo.wi_activity
where internal_task_Code = 51


select * from dbo.[Service_Provision_Position]

[dbo].[Organisation] J001
inner join [dbo].[Service_Delivery_Work_Team] J002 on J002.[Centre_ID] = J001.[Organisation_ID]
	left outer join [dbo].[Service_Provision_Position] J003 on J003.[Centre_ID] = J002.[Centre_ID] and J003.[Team_No] = J002.[Team_No]
*/