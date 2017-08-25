
/*
----------------------------------
	Centre's
----------------------------------
	Transitional Care Program
	Home Care West
	Allied Health Services
	Home Care South
	Exceptional Needs
	Home Care North
	Disabilities Children
	Home Care East
	Home Care Barossa Yorke Peninsula
	Disabilities Adult
	AnglicareSA Corporate Office
	Dutton Court --has buddy team
	All Hallows Court
	Canterbury Close
	Ian George Court
	St Laurences Court
	Grandview Court
	Anglicaresa Oats
	----------------------------------
	Provider Class Codes
	----------------------------------
	ADM   
	CK1   
	CK2   
	EN    
	HW    
	LA    
	LE    
	MGR   
	MN    
	PCW   
	RC    
	RN    
	RNIC  
	TL    

	select top 1 * from dbo.wi_activity
	where cast(schedule_time as datetime) = '2017-04-04 09:42:00.000'
	--*/

--test settings

declare @stringDate varchar(32) = '2017-04-04'
declare @stringDate2 varchar(32) = '2017-04-17'--'2017-01-20'
declare @Start_Date date = convert(date, @stringDate)
declare @End_Date date = convert(date, @stringDate2)
declare @Centre varchar(32) = 'Dutton Court'
declare @ShowVacantOnly int = 1
declare @NoBuddyShifts int = 1
declare @hideUnAss int = 0
declare @ClassCodeFilter VarChar(8)= 'HW'
declare @TeamFilt VarChar(128) = 'Buddy Team'
declare @SortBy VarChar(32) = 'StartTime'
--------------------------------------------------------------
--------------------------------------------------------------

--Setup Vars and Defults.
declare @date_Start date = @Start_Date
declare @date_End date = @End_Date

--Create DateRange and set start of week
SET DATEFIRST 1

