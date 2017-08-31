
--select * from dbo.Organisation where Organisation_Type_Code = 1

use ComCareProd

declare @stringDate varchar(32) = '2017-08-24'
declare @stringDate2 varchar(32) = '2017-08-24'--'2017-07-19' ,'2017-08-03' ,'2017-08-01'
declare @Start_Date date = convert(date, @stringDate)
declare @End_Date date = convert(date, @stringDate2)
--declare @Centre varchar(32) = 'Dutton Court'
--declare @Centre varchar(32) = 'Ian George Court'
declare @Centre Varchar(32) = 'All Hallows Court'
--declare @Centre Varchar(32) = 'St Laurences Court'
--declare @Centre Varchar(32) = 'Canterbury Close'
declare @ShowVacantOnly int = 1
declare @NoBuddyShifts int = 1
declare @hideUnAss int = 0



-----------------------------------------------------------------------------------------------
--populate @ClassCodeFilter for dev purposes
declare @ClassCodeFilter Table (Provider_Class_Code VarChar(128),Description VarChar(128))
insert into @ClassCodeFilter
select
	J103.Provider_Class_Code
	,J104.Description

from dbo.Organisation J101

inner join dbo.Service_Delivery_Work_Team J102 on J102.Centre_ID = J101.Organisation_ID
left outer join dbo.Service_Provision_Position J103 on J103.Centre_ID = J102.Centre_ID and J103.Team_No = J102.Team_No
inner join dbo.Provider_Classification J104 on J104.Provider_Class_Code = J103.Provider_Class_Code

where
	1=1
	and J101.Organisation_Name = @Centre

Group by
	J103.Provider_Class_Code
	,J104.Description

Order by
	J104.Description
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

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
--------------------------------------------------DeBug
declare @forceProv_ID int = 1


--declare @Prov_ID int = 10048668 --Hill, Nerissa has split shift CLEAN
--declare @Prov_ID int = 10048524 --Norrie, Carol has split shift CLEAN
--declare @Prov_ID int = 10049327 --Sparrow, Carrie has split shift CLEAN
--declare @Prov_ID int = 10075347 --Kneebone, Helen Has split shift **second shift not not recorded.* has dule StartEnd.
--declare @Prov_ID int = 10048181 --Kneebone, Helen Has split shift CLEAN
--declare @Prov_ID int = 10046817 --Nelson, Margaret Has split shift **Only 1 sign off
--declare @Prov_ID int = 10052628 --
--declare @Prov_ID int = 10046817 --Nelson, Margaret ***splitShift blerk
declare @Prov_ID int = 10051295
------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
--Copy from here down
------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------




declare @EventBracket1 int = -1
declare @EventBracket2 int = 13
declare @TimezoneOffset int = DateDiff(minute, GetUTCDate(), GetDate())
--------------------------------------------------------------
--------------------------------------------------------------

