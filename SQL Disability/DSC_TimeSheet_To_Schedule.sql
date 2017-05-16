use ComCareProd
/*
--Select * from dbo.WI_Timesheet_Directive --empty
Select top 1 * from dbo.Activity_Work_Table where task_type_code is not null
select top 1 * from dbo.WI_Activity where Activity_ID =848834
select Top 1 * from dbo.Actual_Service order by date_Finalised -- where activity_No = 161906
select * from dbo.Indirect_Activity_Type
--*/


DECLARE @StartDate AS DATETIME = '20170328 00:00:00.000'
DECLARE @EndDate AS DATETIME = '20170328 00:00:00.000'
declare @Organisation VarChar(64) = 'Disabilities Children'
declare @Provider_ID int = 10068812

--------------------------------------------------------------
--------------------------------------------------------------
--------------------------------------------------------------
--------------------------------------------------------------
--Main Query


select * from
(
	select
		J001.Activity_Date
		,J001.Provider_ID
		,Concat(J009.Last_Name,', ',J009.Preferred_Name) 'Provider_Name'
		,J007.Description 'Task_Type'
		,J008.Description 'Indirect_Activity_Type'
		,cast(J001.Activity_Start_Time as datetime) 'Activity_Start_Time'
		,J001.Activity_Duration
		,cast(J001.Schedule_Time as datetime) 'Schedule_Time'
		,J001.Schedule_Duration
		,J001.Service_Prov_Position_ID 'SPPID'
		,J001.Classn_Shift_Centre 'RoundCode'
		,iif(J002.Provider_ID is null,'No_Schedule',IIF(J001.WI_Record_ID is null,'Forced_Match','Matched_Schedule')) 'Schedule_Indicator'
		,cast(J002.Activity_Date as datetime) 'WI_Activity_Date'
		,cast(J002.Activity_Start_Time as datetime) 'WI_Activity_Start_Time'
		,J002.Activity_Duration 'WI_Activity_Duration'
		,J002.Absence_Code
		,cast(J002.Schedule_Time as datetime) 'WI_Schedule_Time'
		,J002.Schedule_Duration 'WI_Schedule_Duration'
		,J002.Generated_Provider_Code 'WI_RoundCode'
		,J002.SPPID 'WI_SPPID'
		,cast(J006.Activity_Start_Time as datetime) 'AS_Activity_Start_Time'
		,cast(J006.Visit_Time as datetime) 'AS_Visit_Time'
		,J006.Visit_Duration 'AS_Visit_Duration'
		,J006.Scheduled_Duration 'AS_Scheduled_Duration'
		,J001.Activity_No 'Activity_No'
		
/*
		------------------------------------------
		--debug vals
		------------------------------------------
		,J006.Activity_No 'J006_Activity_No'
		,J001.WI_Record_ID 'J001_WI_Record_ID'
		,J002.Activity_ID 'J002_Activity_ID'

--*/
	from 
	(
		select
			awt.Activity_Date 'Activity_Date'
			,awt.Activity_Duration 'Activity_Duration'
			,awt.Activity_Start_Time 'Activity_Start_Time'
			,awt.Schedule_Time 'Schedule_Time'
			,awt.Schedule_Duration 'Schedule_Duration'
			,awt.Class_ID 'Class_ID'
			,awt.Provider_ID 'Provider_ID'
			,awt.Service_Prov_Position_ID 'Service_Prov_Position_ID'
			,awt.WI_Activity_ID 'WI_Activity_ID'
			,awt.WI_Record_ID 'WI_Record_ID'
			,awt.Classn_Shift_Centre 'Classn_Shift_Centre'
			,awt.Task_Type_Code 'Task_Type_Code'
			,awt.Client_Not_Home 'Client_Not_Home'
			,awt.Cancelled_Visit 'Cancelled_Visit'
			,awt.Indirect_Activity_No 'Indirect_Activity_No'
			,awt.Indirect_Activity_Type_Code 'Indirect_Activity_Type_Code'
			,awt.Activity_No 'Activity_No'
			,awt.Actual_Service_Visit_No 'Actual_Service_Visit_No'
		from dbo.Activity_Work_Table AWT
		where
			1=1
			and cast(awt.Activity_Date as date) between @StartDate and @EndDate
		
	)J001

		Left outer join dbo.WI_Activity J002 
			on J002.Activity_ID = J001.WI_Record_ID
			or 1 =
			(
				case
					when 
					J001.WI_Record_ID is null
					and J002.Generated_Provider_Code = J001.Classn_Shift_Centre
					and J002.Activity_Start_Time = J001.Schedule_Time
					and J002.Provider_ID = J001.Provider_ID
					and J002.SPPID = J001.Service_Prov_Position_ID
					then 1
					else 0
				end
			)

		Left outer join dbo.Service_Provision_Position J003 on J003.Service_Prov_Position_ID = J001.Service_Prov_Position_ID
		Left outer join dbo.Service_Delivery_Work_Team J004 on J004.Team_No = J003.Team_No and J004.Centre_ID = J003.Centre_ID
		Left outer join dbo.Organisation J005 on J005.Organisation_ID = J004.Centre_ID

		Left outer Join dbo.Actual_Service J006 on J006.Activity_No  = J001.Activity_No 

		Left outer join dbo.Task_Type J007 on J007.Task_Type_Code = J001.Task_Type_Code
		Left outer join dbo.Indirect_Activity_Type J008 on J008.Indirect_Activity_Type_Code = J001.Indirect_Activity_Type_Code
		Left outer join dbo.Person J009 on J009.Person_ID = J001.Provider_ID

	Where
		1=1
		and J005.Organisation_Name = @Organisation


/*
		------------------------------------------
		--debug vals
		------------------------------------------
		and J001.Provider_ID = @Provider_ID
--*/
	--------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------
	Union all
	--------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------

	select
		J001.Activity_Date
		,J001.Provider_ID
		,Concat(J009.Last_Name,', ',J009.Preferred_Name) 'Provider_Name'
		,J007.Description 'Task_Type'
		,J008.Description 'Indirect_Activity_Type'
		,cast(J001.Activity_Start_Time as datetime) 'Activity_Start_Time'
		,J001.Activity_Duration
		,cast(J001.Schedule_Time as datetime) 'Schedule_Time'
		,J001.Schedule_Duration
		,J001.Service_Prov_Position_ID 'SPPID'
		,J001.Classn_Shift_Centre 'RoundCode'
		,iif(J002.Provider_ID is null,'No_Schedule','Matched_Schedule') 'Schedule_Indicator'
		,cast(J002.Activity_Date as datetime) 'WI_Activity_Date'
		,cast(J002.Activity_Start_Time as datetime) 'WI_Activity_Start_Time'
		,J002.Activity_Duration 'WI_Activity_Duration'
		,J002.Absence_Code
		,cast(J002.Schedule_Time as datetime) 'WI_Schedule_Time'
		,J002.Schedule_Duration 'WI_Schedule_Duration'
		,J002.Generated_Provider_Code 'WI_RoundCode'
		,J002.SPPID 'WI_SPPID'
		,cast(J006.Activity_Start_Time as datetime) 'AS_Activity_Start_Time'
		,cast(J006.Visit_Time as datetime) 'AS_Visit_Time'
		,J006.Visit_Duration 'AS_Visit_Duration'
		,J006.Scheduled_Duration 'AS_Scheduled_Duration'
		,J001.Activity_No 'Activity_No'
/*
		------------------------------------------
		--debug vals
		------------------------------------------
		
		,J006.Activity_No 'J006_Activity_No'
		,J001.WI_Record_ID 'J001_WI_Record_ID'
		,J002.Activity_ID 'J002_Activity_ID'

--*/
	From 
	(
		select * from
			dbo.WI_Activity WIA
		where
			1=1
			and WIA.Provider_ID is not null
			and WIA.Provider_ID <> 0
			and cast(WIA.Activity_Date as date) between @StartDate and @EndDate
	)J002

	Left outer join
	(
		select
			awt.Activity_Date 'Activity_Date'
			,awt.Activity_Duration 'Activity_Duration'
			,awt.Activity_Start_Time 'Activity_Start_Time'
			,awt.Schedule_Time 'Schedule_Time'
			,awt.Schedule_Duration 'Schedule_Duration'
			,awt.Class_ID 'Class_ID'
			,awt.Provider_ID 'Provider_ID'
			,awt.Service_Prov_Position_ID 'Service_Prov_Position_ID'
			,awt.WI_Activity_ID 'WI_Activity_ID'
			,awt.WI_Record_ID 'WI_Record_ID'
			,awt.Classn_Shift_Centre 'Classn_Shift_Centre'
			,awt.Task_Type_Code 'Task_Type_Code'
			,awt.Client_Not_Home 'Client_Not_Home'
			,awt.Cancelled_Visit 'Cancelled_Visit'
			,awt.Indirect_Activity_No 'Indirect_Activity_No'
			,awt.Indirect_Activity_Type_Code 'Indirect_Activity_Type_Code'
			,awt.Activity_No 'Activity_No'
			,awt.Actual_Service_Visit_No 'Actual_Service_Visit_No'
		from dbo.Activity_Work_Table AWT
		where
			1=1
	--		and awt.Activity_Date between @StartDate and @EndDate
		
	)J001 on J002.Activity_ID = J001.WI_Record_ID
		Left outer join dbo.Service_Provision_Position J003 on J003.Service_Prov_Position_ID = J001.Service_Prov_Position_ID
		Left outer join dbo.Service_Delivery_Work_Team J004 on J004.Team_No = J003.Team_No and J004.Centre_ID = J003.Centre_ID
		Left outer join dbo.Organisation J005 on J005.Organisation_ID = J004.Centre_ID

		Left outer Join dbo.Actual_Service J006 on J006.Activity_No  = J001.Activity_No 
		
		Left outer join dbo.Task_Type J007 on J007.Task_Type_Code = J001.Task_Type_Code
		Left outer join dbo.Indirect_Activity_Type J008 on J008.Indirect_Activity_Type_Code = J001.Indirect_Activity_Type_Code
		Left outer join dbo.Person J009 on J009.Person_ID  = J001.Provider_ID

	Where
		1=1
		and J005.Organisation_Name = @Organisation

/*
		------------------------------------------
		--debug vals
		------------------------------------------
		and J001.Provider_ID = @Provider_ID
--*/

)t1