---------------------------
--Main quiry
---------------------------
Select * from 
(
	select
		J004.Description 'Team'
		,J003.Generated_Provider_Code 'ServiceProvision'
		,J003.Provider_Class_Code
		,J007.Description 'Provider_Class'
		,(
			Case
				when DatePart(dw, cast(J001.Schedule_StartTime as date)) = 1 then 'Monday'
				when DatePart(dw, cast(J001.Schedule_StartTime as date)) = 2 then 'Tuesday'
				when DatePart(dw, cast(J001.Schedule_StartTime as date)) = 3 then 'Wednesday'
				when DatePart(dw, cast(J001.Schedule_StartTime as date)) = 4 then 'Thursday'
				when DatePart(dw, cast(J001.Schedule_StartTime as date)) = 5 then 'Friday'
				when DatePart(dw, cast(J001.Schedule_StartTime as date)) = 6 then 'Saturday'
				when DatePart(dw, cast(J001.Schedule_StartTime as date)) = 7 then 'Sunday'
			end
		) 'DayOfWeek'
		,J001.Activity_Date 'Activity_Date'
		,J001.Schedule_StartTime 'StartTime'
		,J001.Schedule_Duration 'Duration'
		,J001.Schedule_EndTime 'EndTime'
		,J001.Provider_ID
		,J001.Absence_Code
		,IIF --defines if the round is filled.
		(
			J001.Provider_ID!=0 and J001.Absence_Code is null
			,'True'
			,'False'
		) 'Coverage'
		,(J002.Last_Name + ', ' + J002.Preferred_Name) 'ProviderName'

		--DeBug Info.
--		/*
		,J003.Service_Prov_Position_ID 'SPPID'
		,J001.RN
		--*/
		--END DeBug Info.

	From 
	(
		Select
			WiA.SPPID 'SPPID'
			,cast (WiA.Activity_Date as date) 'Activity_Date'
			,cast (WiA.Schedule_Time as datetime) 'Schedule_StartTime'
			,DateAdd(MINUTE, WiA.Schedule_Duration,cast(WiA.Schedule_Time as datetime))'Schedule_EndTime'
			,WiA.Absence_Code 'Absence_Code'
			,WiA.Provider_ID 'Provider_ID'
			,WiA.Schedule_Duration 'Schedule_Duration'
			,WiA.Generated_Provider_Code 'Generated_Provider_Code'
			,ROW_NUMBER () -- sort by importance of 'covered' 'absent' and 'Un-Alocated'.
				over 
				(
					Partition by cast(WiA.Schedule_Time as Datetime), WiA.SPPID Order by 
						Case
							when ((WiA.Provider_ID > 0) and (WiA.Absence_Code is NULL)) then concat('1_',WiA.Provider_ID)
							when (WiA.Provider_ID > 0) and (WiA.Absence_Code is not NULL) then concat('2_',WiA.Provider_ID)
						else 'z'
					end
				) 'RN'
		From dbo.Wi_Activity WiA
		where convert(date, Wia.Activity_Date) between dateadd(day,-7,@Start_Date) and dateadd(day,7,@End_Date)
	)J001

	Left Outer Join dbo.Person J002 on J002.Person_ID = J001.Provider_ID
	Left outer join dbo.Service_Provision_Position J003 on J003.Service_Prov_Position_ID = J001.SPPID
	Left outer join dbo.Service_Delivery_Work_Team J004 on J004.Team_No = J003.Team_No and J004.Centre_ID = J003.Centre_ID
	Left outer join dbo.Organisation J005 on J005.Organisation_ID = J004.Centre_ID
	Left outer join dbo.Service_Provision_Allocation J006 on J006.Service_Prov_Position_ID = J003.Service_Prov_Position_ID
	Left outer join dbo.Provider_Classification J007 on J007.Provider_Class_Code = J003.Provider_Class_Code


	where
		1=1
		and J001.RN < 2
		and J001.Schedule_Duration is not null
		and J001.Activity_Date between @date_Start and @date_End
		and J005.Organisation_Name = @Centre
		and J003.Provider_Class_Code in (@ClassCodeFilter)
		and 1 = IIF --Hide Buddy shifts
				(
					J004.Description Like '%uddy%'
					,@NoBuddyShifts
					,1
				)
		and 1 = IIF --Hide un allocated shifts
				(
					J001.Provider_ID=0
					,@hideUnAss
					,1
				)
		and J004.Description in (@TeamFilt)
	----------------------
	--	Debug filters	--
	----------------------
--		and J003.Generated_Provider_Code = 'HW-RES-DC2413-2'
--		and J003.Generated_Provider_Code = 'LA-RES-DCD11-2'
--		and J003.Generated_Provider_Code = 'CK1-RES-DC7D7-1'
	--	and J002.Description = 'Giles'
	--	and J003.Generated_Provider_Code = 'PCW-RES-SL7V7-4'
	--	and J003.Generated_Provider_Code = 'PCW-RES-AH7V5-2'
	--	and J003.Generated_Provider_Code = 'LA-RES-CC7D11-7'
) as T1

group by 
	T1.Team
	,T1.ServiceProvision
	,T1.Provider_Class_Code
	,T1.Provider_Class
	,t1.DayOfWeek
	,t1.Activity_Date
	,t1.StartTime
	,t1.Duration
	,t1.EndTime
	,t1.Provider_ID
	,t1.Absence_Code
	,t1.Coverage
	,t1.ProviderName

	--DeBug Info.
--	/*
	,t1.SPPID
	,t1.RN
--*/

order by
	t1.Activity_Date
	,Case
		when @SortBy = 'StartTime' then cast(cast(t1.StartTime as time) as varchar(128))
		When @SortBy = 'ProviderName' then cast(t1.ProviderName as varchar(128))
		When @SortBy = 'Team_ClassCode' then cast(T1.ServiceProvision as varchar(128))
		end
	,Case
		when @SortBy = 'StartTime' then cast(t1.ProviderName as varchar(128))
		When @SortBy = 'ProviderName' then cast(cast(t1.StartTime as time) as varchar(128))
		When @SortBy = 'Team_ClassCode' then cast(T1.Provider_Class_Code as varchar(128))
		end

--reset of defults
SET DATEFIRST 7
