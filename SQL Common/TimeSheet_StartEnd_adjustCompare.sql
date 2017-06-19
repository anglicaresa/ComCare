use ComCareProd

declare @stringDate varchar(32) = '2017-05-17'
declare @stringDate2 varchar(32) = '2017-05-17'--'2017-01-20'
declare @Start_Date date = convert(date, @stringDate)
declare @End_Date date = convert(date, @stringDate2)
declare @Centre varchar(32) = 'Dutton Court'

declare @ShowVacantOnly int = 1
declare @NoBuddyShifts int = 1
declare @hideUnAss int = 0

-----------------------------------------------------------------------------------------------
declare @ClassCodeFilter Table (Provider_Class_Code VarChar(128),Description VarChar(128))
insert into @ClassCodeFilter
select 
	J003.Provider_Class_Code
	,J004.Description

from [dbo].[Organisation] J001

inner join [dbo].[Service_Delivery_Work_Team] J002 on J002.[Centre_ID] = J001.[Organisation_ID]
left outer join [dbo].[Service_Provision_Position] J003 on J003.[Centre_ID] = J002.[Centre_ID] and J003.Team_No = J002.Team_No
inner join [dbo].[Provider_Classification] J004 on J004.Provider_Class_Code = J003.Provider_Class_Code

where
	1=1
	and J001.Organisation_Name = @Centre

Group by
	J003.Provider_Class_Code
	,J004.Description

Order by
	J004.Description
-----------------------------------------------------------------------------------------------
declare @TeamFilt table (description varchar(128))
insert into @TeamFilt
select 
	J002.Description 'Team'

from [dbo].[Organisation] J001

inner join [dbo].[Service_Delivery_Work_Team] J002 on J002.[Centre_ID] = J001.[Organisation_ID]
left outer join [dbo].[Service_Provision_Position] J003 on J003.[Centre_ID] = J002.[Centre_ID] and J003.Team_No = J002.Team_No
--inner join [dbo].[Provider_Classification] J004 on J004.Provider_Class_Code = J003.Provider_Class_Code

where
	1=1
	and J001.Organisation_Name = @Centre
	and J002.Effective_Date_To is null
	and J003.Provider_Class_Code in (select Provider_Class_Code from @ClassCodeFilter)

group by J002.Description
order by 1

--declare @ClassCodeFilter VarChar(8)= 'PCW'
--declare @TeamFilt VarChar(128) = 'Banksia Central'
--declare @TeamFilt VarChar(128) = 'Buddy Team'
declare @SortBy VarChar(32) = 'StartTime'
--------------------------------------------------DeBug
declare @forceProv_ID int = 0

--declare @Prov_ID int = 10048668 --Hill, Nerissa has split shift CLEAN
--declare @Prov_ID int = 10048524 --Norrie, Carol has split shift CLEAN
--declare @Prov_ID int = 10049327 --Sparrow, Carrie has split shift CLEAN
--declare @Prov_ID int = 10075347 --Kneebone, Helen Has split shift **second shift not not recorded.* has dule StartEnd.
--declare @Prov_ID int = 10048181 --Kneebone, Helen Has split shift CLEAN
--declare @Prov_ID int = 10046817 --Nelson, Margaret Has split shift **Only 1 sign off
declare @Prov_ID int = 10048536 --Broderick, Josie **Record Duplicate

------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
--Copy from here down
------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------




declare @EventBracket1 int = -1
declare @EventBracket2 int = 13
--------------------------------------------------------------
--------------------------------------------------------------

--Setup Vars and Defults.
declare @date_Start date = @Start_Date
declare @date_End date = @End_Date

