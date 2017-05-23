use ComCareProd
--------------------------------------------
declare @ClientId as int = 10019824
declare @StartDate as DateTime = cast(Dateadd(day,-13,Getdate()) as Date)
declare @EndDate as DateTime = Cast(Getdate() as Date)
--------------------------------------------
select 
	J001.client_id
	,J001.Provider_ID
	,datename(WEEKDAY,J001.Activity_Date) 'WorkDay'
	,convert(date,J001.Activity_Date,103) 'Activity_date'
	,J001.Schedule_Task_Type
	,substring(convert(varchar,J001.schedule_time,108),1,5) 'schedule_Start_time'
	,substring(convert(varchar,dateadd(minute,J001.schedule_duration,convert(time,J001.schedule_time)),108),1,5) 'schedule_End_time'
	,cast(J001.Schedule_Duration as float)/60 'Hours'
	,case J009.provider_contract_type_code
		when '3' then 'Agency'
		else J004.Preferred_Name
		end 'Preferred_Name'
	,J005.Description 'Task_Description'
	,(J006.Preferred_Name+' '+J006.Last_Name) 'client_name'
	,J008.Description 'Program'
from (select * from dbo.WI_Activity where cast(Activity_Date as Date) between Cast(@StartDate as Date) and Cast(@EndDate as Date)) J001
Left outer join dbo.Round_Allocation J002 on J001.Round_Allocation_ID = J002.Allocated_Round_ID
Left outer join dbo.Task_Schedule_Allocation J003 on J002.Schedule_Sequence_No = J003.Schedule_Sequence_No
Left outer join dbo.person J004 on J001.provider_id = J004.Person_ID
Left Outer Join dbo.Task_Type J005 on J005.Task_Type_Code=J001.Schedule_Task_Type
Left Outer Join dbo.person J006 on J001.client_id = J006.Person_ID

Left Outer Join 
(
	select 
		FC_CC.client_id 'Client_ID'
		,min(FC_CC.program_id) 'Program_ID'
	from dbo.FC_Client_Contract FC_CC
	where
		1=1 
		and FC_CC.Effective_To_Date is null 
	group by 
		FC_CC.client_id

)J007 on J001.client_id = J007.client_id
Inner Join dbo.PT_Program J008 on J008.Program_ID = J007.Program_ID
Left Outer Join dbo.provider_contract J009 on J001.provider_id = J009.provider_id

where 
	1=1
	and J001.client_id = @ClientId
--	and cast(J001.Activity_Date as Date) between @StartDate and @EndDate
	and J009.Effective_date_to is null
	-------------------------------
	--DEBUG-- 
--	and J001.Provider_ID = 0
	and J001.Client_ID is not null
order by 
	J001.Activity_Date
	,J001.Schedule_Time asc 