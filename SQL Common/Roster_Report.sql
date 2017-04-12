use ComCareProd
/*
ReStructured
select * from [dbo].Provider_Payroll_Options
[appsql-3\TRAIN].[ComCareTRAIN]
[APPSQL-3\COMCAREPROD].[comcareprod]
----------------------------------
----------------------------------
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
	----------------------------------
	----------------------------------
	----------------------------------
=IIF
(
	Fields!Coverage.Value = "True"
	,"No Color"
	,IIF
	(
		IsNothing(Fields!Absence_Code.Value)
		,"#B3CEEA"
		,"#92B8DE"
	)

)


	--*/

--------------------------------------------------------------
--------------------------------------------------------------
--test settings

declare @stringDate varchar(32) = '2017-02-13'
declare @stringDate2 varchar(32) = '2017-02-26'--'2017-01-20'
declare @Start_Date date = convert(date, @stringDate)
declare @End_Date date = convert(date, @stringDate2)
declare @Centre varchar(32) = 'Dutton Court'
declare @ShowVacantOnly int = 0
declare @NoBuddyShifts int = 1
declare @hideUnAss int = 1
declare @ClassCodeFilter VarChar(8)= 'HW'
declare @TeamFilt VarChar(128) = 'Buddy Team'
--------------------------------------------------------------
--------------------------------------------------------------
--------------------------------------------------------------
--------------------------------------------------------------
--------------------------------------------------------------
--------------------------------------------------------------
--------------------------------------------------------------
--Setup Vars and Defults.
declare @date_Start date = @Start_Date
declare @date_End date = @End_Date


--Create DateRange --FORCE RESET

SET DATEFIRST 7


--Create DateRange and set start of week
SET DATEFIRST 1
Declare @temp table 
(
	date_seq date
	,Day_of_week int
)

while @date_Start <= @date_End

begin
	insert into @temp values (@date_Start, DATEPART(dw,@date_Start))
	 set @date_Start = DATEADD(dd, 1, @date_Start)
end
---------------------------
--Main quiry
---------------------------
select
	J002.[Description] 'Team'
	,J003.[Generated_Provider_Code] 'ServiceProvision'
	,J003.[Provider_Class_Code]
	,J008.[Description] 'Provider_Class'
	,IIF
	(
		J004.[Working_Week_No] is NOT NULL
		,J005.[DayOfWeek]
		,J009.[DayOfWeek]
	) 'DayOfWeek'
	,J010.[date_seq] 'Activity_Date'
	--/*
	,IIF
		(
			J006.[Provider_ID] is not null
			, convert 
			(
				DateTime
				,IIF
				(	J004.[Working_Week_No] is NOT NULL --and J002.[Description] not like '%uddy%'
					,J005.[StartTime]
					,J009.[StartTime]
				)
			)
			, NULL
		) 'StartTime'
	--*/
	--,J006. 'Activity_Start_Time'
	,IIF
	(
		J006.[Provider_ID] is not null
		,IIF
		(
			J004.[Working_Week_No] is NOT NULL
			,IIF (J005.[duration]> 5.0, J005.[duration] - 0.5, J005.[duration])
			,IIF (J009.[duration]> 5.0, J009.[duration] - 0.5, J009.[duration])
		)
		, NULL
	) 'Duration'
	,IIF
	(
		J006.[Provider_ID] is not null
		,convert
		(
			DateTime
			,DateAdd
			(
				Minute
				,IIF(J004.[Working_Week_No] is NOT NULL,J005.[duration],J009.[duration])*60
				,IIF(J004.[Working_Week_No] is NOT NULL,J005.[StartTime],J009.[StartTime])
			)
		)
		,NULL
	) 'EndTime'
	,J006.[Provider_ID]
	,J006.[Absence_Code]
	,IIF --defines if the round is filled.
	(
		(J005.[duration] is not null and J006.[Provider_ID] is not null and J004.[Working_Week_No] is NOT NULL)
		or( J009.[duration] is not null and J006.[Provider_ID] is not null and J004.[Working_Week_No] IS NULL)
		,IIF
		(
			J006.[Provider_ID]!=0 and J006.[Absence_Code] is null
			,'True'
			,'False'
		)
		, NULL
	) 'Coverage'