--Setup Vars and Defults.
declare @date_Start date = @Start_Date
declare @date_End date = iif(@End_Date < @Start_Date, @Start_Date, @End_Date)

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
			WiA.SPPID 'SPPID'
			,cast (WiA.Activity_Date as date) 'Activity_Date'
			,cast (WiA.Schedule_Time as datetime2) 'Schedule_StartTime'
			,DateAdd(MINUTE, WiA.Schedule_Duration,cast(WiA.Schedule_Time as datetime2))'Schedule_EndTime'
			,WiA.Absence_Code 'Absence_Code'
			,WiA.Provider_ID 'Provider_ID'
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
		where convert(date, Wia.Activity_Date) between dateadd(day,@EventBracket1,@date_Start) and dateadd(day,@EventBracket2,@date_End)
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
--Process Providers in @Provs gathering all relevent data
----------------------------------------------------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------
declare @RawResult Table
(
	Provider_ID int
	,ProviderName varChar(128)
	,Device_Timestamp DateTime
	,Edit_Action varChar(512)
--	,Edit_Action_2 varChar(255)
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
--		,SJ001.Edit_Action
--		/*
		,Edit_Action = 
		(	
			case SJ001.Edit_Action
				when ' F' then 'Finalise'
				when ' A' then 'Add_Activity'
				when ' StartEnd' then 'Edit_StartEnd'
				when ' OS' then 'SignOn'
				when ' OU' then 'Edit_Actuals'
				when ' Start' then 'Edit_Start'
				else SJ001.Edit_Action
				end
		) 
--			*/
		,SJ001.Activity_Date
		,Cast(SJ001.Start_Time as Datetime)'Start_Time'
		,Cast(SJ001.End_Time as DateTime)'End_Time'
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
			,DateAdd(MINUTE,@TimezoneOffset ,cast(WI_EL_C.Device_Timestamp as datetime))'Device_Timestamp'
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
			and cast(Z.Device_Timestamp as date) between dateadd(day,@EventBracket1,@date_Start) and dateadd(day,@EventBracket2,@date_End)
			and Z.Provider_ID in (Select p.Provider_ID from @Provs p)
		)WI_EL_C
		Inner Join @Provs Provs on Provs.Provider_ID = WI_EL_C.Provider_ID
	)SJ001
	where
		1=1
		and SJ001.Activity_Date between @date_Start and @date_End
	Order by
	1,2,3

select * from @RawResult
--/*

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--Process results to generate a joined Edit actions value for Activity Date.
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
Declare @i_RowNum int = 1
Declare @i_MaxRow int = (select top 1 RR.Row_Count from @RawResult RR)
Declare @i_PID int = null
Declare @t_ActivityDate DateTime = null
declare @J_Edit_Action VarChar(255) = null
declare @i_BaseCount int = 1
Declare @i_TriggerFirstTaskEntry int	= 1
Declare @JoinedEdit_Actions table (Provider_ID int, Activity_Date datetime,Joined_Edit_Action VarChar(255))
declare @i_Temp int = 0
declare @VC_PrevEdAct varchar(128)=''
declare @VC_CurEdAct varchar(128)=''

--Start Main processing
while @i_RowNum <= @i_MaxRow
begin
	-----------------------------------------------------------------------------------------------------------
	--Define current provider for current entry
	set @i_PID = (select RR.Provider_ID from @RawResult RR where RR.RowNumber = @i_RowNum)--baseValue setup
	Set @t_ActivityDate = (select RR.Activity_Date from @RawResult RR where RR.RowNumber = @i_RowNum)
	Set @VC_CurEdAct = (select RR.Edit_Action from @RawResult RR where RR.RowNumber = @i_RowNum)

	if @i_BaseCount = 1
	begin
		set @J_Edit_Action = (select RR.Edit_Action from @RawResult RR where RR.RowNumber = @i_RowNum)--Define Edit action (OS,A,OU,StartEnd,F)
		set @VC_PrevEdAct = ''
	end
		
	if @i_BaseCount <> 1 and @VC_PrevEdAct <> @VC_CurEdAct
	begin
		set @J_Edit_Action = @J_Edit_Action + ', ' + (select RR.Edit_Action from @RawResult RR where RR.RowNumber = @i_RowNum)
		set @VC_PrevEdAct = @VC_CurEdAct
	end

	set @i_Temp = @i_BaseCount
	set  @i_BaseCount = @i_Temp + 1
	set @i_Temp = @i_RowNum
	 --Cycle mechanic
--	print @i_RowNum

	-----------------------------------------------------------------------------------------------------------
	--end base setup
	-----------------------------------------------------------------------------------------------------------
	if --Check to see if the provider ID has changed or the task has changed
	(@i_PID <> (select RR.Provider_ID from @RawResult RR where RR.RowNumber = @i_RowNum+1)) 
	or (@t_ActivityDate <> (select RR.Activity_Date from @RawResult RR where RR.RowNumber = @i_RowNum+1)) 
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
	set @i_RowNum = @i_Temp + 1
end
--*/
--select * from @JoinedEdit_Actions
--select * from @RawResult

