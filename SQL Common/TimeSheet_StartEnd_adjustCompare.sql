use ComCareProd

--Select * from dbo.Activity_Work_Table where WI_Record_ID = 1441885

--10052616
/*
select * From dbo.WI_Event_Log where provider_id = 10052616 and content like 'WI_Timesheet_Edit %'
select * from dbo.WI_Activity where Activity_ID = 1314432
select * from dbo.Activity_Work_Table where Provider_ID = 10012083 and Activity_Date = cast('2017-03-14' as date)
*/



Select 
	WI_EL.Provider_ID
	,WI_EL.Device_Timestamp
	,cast ((select Text from dbo.Split(WI_EL.Content, ',') where Record_Number = 1) as Varchar(128)) 'Edit_Type'
	,cast ((select Text from dbo.Split(WI_EL.Content, ',') where Record_Number = 2) as Varchar(128)) 'Edit_Action'
	,cast ((select Text from dbo.Split(WI_EL.Content, ',') where Record_Number = 3) as int) 'Wi_Record'
--	,cast ((select Text from dbo.Split(WI_EL.Content, ',') where Record_Number = 10) as Varchar(128)) 'SPPID'
	,cast(Replace((select Text from dbo.Split(WI_EL.Content, ',') where Record_Number = 5),'''','')as Date) 'Activity_Date'
	,cast(Replace((select Text from dbo.Split(WI_EL.Content, ',') where Record_Number = 14),'''','')as datetime2) 'Start_Time'
	,cast(Replace((select Text from dbo.Split(WI_EL.Content, ',') where Record_Number = 15),'''','')as datetime2) 'End_Time'
--	,WI_EL.Content
from dbo.WI_Event_Log WI_EL 

where 
	1=1
	and cast(Created as date) between dateadd(day,-90, getdate()) and Getdate()
	and WI_EL.provider_id = 10052616
	and WI_EL.content like 'WI_Timesheet_Edit %'

Order by
2
