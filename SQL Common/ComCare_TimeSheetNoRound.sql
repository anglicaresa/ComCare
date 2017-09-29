declare @StartDate date = '2017-09-13'
declare @EndDate date = '2017-08-13'

--select * from dbo.Service_Provision_Position
--declare @Centre varchar(32) = 'Dutton Court'
--declare @Centre varchar(32) = 'Ian George Court'
--declare @Centre Varchar(32) = 'All Hallows Court'
--declare @Centre Varchar(32) = 'St Laurences Court'
--declare @Centre Varchar(32) = 'Canterbury Close'
declare @Centre Varchar(32) = 'Grandview Court'
/*
Select Organisation_Name from dbo.Organisation 
	where 
	Organisation_Type_Code = 1
	and
	(
		Organisation_Name like 'Home Care%'
		or Organisation_Name like 'Disabilities %'
		or Organisation_ID between 49 and 54
	)
Order by
Case 
	when Organisation_Name like 'Home Care%' then '1_'+ Organisation_Name
	when Organisation_Name like 'Disabilities %' then '2_'+ Organisation_Name
	when Organisation_ID between 49 and 54 then '3_'+ Organisation_Name
end
*/
--------------------------------------------------------------------------------------------------
declare @ProvIDs_1 Table (Provider_ID int, ContractType VarChar(64),Provider_Class_Code VarChar(128))
insert into @ProvIDs_1
Select
	J001.Provider_ID
	,J003.ContractType
	,J003.Provider_Class_Code
From dbo.Provider_Contract J001
Inner join dbo.Organisation J002 on J002.Organisation_ID = J001.Organisation_ID
Left outer join
(
	select
	PC.Provider_ID
	,PC.Provider_Contract_Type_Code
	,PC.Provider_Class_Code
	,CT.Description 'ContractType'
	,ROW_NUMBER()over(Partition by PC.Provider_ID Order by Case
		When PC.Provider_contract_Type_code = 1 and PC.Effective_Date_To is null then '1'
		When PC.Provider_contract_Type_code = 1 and PC.Effective_Date_To > @StartDate then '2'
		when PC.Provider_contract_Type_code = 1 and PC.Effective_Date_From < @EndDate then '3'
		else '4'
		end
		)'RN'
	from dbo.Provider_Contract PC
	left outer Join dbo.Provider_Contract_Type CT on CT.Provider_Contract_Type_Code = PC.Provider_Contract_Type_Code
	where
		1=1
)J003 on J003.Provider_ID = J001.Provider_ID and J003.RN < 2
where
	1=1
	and J002.Organisation_Name in (@Centre)

--select * from @ProvIDs_1
--------------------------------------------------------------------------------------------------

Declare @NoRoundCodeTable Table
(
	Provider_ID int
	,ProviderName VarChar (128)
	,ContractType VarChar(64)
	,Provider_Class_Code VarChar(128)
	,Activity_Date Date
	,Activity_Start_Time DateTime
	,Activity_End_Time DateTime
	,MidActivity_Time DateTime
	,Activity_Duration int
	,ActivityType VarChar(16)
	,ActivityDescription VarChar(128)
	,ActivityCode VarChar(64)
	,TryMatch int
)
insert into @NoRoundCodeTable
Select
	J001.Provider_ID
	,(J005.Last_Name + ', ' + J005.Preferred_Name) 'ProviderName'
	,J004.ContractType
	,J004.Provider_Class_Code
	,Cast(J001.Activity_Date as date)'Activity_Date'
	,Cast(J001.Activity_Start_Time as datetime)'Activity_Start_Time'
	,Cast(J001.Activity_End_Time as datetime)'Activity_End_Time'
	,Cast(DateAdd(Minute,J001.Activity_Duration/2,J001.Activity_Start_Time) as datetime)'MidActivity_Time'
	,J001.Activity_Duration
	,IIF(J001.Indirect_Activity_Type_Code is null,'Task','IndirectActivity')'ActivityType'
	,IIF(J001.Indirect_Activity_Type_Code is null,J003.Description,J002.Description) 'ActivityDescription'
	,IIF(J001.Indirect_Activity_Type_Code is null,J001.Task_Type_code,J001.Indirect_Activity_Type_Code)'ActivityCode'
	,IIF
	(	
		J002.Description like '%Start Shift%'
		or J001.Indirect_Activity_Type_Code is null 
		,1,0
	)'TryMatch'