--/*

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--PrimaryProssessing
Declare @Results table
(
	Provider_ID int
	,ProviderName varchar(128)
	,Activity_Date date
	,StartTime_Raw DateTime
	,StartTime_Alt DateTime
	,EndTime_Raw DateTime
	,EndTime_Alt DateTime
	,LogDuration_Raw int
	,LogDuration_Alt int
	,Diff int
	,editActions VarChar(255)
	,Wi_Record int
	,OldRN int
--	,RemoveFlag int
	,TotalCount int
	,RowNum int
)
insert into @Results
Select 
	*
	,Row_Number() over(partition by null order by TT.Provider_ID,TT.OldRN)'RowNum'
from
(
	Select
		J001.Provider_ID
		,J001.ProviderName
		,J001.Activity_Date
		,J001.FirstTimeStamp 'StartTime_Raw'
		,J001.Start_Time 'StartTime_Alt'
		,J001.LastTimeStamp 'EndTime_Raw'
		,J001.End_Time 'EndTime_Alt'
		,J001.LogDuration_Raw
		,J001.LogDuration_Alt
		,(J001.LogDuration_Raw - J001.LogDuration_Alt)'Diff'
		,J002.Joined_Edit_Action 'editActions'
		,J001.Wi_Record
		,J001.RowNumber 'OldRN'
	--	,J001.RN 'RemoveFlag'
		,Count(J001.Provider_ID) over (partition by null )'TotalCount'
	
	From 
	(
		select
			RR.Provider_ID
			,RR.ProviderName
			,RR.Activity_Date
			,RR.FirstTimeStamp
			,RR.Start_Time
			,RR.LastTimeStamp
			,RR.End_Time
			,RR.Wi_Record
			,RR.RowNumber
			,RR.Edit_Action
			,DateDiff(MINUTE,RR.FirstTimeStamp,RR.LastTimeStamp)'LogDuration_Raw'
			,DateDiff(MINUTE,RR.Start_Time,RR.End_Time)'LogDuration_Alt'
			,ROW_NUMBER()over(Partition by RR.Provider_ID,RR.Activity_Date,RR.Wi_Record order by RR.device_TimeStamp Desc)'RN'
		from @RawResult RR where RR.Start_Time is not null

	)J001

	left outer join @JoinedEdit_Actions J002 on J002.Provider_ID = J001.Provider_ID and J002.Activity_Date = J001.Activity_Date

	where
		1=1
		--and 1 = iif(Count(J001.Provider_ID) over (partition by null ) > 2 and J001.End_Time is not null,1,0)
		and 1= iif(J001.RN < 2 or J001.RN Is null,1,0)
--/*
)TT
--/*
--/*
Group by
	TT.Provider_ID
	,TT.ProviderName
	,TT.Activity_Date
	,TT.StartTime_Raw
	,TT.StartTime_Alt
	,TT.EndTime_Raw
	,TT.EndTime_Alt
	,TT.LogDuration_Raw
	,TT.LogDuration_Alt
	,TT.Diff
	,TT.editActions
	,TT.Wi_Record
	,TT.OldRN
--	,TT.RemoveFlag
	,TT.TotalCount
--*/
order by
	TT.Provider_ID
	,TT.OldRN
--*/
--select * from @Results