--	,(J007.[Preferred_Name] + ' ' + J007.[Last_Name]) as 'ProviderName'
	,(J007.[Last_Name] + ', ' + J007.[Preferred_Name]) as 'ProviderName'
	,J050.Employee_Status_Code
	--DeBug Info.
--	/*
	,J003.[Service_Prov_Position_ID] 'SPPID'
	,J006.[RN]
	,J004.[Working_Week_No]
--	,J006.[Creation_Date]
--	,J006.[Activity_Start_Time]
	--*/
	--END DeBug Info.

from [dbo].[Organisation] J001
inner join [dbo].[Service_Delivery_Work_Team] J002 on J002.[Centre_ID] = J001.[Organisation_ID]
left outer join [dbo].[Service_Provision_Position] J003 on J003.[Centre_ID] = J002.[Centre_ID] and J003.[Team_No] = J002.[Team_No]
Left outer join [dbo].[Service_Provision_Allocation] J004 on J004.[Service_Prov_Position_ID] = J003.[Service_Prov_Position_ID]
inner join [dbo].[Provider_Classification] J008 on J008.[Provider_Class_Code] = J003.[Provider_Class_Code]

Left outer join
(
	select
		tmp.[date_seq] as 'date_seq'
		,WW.[Working_Week_No] as 'Working_Week_No'
		,Case
			when tmp.[Day_of_week] = 1 then WW.[Monday_Duration]
			when tmp.[Day_of_week] = 2 then WW.[Tuesday_Duration]
			when tmp.[Day_of_week] = 3 then WW.[Wednesday_Duration]
			when tmp.[Day_of_week] = 4 then WW.[Thursday_Duration]
			when tmp.[Day_of_week] = 5 then WW.[Friday_Duration]
			when tmp.[Day_of_week] = 6 then WW.[Saturday_Duration]
			when tmp.[Day_of_week] = 7 then WW.[Sunday_Duration]
		end as 'duration'
		,Case
			when tmp.[Day_of_week] = 1 then WW.[Monday_Start]
			when tmp.[Day_of_week] = 2 then WW.[Tuesday_Start]
			when tmp.[Day_of_week] = 3 then WW.[Wednesday_Start]
			when tmp.[Day_of_week] = 4 then WW.[Thursday_Start]
			when tmp.[Day_of_week] = 5 then WW.[Friday_Start]
			when tmp.[Day_of_week] = 6 then WW.[Saturday_Start]
			when tmp.[Day_of_week] = 7 then WW.[Sunday_Start]
		end as 'StartTime'
		,Case
			when tmp.[Day_of_week] = 1 then 'Monday'
			when tmp.[Day_of_week] = 2 then 'Tuesday'
			when tmp.[Day_of_week] = 3 then 'Wednesday'
			when tmp.[Day_of_week] = 4 then 'Thursday'
			when tmp.[Day_of_week] = 5 then 'Friday'
			when tmp.[Day_of_week] = 6 then 'Saturday'
			when tmp.[Day_of_week] = 7 then 'Sunday'
		end as 'DayOfWeek'

	From [dbo].[Working_Week] WW	
	left outer join @temp tmp on 1=1

)J005 on J005.[Working_Week_No] = J004.[Working_Week_No] and J004.[Working_Week_No] is NOT NULL

Left outer join
(
	select
		tmp.[date_seq] as 'date_seq'
		,Sh.[Shift_Code] as 'Shift_Code'
		,Sh.[Shift_Duration] 'duration'
		,Sh.[Shift_Start] 'StartTime'
		,iif(1=1, Null, 1) 'forceNull'
		,Case
			when tmp.[Day_of_week] = 1 then 'Monday'
			when tmp.[Day_of_week] = 2 then 'Tuesday'
			when tmp.[Day_of_week] = 3 then 'Wednesday'
			when tmp.[Day_of_week] = 4 then 'Thursday'
			when tmp.[Day_of_week] = 5 then 'Friday'
			when tmp.[Day_of_week] = 6 then 'Saturday'
			when tmp.[Day_of_week] = 7 then 'Sunday'
		end as 'DayOfWeek'
	from [dbo].[Shift] Sh
	left outer join @temp tmp on 1=1
	where
		1=1
		and 1 = Case
					when tmp.[Day_of_week] = 1 and Monday_Indicator = 1 then 1
					when tmp.[Day_of_week] = 2 and Tuesday_Indicator = 1 then 1
					when tmp.[Day_of_week] = 3 and Wednesday_Indicator = 1 then 1
					when tmp.[Day_of_week] = 4 and Thursday_Indicator = 1 then 1
					when tmp.[Day_of_week] = 5 and Friday_Indicator = 1 then 1
					when tmp.[Day_of_week] = 6 and Saturday_Indicator = 1 then 1
					when tmp.[Day_of_week] = 7 and Sunday_Indicator = 1 then 1
				end
		
)J009 on J009.[Shift_Code] = J003.[Shift_Code] and J004.[Working_Week_No] Is null

