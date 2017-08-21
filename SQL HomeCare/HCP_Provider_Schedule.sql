--select * from Organisation where Organisation_Type_code = 1
--select * from dbo.Provider_Classification
--select * from dbo.Provider_Contract

declare @Start_Date date = '2017-08-04'
declare @End_Date date = '2017-08-06'

--select * from dbo.WI_Activity where cast(Activity_Date as date) between @Start_Date and @End_Date and (Internal_Task_Code = 76 or Internal_Task_Code = 71) order by Activity_Date
--declare @Centre varchar(128) = 'Home Care Barossa Yorke Peninsula'
declare @Centre varchar(128) = 'Disabilities Children'
declare @ClassCodeFilter VarChar(8)= 'HW'


--------------------------------------------------------------
--------------------------------------------------------------
Declare @ProvRiskAlert Table (Code int)
insert into @ProvRiskAlert values (2),(3),(6),(8)
--Create DateRange and set start of week
SET DATEFIRST 1

---------------------------
--Main quiry
---------------------------
Select * from 
(
	select
		iif (J005.Organisation_Name is not null, J005.Organisation_Name, Jx002.Organisation_Name) 'Centre'
		,case 
			when J001.Internal_Task_Code = 71 then 'Overnight Respite'
			When J001.Internal_Task_Code = 76 then 'Overnight Respite'
			when J001.Internal_Task_Code = 13 then 'Admin'
			else J004.Description 
			end 'Team'
		,J003.Generated_Provider_Code 'ServiceProvision'
		,iif(J003.Provider_Class_Code is null, Jx001.Provider_Class_code, J003.Provider_Class_Code)'Provider_Class_Code'
		,iif (J001.SPPID = 0 or J001.SPPID is null, Jx003.Description, J007.Description) 'Provider_Class'
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
		,J001.Client_ID
--		,J001.Absence_Code
		,(J002.Last_Name + ', ' + J002.Preferred_Name) 'ProviderName'
		,J012.Client_Name
		,iif(J001.Override_Address_ID <> 0,J013.Client_Address, J012.Client_Address)'Visit_Address'
		,iif(J001.Override_Address_ID <> 0,J013.Access_Comments, J012.Access_Comments)'Access_Comments'
		,J014.Phone 'Client_PH'
		--DeBug Info.
--		/*
		,J003.Service_Prov_Position_ID 'SPPID'
--		,J008.Description 'Task_Type'
		,iif(J001.Event_Type = 18,J009.Description, J008.Description) 'Task_Type'
		,J009.Description 'Internal_Task_Type'
		,J010.Description 'Event_Type'
		,J001.Event_Type 'Event_Type_code'
		,J011.Description 'Group_Activity'
		,iif(J015.Alert_Type_ID is null,0,iif(J015.Alert_Type_ID in(select * from @ProvRiskAlert),2,1))'ClientAlert'
		,J001.RN
		--*/
		--END DeBug Info.

	From 
	(
		Select
			WiA.SPPID 'SPPID'
			,WIA.Client_ID
			,cast (WiA.Activity_Date as date) 'Activity_Date'
			,cast (WiA.Schedule_Time as datetime) 'Schedule_StartTime'
			,DateAdd(MINUTE, WiA.Schedule_Duration,cast(WiA.Schedule_Time as datetime))'Schedule_EndTime'
			,WiA.Absence_Code 'Absence_Code'
			,WiA.Provider_ID 'Provider_ID'
			,WiA.Schedule_Duration 'Schedule_Duration'
			,WiA.Generated_Provider_Code 'Generated_Provider_Code'
			,WiA.Schedule_Task_Type
			,WiA.Internal_Task_Code
			,WiA.Event_Type
			,WiA.Group_Activity_ID
			,WiA.Override_Address_ID
			,WiA.Destination_Address_ID
			,ROW_NUMBER () -- sort by importance of 'covered' 'absent' and 'Un-Alocated'.
				over 
				(
					Partition by cast(WiA.Schedule_Time as Datetime), WiA.SPPID,WiA.Client_ID Order by 
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

	Left outer join dbo.Provider_Contract Jx001 on Jx001.Provider_ID = J001.Provider_ID and (J001.SPPID = 0 or J001.SPPID is null)
	Left outer join dbo.Organisation Jx002 on Jx002.Organisation_ID = Jx001.Organisation_ID
	Left outer join dbo.Provider_Classification Jx003 on Jx003.Provider_Class_Code = Jx001.Provider_Class_Code

	Left outer join dbo.Service_Provision_Allocation J006 on J006.Service_Prov_Position_ID = J003.Service_Prov_Position_ID
	Left outer join dbo.Provider_Classification J007 on J007.Provider_Class_Code = J003.Provider_Class_Code
	Left outer join dbo.Task_Type J008 on J008.Task_Type_Code = J001.Schedule_Task_Type
	Left outer join dbo.Indirect_Activity_Type J009 on J009.Indirect_Activity_Type_Code = J001.Internal_Task_Code
	Left outer join dbo.WI_Activity_Event_Type J010 on J010.Event_Type = J001.Event_Type
	Left outer join dbo.Group_Activity J011 on J011.Group_Activity_ID = J001.Group_Activity_ID
	--select top 1 * from Address
	left outer join 
	(
		select 
		P.Person_ID
		,Concat(P.Last_Name,', ',P.Preferred_Name)'Client_Name'
		,Concat
		(
			A.Building_Name
			,iif(A.Building_Name is null,null,', ')
			,A.Dwelling_Number
			,iif(A.Dwelling_Number is null,null,' ')
			,A.Street_or_PO_Box
			,iif(A.Street_or_PO_Box is null,null,', ')
			,S.Suburb_Name
			,iif(S.Suburb_Name is null,null,' ')
			,A.Post_Code
		)'Client_Address'
		,A.Access_Comments
		from dbo.Person P
		left outer join dbo.Period_of_Residency PR on PR.Person_ID = P.Person_ID
		left outer join dbo.Address A on A.Address_ID = PR.Address_ID
		left outer join dbo.Suburb S on S.Suburb_ID = A.Suburb_ID
	)J012 on J012.Person_ID = J001.Client_ID

	left outer join 
	(
		select 
		A.Address_ID
		,Concat
		(
			A.Building_Name
			,iif(A.Building_Name is null,null,', ')
			,A.Dwelling_Number
			,iif(A.Dwelling_Number is null,null,' ')
			,A.Street_or_PO_Box
			,iif(A.Street_or_PO_Box is null,null,', ')
			,S.Suburb_Name
			,iif(S.Suburb_Name is null,null,' ')
			,A.Post_Code
		)'Client_Address'
		,A.Access_Comments
		from dbo.Address A
		left outer join dbo.Suburb S on S.Suburb_ID = A.Suburb_ID
	)J013 on J013.Address_ID = J001.Override_Address_ID-- and J001.Override_Address_ID <> 0

	Left outer join dbo.Person_Current_Address_Phone J014 on J014.Person_id = J001.Client_ID
	Left outer join 
	(
		select 
		PA.Alert_Type_ID
		,PA.Person_ID
		,ROW_NUMBER()over
		(
			partition by PA.Person_ID 
			order by Case
			when PA.Alert_Type_ID in (select * from @ProvRiskAlert) then '1'
			else 'z'
			end
		)'RN'
		from dbo.Person_Alert PA

	)J015 on J015.Person_ID = J001.Client_ID
	where
		1=1
		and (J015.RN < 2 or J015.RN is null)
		and J001.Provider_ID <> 0
		and J001.Schedule_Duration is not null
		and J001.Activity_Date between @Start_Date and @End_Date
		and (J005.Organisation_Name = @Centre or Jx002.Organisation_Name = @Centre)
--		/*
		and J001.Event_Type <> 12
		and J001.Event_Type <> 13
		and J001.Event_type <> 17
		and J001.Event_type <> 16
		and J001.Event_type <> 5
--		*/
/*
		and J003.Provider_Class_Code in (@ClassCodeFilter)
		and J004.Description in (@TeamFilt)
--*/

) as T1
where
	1=1
/*
	and t1.Provider_Class_Code in (@ClassCodeFilter)
	and t1.Team in (@TeamFilt)
--*/
group by 
	T1.Centre
	,T1.Team
	,T1.ServiceProvision
	,T1.Provider_Class_Code
	,T1.Provider_Class
	,t1.DayOfWeek
	,t1.Activity_Date
	,t1.StartTime
	,t1.Duration
	,t1.EndTime
	,t1.Provider_ID
	,t1.Client_ID
--	,t1.Absence_Code
	,t1.ProviderName
	,t1.Client_Name
	,t1.Visit_Address
	,t1.Access_Comments
	,t1.Client_PH
	--DeBug Info.
--	/*
	,t1.SPPID
	,t1.Task_Type
	,t1.Internal_Task_Type
	,t1.Event_Type
	,t1.Event_Type_code
	,t1.Group_Activity
	,t1.ClientAlert
	,t1.RN
--*/

order by
	t1.Activity_Date
	,T1.ServiceProvision
	,T1.Provider_Class_Code
	,T1.StartTime
	,T1.Group_Activity
	,T1.Client_ID
	,T1.EndTime

SET DATEFIRST 7