--/*
--this next section is to handle split shifts as they show up with a void end time that has to be removed and the count + rowNumber re calculated.
Declare @Results_Filtered table
(
	Provider_ID int
	,ProviderName varchar(128)
	,Activity_Date date
	,StartTime_Raw DateTime
	,StartTime_Alt DateTime
	,EndTime_Raw DateTime
	,EndTime_Alt DateTime
	,LogDuration_Raw int
	,LogDuration_Alt int
	,Diff int
	,editActions VarChar(255)
	,Wi_Record int
	,OldRN int
--	,RemoveFlag int
	,TotalCount int
	,RowNum int
)
insert into @Results_Filtered
select
	RF.Provider_ID
	,RF.ProviderName
	,RF.Activity_Date
	,RF.StartTime_Raw
	,RF.StartTime_Alt
	,RF.EndTime_Raw
	,RF.EndTime_Alt
	,RF.LogDuration_Raw
	,RF.LogDuration_Alt
	,RF.Diff
	,RF.editActions
	,RF.Wi_Record
	,RF.OldRN
	--,OT.TotalCount
	--,OT.RowNum
	,count(RF.Provider_ID)over(partition by null)'TotalCount'
	,ROW_NUMBER()Over(partition by null order by RF.RowNum)'RowNum'
From
(
	select * from
	(
		select
		*
		,Count(R.Provider_ID)over(partition by R.Provider_ID, R.Activity_Date)'EntryCount'
		From @Results R
	)OT--OUT table for filtering
	where
	1=1
	and 1 = iif (OT.EntryCount > 2 and OT.EndTime_Alt is null,0,1)
)RF --Results Filtered

--select * from @Results_Filtered
--*/