Left Outer Join 
(
	Select
		WiA.[SPPID] 'SPPID'
		,WiA.[Activity_Date] 'Activity_Date'
		,WiA.[Creation_Date] 'Creation_Date'
		,WiA.[Activity_Start_Time] 'Activity_Start_Time'
		,WiA.Schedule_Time 'Schedule_Time'
		,WiA.Activity_End_Time ' '
		,WiA.[Absence_Code] 'Absence_Code'
		,WiA.[Provider_ID] 'Provider_ID'
		,ROW_NUMBER () -- sort by importance of 'covered' 'absent' and 'Un-Alocated'.
			over 
			(
				Partition by WiA.[Activity_Date], WiA.[SPPID] Order by 
					Case
						when ((WiA.[Provider_ID] > 0) and (WiA.[Absence_Code] is NULL)) then '300'
						when (WiA.[Provider_ID] > 0) and (WiA.[Absence_Code] is not NULL) then '200'
					else '1'
				end Desc
			) AS 'RN'
	From [dbo].[Wi_Activity] WiA

)J006 on J006.[SPPID] = J003.[Service_Prov_Position_ID] and (J006.[Activity_Date] = J005.[date_seq] or J006.[Activity_Date] = J009.[date_seq])

Left Outer Join [dbo].[Person] J007 on J007.[Person_ID] = J006.[Provider_ID]

Left Outer Join
(
	select
		tmp.[date_seq] as 'date_seq'
	From @temp tmp

)J010 on (J010.[date_seq] = J005.[date_seq] and J004.[Working_Week_No] is NOT NULL) or (J010.[date_seq] = J009.[date_seq] and J004.[Working_Week_No] IS NULL)

Left outer join [dbo].Team_Position J011 on J011.[Service_Prov_Position_ID] = J003.[Service_Prov_Position_ID]
Left outer join [dbo].Provider_Payroll_Options J050 on J050.Provider_ID = J006.Provider_ID

where
	1=1
	and J001.[Organisation_Name] = @Centre
	and J003.[Provider_Class_Code] in (@ClassCodeFilter)
	and J002.[Effective_Date_to] is null --Team still active
	and J003.[Position_Closed_Date] is null
	and J011.Effective_Date_To is Null
	and J004.[To_Date] is null
	and (J006.[RN] < 2 or J006.[RN] is NULL)
	and 1 = IIF -- show only not covered shifts
			(
				(J005.[duration] is null and J004.[Working_Week_No] is not null)
				or (J009.[duration] is null and J004.[Working_Week_No] is null)
				or J006.[Provider_ID] is null
				,@ShowVacantOnly
				,IIF(J006.[Provider_ID]!=0 and J006.[Absence_Code] is null, @ShowVacantOnly, 1)
			)
	and 1 = IIF --Hide Buddy shifts
			(
				J002.[Description] Like '%uddy%'
				,@NoBuddyShifts
				,1
			)
	and 1 = IIF --Hide un allocated shifts
			(
				J006.[Provider_ID]=0
				,@hideUnAss
				,1
			)
	and J002.Description in (@TeamFilt)
----------------------
--	Debug filters	--
----------------------
--	and J004.[Working_Week_No] is NULL
--	and J002.[Description] = 'Giles'
--	and J003.[Generated_Provider_Code] = 'PCW-RES-SL7V7-4'
--	and J003.[Generated_Provider_Code] = 'PCW-RES-AH7V5-2'
--	and J003.[Generated_Provider_Code] = 'LA-RES-CC7D11-7'

order by
	J002.[Description]
	,J010.date_seq

--reset of defults, kill temp table.
If(OBJECT_ID('tempdb.dbo.#temp') Is Not Null)
Begin
    Drop Table #Temp
End
SET DATEFIRST 7

--select * From [dbo].[Wi_Activity] 