---------------------------------------------------------------
--Pre assemble Provider list for performance reasons
---------------------------------------------------------------
declare @Provs Table
(
	Provider_ID int
	,ProviderName varChar(128)
)
insert into @Provs
	Select
		X001.Provider_ID
		,(X002.Last_Name + ', ' + X002.Preferred_Name) 'ProviderName'
	From 
	(
		Select
			WiA.[SPPID] 'SPPID'
			,cast (WiA.[Activity_Date] as date) 'Activity_Date'
			,cast (WiA.Schedule_Time as datetime2) 'Schedule_StartTime'
			,DateAdd(MINUTE, WiA.Schedule_Duration,cast(WiA.Schedule_Time as datetime2))'Schedule_EndTime'
			,WiA.[Absence_Code] 'Absence_Code'
			,WiA.[Provider_ID] 'Provider_ID'
			,WiA.Schedule_Duration 'Schedule_Duration'
			,WiA.Generated_Provider_Code 'Generated_Provider_Code'
			,ROW_NUMBER () -- sort by importance of 'covered' 'absent' and 'Un-Alocated'.
				over 
				(
					Partition by cast(WiA.Schedule_Time as Datetime2), WiA.[SPPID] Order by 
						Case
							when ((WiA.[Provider_ID] > 0) and (WiA.[Absence_Code] is NULL)) then concat('1_',WiA.[Provider_ID])
							when (WiA.[Provider_ID] > 0) and (WiA.[Absence_Code] is not NULL) then concat('2_',WiA.[Provider_ID])
						else 'z'
					end
				) 'RN'
		From [dbo].[Wi_Activity] WiA
		where convert(date, Wia.Activity_Date) between dateadd(day,@EventBracket1,@Start_Date) and dateadd(day,@EventBracket2,@End_Date)
	)X001

	Inner Join dbo.Person X002 on X002.Person_ID = X001.Provider_ID
	Inner Join dbo.Service_Provision_Position X003 on X003.Service_Prov_Position_ID = X001.SPPID
	Inner join dbo.Service_Delivery_Work_Team X004 on X004.Team_No = X003.Team_No and X004.Centre_ID = X003.Centre_ID
	Inner join dbo.Organisation X005 on X005.Organisation_ID = X004.Centre_ID
	Left outer join dbo.Service_Provision_Allocation X006 on X006.Service_Prov_Position_ID = X003.Service_Prov_Position_ID
	Left outer join dbo.Provider_Classification X007 on X007.Provider_Class_Code = X003.Provider_Class_Code
		where
		1=1
		and X001.RN < 2
			and X001.Schedule_Duration is not null
			and cast(X001.Activity_Date as date) between @date_Start and @date_End
		and 
		(
			1 = IIF
			(
				1 <> @forceProv_ID
				and X001.[Provider_ID] <> 0
				and X005.Organisation_Name = @Centre
				and X003.Provider_Class_Code in (select Provider_Class_Code from @ClassCodeFilter)
				and X004.Description in (select * from @TeamFilt)
--				and X003.Provider_Class_Code in (@ClassCodeFilter)
--				and X004.Description in (@TeamFilt)
				,1
				,0
			)
			or
			1 = IIF
			(
				1 = @forceProv_ID
				and X001.[Provider_ID] = @Prov_ID
				,1
				,0 
			)
		)

		
	Group by
		X001.Provider_ID
		,(X002.Last_Name + ', ' + X002.Preferred_Name)
	order by
		1
--select * from @Provs
	