--/*
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--POST PROCESSING
--Process @RawResult
--	Identify SplitShifts and process
--	Identify Minor edits of same task and select Last edit.
--	Flags for scenarios --split shift, ShortLogin at start/at end, Not Finalised.

set @i_RowNum = 1
set @i_MaxRow = (select top 1 R.TotalCount from @Results_Filtered R)
set @i_BaseCount = 1
set @i_TriggerFirstTaskEntry = 0
set @i_Temp = 0
Declare @i_RemoveFlag int = 1
Declare @i_NextRemoveFlag int = 0
Declare @dt_ForceStart DateTime = null
Declare @dt_ForceEnd DateTime = null
--packValues
set @i_PID = null
Declare @vc_ProviderName varchar(128)
Declare @dt_ActivityDate date = null
Declare @dt_StartTime_Raw DateTime = null
Declare @dt_StartTime_Alt DateTime = null
Declare @dt_EndTime_Raw DateTime = null
Declare @dt_EndTime_Alt DateTime = null
declare @i_StartTime_Diff int = null
Declare @i_LogDuration_Raw int = null
Declare @i_LogDuration_Alt int = null
Declare @i_Diff int = null
declare @vc_Edit_Actions varchar(255)= null
declare @Wi_Record int = null
declare @vc_Comment varchar(128) = null

Declare @PostProcessed table (
	Provider_ID int--
	,ProviderName varchar(128)--
	,Activity_Date date
	,StartTime_Raw DateTime
	,StartTime_Alt DateTime
	,EndTime_Raw DateTime
	,EndTime_Alt DateTime
	,StartTime_Diff int
	,LogDuration_Raw int
	,LogDuration_Alt int
	,Diff int
	,editActions VarChar(255)
	,Wi_Record int
--	,Comment VarChar(128)
)
--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
while @i_RowNum <= @i_MaxRow
begin
	------------------------
	--Pack Current Row Values
	set @i_PID = (select R.Provider_ID from @Results_Filtered R where R.RowNum = @i_RowNum)--baseValue setup
	set @vc_ProviderName = (select R.ProviderName from @Results_Filtered R where R.RowNum = @i_RowNum)
	Set @dt_ActivityDate = (select R.Activity_Date from @Results_Filtered R where R.RowNum = @i_RowNum)
	Set @dt_StartTime_Raw = (select R.StartTime_Raw from @Results_Filtered R where R.RowNum = @i_RowNum)
	Set @dt_StartTime_Alt = (select R.StartTime_Alt from @Results_Filtered R where R.RowNum = @i_RowNum)
	Set @dt_EndTime_Raw = (select R.EndTime_Raw from @Results_Filtered R where R.RowNum = @i_RowNum)
	Set @dt_EndTime_Alt = (select R.EndTime_Alt from @Results_Filtered R where R.RowNum = @i_RowNum)
	set @i_StartTime_Diff = DATEDIFF(MINUTE,@dt_StartTime_Raw,@dt_StartTime_Alt)
	Set @i_LogDuration_Raw = (select R.LogDuration_Raw from @Results_Filtered R where R.RowNum = @i_RowNum)
	Set @i_LogDuration_Alt = (select R.LogDuration_Alt from @Results_Filtered R where R.RowNum = @i_RowNum)
	Set @i_Diff = (select R.Diff from @Results_Filtered R where R.RowNum = @i_RowNum)
	Set @vc_Edit_Actions = (select R.editActions from @Results_Filtered R where R.RowNum = @i_RowNum)
	Set @Wi_Record = (select R.Wi_Record from @Results_Filtered R where R.RowNum = @i_RowNum)
	-----------------------------------------------------------------------------------------------------------
	
	if @Wi_Record is null
	begin
	Set @Wi_Record = 0
	end
	-----------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------
	--Process Removeflag
	if @i_NextRemoveFlag = 1 --skip next for split shift detected and processed
	begin

		set @i_NextRemoveFlag = 0
	end
	else
	begin
		set @i_RemoveFlag = 1
	end
	-----------------------------------------------------------------------------------------------------------
	--Process 
	-----------------------------------------------------------------------------------------------------------
	if --prossess Split shift
		@i_PID = (select R.Provider_ID from @Results_Filtered R where R.RowNum = @i_RowNum+1)
		and @Wi_Record <> (select R.Wi_Record from @Results_Filtered R where R.RowNum = @i_RowNum+1)
		and @dt_ActivityDate = (select R.Activity_Date from @Results_Filtered R where R.RowNum = @i_RowNum+1)
		begin
			set @dt_EndTime_Alt = (select R.EndTime_Alt from @Results_Filtered R where R.RowNum = @i_RowNum+1)
			set @i_LogDuration_Alt = DateDiff(Minute,@dt_StartTime_Alt,@dt_EndTime_Alt)
			set @i_Diff = (@i_LogDuration_Raw - @i_LogDuration_Alt)
			set @i_NextRemoveFlag = 1
			set @Wi_Record = (select R.Wi_Record from @Results_Filtered R where R.RowNum = @i_RowNum+1)
		end
	-----------------------------------------------------------------------------------------------------------
	--Process output
	-----------------------------------------------------------------------------------------------------------
	if --Check Flags and conditions for Pack results
		--(@i_PID <> (select R.Provider_ID from @@Results_Filtered R where R.RowNum = @i_RowNum+1)) 
		(@dt_ActivityDate <> (select R.Activity_Date from @Results_Filtered R where R.RowNum = @i_RowNum+1)) 
		or (@i_RowNum = @i_MaxRow and @i_RemoveFlag < 2)
		or @i_RemoveFlag < 2
	begin
		set @i_TriggerFirstTaskEntry = 1
	end

	--------------------------------------------------------------------------------------------------------------------------
	--Pack results
	if @i_TriggerFirstTaskEntry = 1 
	begin
		insert into @PostProcessed Values 
		( 
			@i_PID
			,@vc_ProviderName
			,@dt_ActivityDate
			,@dt_StartTime_Raw
			,@dt_StartTime_Alt
			,@dt_EndTime_Raw
			,@dt_EndTime_Alt
			,@i_StartTime_Diff
			,@i_LogDuration_Raw
			,@i_LogDuration_Alt
			,@i_Diff
			,@vc_Edit_Actions
			,@Wi_Record
--			,@vc_Comment
		)
		set @i_TriggerFirstTaskEntry = 0
		set @vc_Comment = null
	end --End Pack results

	--------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------
	if @i_NextRemoveFlag = 1 --skip next for split shift detected and processed
	begin
		set @i_RemoveFlag = 2
	end
	--------------------------------------------------------------------------------------------------------------------------
	--Trip next row processing
	set @i_Temp = @i_RowNum
	set @i_RowNum = @i_Temp + 1
	--------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------
end--end process
---------------------------------------------------------------------

select * from @PostProcessed
--*/