Group by
	t1.Activity_Date
	,t1.Provider_ID
	,t1.Provider_Name
	,t1.Task_Type
	,t1.Indirect_Activity_Type
	,t1.Activity_Start_Time
	,t1.Activity_Duration
	,t1.Schedule_Time
	,t1.Schedule_Duration
	,t1.SPPID
	,t1.RoundCode
	,t1.Schedule_Indicator
	,t1.WI_Activity_Date
	,t1.WI_Activity_Start_Time
	,t1.WI_Activity_Duration
	,t1.Absence_Code
	,t1.WI_Schedule_Time
	,t1.WI_Schedule_Duration
	,t1.WI_RoundCode
	,t1.WI_SPPID
	,t1.AS_Activity_Start_Time
	,t1.AS_Visit_Time
	,t1.AS_Visit_Duration
	,t1.AS_Scheduled_Duration
	,t1.Activity_No
/*
	,t1.J006_Activity_No
	,t1.J001_WI_Record_ID
	,t1.J002_Activity_ID
--*/
order by
	t1.Activity_Date
	,t1.Provider_ID
	,case
		when t1.Activity_Start_Time is not null then cast(t1.Activity_Start_Time as varchar(128))
		when t1.Activity_Start_Time is null and t1.Schedule_Time is not null then cast(t1.Schedule_Time as varchar(128))
	end