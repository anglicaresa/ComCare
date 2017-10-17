declare @Start_Date date = '2017-10-04'
declare @End_Date date = '2017-10-06'

Declare @Organisation Varchar(128) = 'Home Care east'


Declare @Client_List table (Client_ID int)
insert into @Client_List
Select distinct
	SD.Client_ID
from dbo.Service_Delivery SD
	join dbo.Period_of_Residency PR on PR.Person_ID = SD.Client_ID
	join dbo.Address A on A.Address_ID = PR.Address_ID
	Join dbo.Service_Provision SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
	Join dbo.Organisation O on Sp.Centre_ID = O.Organisation_ID
Where 
	PR.To_Date is null 
	and PR.Display_Indicator  = 1
	and O.Organisation_Name = @Organisation
Order by 1


--/*
select 
	cast(J001.Activity_Date as date)'Activity_Date'
	,cast(J001.Schedule_Time as time)'Schedule_Time'
	,J001.Client_ID
	,J003.Preferred_Name + ' ' + J003.Last_Name 'Client_Name'
	,J001.Provider_ID 
	,J004.Preferred_Name + ' ' + J004.Last_Name 'Provider_Name'
	,J002.Description 'Task_Type'
	,cast(J001.Cancellation_Date as datetime)'Cancellation_Date'
	,J006.Description 'Cancellation_Reason'
	,J001.Cancel_Recorded_Person_ID
	,J005.Preferred_Name + ' ' + J005.Last_Name 'Cancel_Recorded_Person_Name'
from 
(
	select
	*
	from dbo.WI_Activity Wi
	where
		Wi.Client_ID in (select * from @Client_List)
		and Wi.Activity_Date between @Start_Date and @End_Date
)
J001
Left outer join dbo.Task_Type J002 on J002.Task_Type_Code = Schedule_Task_Type
Left outer join dbo.Person J003 on J003.Person_ID = J001.Client_ID
Left outer join dbo.Person J004 on J004.Person_ID = J001.Provider_ID
Left outer join dbo.Person J005 on J005.Person_ID = J001.Cancel_Recorded_Person_ID
Left outer join dbo.Visit_Cancel_Reason J006 on J006.Visit_Cancel_Reason_ID = J001.Visit_Cancel_Reason_ID
where J001.Cancel_Recorded_Person_ID is not null
order by J001.Schedule_Time
--*/