----------------------------------------------------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------
declare @RawResult Table
(
	Provider_ID int
	,ProviderName varChar(128)
	,Device_Timestamp DateTime
	,Edit_Action varChar(128)
	,Activity_Date DateTime
	,Start_Time DateTime
	,End_Time DateTime
	,Edit_Type varChar(128)
	,RN int
	,Count_ int
	,Wi_Record int
	,FirstTimeStamp DateTime
	,LastTimeStamp DateTime
	,Row_Count int
	,RowNumber int
)
insert into @RawResult
	Select
		SJ001.Provider_ID
		,SJ001.ProviderName
		,SJ001.Device_Timestamp
		,SJ001.Edit_Action
		,SJ001.Activity_Date
		,SJ001.Start_Time
		,SJ001.End_Time
		,SJ001.Edit_Type
		,Row_Number()over(Partition by SJ001.Provider_ID,SJ001.Edit_Action,SJ001.Activity_Date Order by SJ001.Activity_Date,SJ001.Device_Timestamp)'RN'
		,Count(SJ001.Edit_Action) over (partition by SJ001.Provider_ID,SJ001.Edit_Action,SJ001.Activity_Date,SJ001.Wi_Record Order by SJ001.Activity_Date,SJ001.Device_Timestamp)'Count_'
		,SJ001.Wi_Record
		,MIN(SJ001.Device_Timestamp) over (partition by SJ001.Provider_ID,SJ001.Activity_Date )'FirstTimeStamp'
		,Max(SJ001.Device_Timestamp) over (partition by SJ001.Provider_ID,SJ001.Activity_Date )'LastTimeStamp'
		,Count(SJ001.Provider_ID)over (partition by null )'Row_Count'
		,Row_Number() over(Partition by null order by SJ001.Provider_ID, SJ001.ProviderName, SJ001.Device_Timestamp)'RowNumber'
	From
	(
		select
			WI_EL_C.Provider_ID
			,Provs.ProviderName
		--	,WI_EL_C.Content
		--	,WI_EL_C.Directive_Type_ID
			,cast(WI_EL_C.Device_Timestamp as datetime2)'Device_Timestamp'
			,cast(Replace((select Text from dbo.Split(WI_EL_C.Content, ',') where Record_Number = 1),'''','') as Varchar(128)) 'Edit_Type'
			,cast(Replace((select Text from dbo.Split(WI_EL_C.Content, ',') where Record_Number = 2),'''','')as Varchar(128)) 'Edit_Action'
			,cast((select Text from dbo.Split(WI_EL_C.Content, ',') where Record_Number = 3) as int) 'Wi_Record'
			,cast(Replace((select Text from dbo.Split(WI_EL_C.Content, ',') where Record_Number = 5),'''','')as Date) 'Activity_Date'
			,cast(Replace((select Text from dbo.Split(WI_EL_C.Content, ',') where Record_Number = 14),'''','')as datetime2) 'Start_Time'
			,cast(Replace((select Text from dbo.Split(WI_EL_C.Content, ',') where Record_Number = 15),'''','')as datetime2) 'End_Time'
		from
		(
			select * from dbo.WI_Event_Log Z 
			where 
			1=1
			and Z.Directive_Type_ID = 114 
			and Z.Device_Timestamp between dateadd(day,@EventBracket1,cast(@Start_Date as datetime)) and dateadd(day,@EventBracket2,cast(@End_Date as datetime))
			and Z.Provider_ID in (Select p.Provider_ID from @Provs p)
		)WI_EL_C
		Inner Join @Provs Provs on Provs.Provider_ID = WI_EL_C.Provider_ID
	)SJ001
	where
		1=1
		and SJ001.Activity_Date between @Start_Date and @End_Date
	Order by
	1,2,3

--select * from @RawResult


Declare @i_RowNum int = 1
Declare @i_MaxRow int = (select top 1 RR.Row_Count from @RawResult RR)
Declare @i_PID int = null
Declare @t_ActivityDate DateTime = null
declare @J_Edit_Action VarChar(255) = null
declare @i_BaseCount int = 1
Declare @i_TriggerFirstTaskEntry int	= 1
Declare @JoinedEdit_Actions table (Provider_ID int, Activity_Date datetime,Joined_Edit_Action VarChar(255))
declare @i_Temp int = 0


while @i_RowNum <= @i_MaxRow
begin
	
	set @i_PID = (select RR.Provider_ID from @RawResult RR where RR.RowNumber = @i_RowNum)--baseValue setup
	Set @t_ActivityDate = (select RR.Activity_Date from @RawResult RR where RR.RowNumber = @i_RowNum)
		
	if @i_BaseCount = 1
	begin
		set @J_Edit_Action = (select RR.Edit_Action from @RawResult RR where RR.RowNumber = @i_RowNum)
	end
		
	if @i_BaseCount <> 1
	begin
		set @J_Edit_Action = @J_Edit_Action + ', ' + (select RR.Edit_Action from @RawResult RR where RR.RowNumber = @i_RowNum)
	end
	set @i_Temp = @i_BaseCount
	set  @i_BaseCount = @i_Temp + 1
	set @i_Temp = @i_RowNum
	set @i_RowNum = @i_Temp + 1 --Cycle mechanic

	if 
	(@i_PID <> (select RR.Provider_ID from @RawResult RR where RR.RowNumber = @i_RowNum)) 
	or (@t_ActivityDate <> (select RR.Activity_Date from @RawResult RR where RR.RowNumber = @i_RowNum)) 
	or  @i_RowNum = @i_MaxRow
	begin
		set @i_TriggerFirstTaskEntry = 0
	end
	

	if @i_TriggerFirstTaskEntry = 0
	begin
		insert into @JoinedEdit_Actions Values ( @i_PID,@t_ActivityDate,@J_Edit_Action)
		set @i_TriggerFirstTaskEntry = 1
		set @i_BaseCount = 1
	end

end

--select * from @JoinedEdit_Actions
--select * from @RawResult

--/*
Select
	J001.Provider_ID
	,J001.ProviderName
	,J001.Activity_Date
	,J001.FirstTimeStamp 'StartTime_Raw'
	,J001.Start_Time 'StartTime_Alt'
	,J001.LastTimeStamp 'EndTime_Raw'
	,J001.End_Time 'EndTime_Alt'
--	,J001.Prev_StartTime
	,J001.LogDuration_Raw
	,J001.LogDuration_Alt
	,(J001.LogDuration_Raw - J001.LogDuration_Alt)'Diff'
--	,IIF(JS001.Start_Time
--	,J001.EndTime_Alt
	,J002.Joined_Edit_Action 'editActions'
	,J001.Wi_Record

From 
(
	select
		RR.*
--		,Lag(RR.Start_Time)over(Partition by RR.Provider_ID, RR.Activity_Date order by RR.Device_Timestamp)'Prev_StartTime'
		,DateDiff(MINUTE,RR.FirstTimeStamp,RR.LastTimeStamp)'LogDuration_Raw'
		,DateDiff(MINUTE,RR.Start_Time,RR.End_Time)'LogDuration_Alt'
	--	,Max(RR.Device_Timestamp)over(partition by DateAdd(Minute,-10,RR.Device_Timestamp))'SessionLastStamp'
	from @RawResult RR
)J001

left outer join @JoinedEdit_Actions J002 on J002.Provider_ID = J001.Provider_ID and J002.Activity_Date = J001.Activity_Date

where
	1=1
	and J001.Start_Time IS not null
	and J001.End_Time is not null
--/*
Group by
	J001.Provider_ID
	,J001.ProviderName
	,J001.Activity_Date
	,J001.FirstTimeStamp
	,J001.Start_Time
	,J001.LastTimeStamp
	,J001.End_Time
--	,J001.Prev_StartTime
	,J001.LogDuration_Raw
	,J001.LogDuration_Alt
	,(J001.LogDuration_Raw - J001.LogDuration_Alt)
	,J002.Joined_Edit_Action
	,J001.Wi_Record
--*/