from dbo.Activity_Work_Table J001
Left outer join dbo.Indirect_Activity_Type J002 on J002.Indirect_Activity_Type_Code = J001.Indirect_Activity_Type_Code
Left outer Join dbo.Task_Type J003 on J003.Task_Type_Code = J001.Task_Type_Code
inner join @ProvIDs_1 J004 on J004.Provider_ID = J001.Provider_ID
inner join dbo.Person J005 on J005.Person_ID = J001.Provider_ID

where 
	1=1
	and Cast(J001.Activity_Date as date) between @StartDate and @EndDate
	and (J001.Classn_Shift_Centre is null or J001.Classn_Shift_Centre = '')
	and J001.Activity_Start_Time is not null 
	and J001.Activity_End_Time is not null
Order by
1,2,3
--Select * from @NoRoundCodeTable
--/*
--------------------------------------------------------------------------------------------------
declare @Provs_Roster Table
(
	Provider_ID int
	,ProviderName varChar(128)
	,Activity_Date Date
	,Schedule_StartTime DateTime
	,Schedule_EndTime DateTime
	,Schedule_Duration int
	,SPPID int
	,RoundCode varChar(128)
)

insert into @Provs_Roster
Select Distinct
	X001.Provider_ID
	,(X002.Last_Name + ', ' + X002.Preferred_Name) 'ProviderName'
	,X001.Activity_Date
	,X001.Schedule_StartTime
	,X001.Schedule_EndTime
	,X001.Schedule_Duration
	,X001.SPPID
	,X003.Generated_Provider_Code 'RoundCode'
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
						when ((WiA.Provider_ID > 0) and (WiA.Absence_Code is NULL)) then concat('1_',WiA.Provider_ID)
						when (WiA.Provider_ID > 0) and (WiA.Absence_Code is not NULL) then concat('2_',WiA.Provider_ID)
					else 'z'
				end
			) 'RN'
	From dbo.Wi_Activity WiA
	inner join @ProvIDs_1 PID on PID.Provider_ID = WiA.Provider_ID
	where
		1=1
		and convert(date, Wia.Activity_Date) between @StartDate and @EndDate
		and WiA.SPPID is not null
)X001
Inner Join dbo.Person X002 on X002.Person_ID = X001.Provider_ID --get prov name
Inner Join dbo.Service_Provision_Position X003 on X003.Service_Prov_Position_ID = X001.SPPID
Inner join dbo.Service_Delivery_Work_Team X004 on X004.Team_No = X003.Team_No and X004.Centre_ID = X003.Centre_ID

where
	1=1
	and X001.Absence_Code is null
	and X001.RN < 2
	and X001.Schedule_Duration is not null
	and cast(X001.Activity_Date as date) between @StartDate and @EndDate
--	and X008.Provider_Contract_Type_Code = 1

order by
	1,3,4	

--Select * from @Provs_Roster

--------------------------------------------------------------------------------------------------
--*/
Select
J001.Provider_ID
,J001.ProviderName
,J001.ContractType
,J001.Provider_Class_Code
,J001.Activity_Date
,J001.Activity_Start_Time
,J001.Activity_End_Time
,J001.Activity_Duration
,J001.ActivityType
,J001.ActivityCode
,J001.ActivityDescription
,STUFF
(
	(
		Select
		', '+J002.RoundCode
		From @Provs_Roster J002 where
		J002.Provider_ID = J001.Provider_ID
		and J002.Activity_Date = J001.Activity_Date
		and J001.TryMatch = 1
		and J001.MidActivity_Time between J002.Schedule_StartTime and J002.Schedule_EndTime
		For XML Path ('')
	)
	,1,2,''
)'Possible Round matches'
From @NoRoundCodeTable J001
