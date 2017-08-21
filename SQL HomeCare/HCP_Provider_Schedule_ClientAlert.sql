
declare @Start_Date date = '2017-08-14'
declare @End_Date date = '2017-08-14'
declare @Centre varchar(128) = 'Home Care Barossa Yorke Peninsula'
declare @ClassCodeFilter VarChar(8)= 'HW'

---------------------------
--Main quiry
---------------------------
Declare @ProvRiskAlert Table (Code int)
insert into @ProvRiskAlert values (2),(3),(6),(8)

Select * from 
(
	select
		J001.Client_ID
		,J012.Client_Name
		,J014.Phone 'Client_PH'
		,J016.Description'Alert_type'
		,J015.Alert_Comments'Alert_Comments'
		,iif(J015.Alert_Type_ID is null,0,iif(J015.Alert_Type_ID in(select * from @ProvRiskAlert),2,1))'HighlightAlert'

	From 
	(
		Select
			WiA.SPPID 'SPPID'
			,WIA.Client_ID
			,cast (WiA.Activity_Date as date) 'Activity_Date'
			,WiA.Provider_ID 'Provider_ID'
			,WiA.Schedule_Duration 'Schedule_Duration'
		From dbo.Wi_Activity WiA
		where 
			convert(date, Wia.Activity_Date) between dateadd(day,-7,@Start_Date) and dateadd(day,7,@End_Date)
			and Wia.Event_Type <> 12
			and Wia.Event_Type <> 13
			and Wia.Event_type <> 17
			and Wia.Event_type <> 16
	)J001

	Left Outer Join dbo.Person J002 on J002.Person_ID = J001.Provider_ID
	Left outer join dbo.Service_Provision_Position J003 on J003.Service_Prov_Position_ID = J001.SPPID
	Left outer join dbo.Service_Delivery_Work_Team J004 on J004.Team_No = J003.Team_No and J004.Centre_ID = J003.Centre_ID
	Left outer join dbo.Organisation J005 on J005.Organisation_ID = J004.Centre_ID

	left outer join 
	(
		select 
		P.Person_ID
		,Concat(P.Last_Name,', ',P.Preferred_Name)'Client_Name'
		from dbo.Person P
	)J012 on J012.Person_ID = J001.Client_ID

	Left outer join dbo.Person_Current_Address_Phone J014 on J014.Person_id = J001.Client_ID
	Left outer join dbo.Person_Alert J015 on J015.Person_ID = J001.Client_ID
	Left outer join dbo.Alert_Type J016 on J016.Alert_Type_ID = J015.Alert_Type_ID

	where
		1=1
		and J001.Provider_ID <> 0
		and J001.Schedule_Duration is not null
		and J001.Activity_Date between @Start_Date and @End_Date
		and J005.Organisation_Name = @Centre

) as T1
where
	1=1
	and t1.Alert_type is not null

group by 
	t1.Client_ID
	,t1.Client_Name
	,t1.Client_PH
	,t1.Alert_type
	,t1.Alert_Comments
	,t1.HighlightAlert

order by
	t1.Client_Name
	,T1.Client_ID

--	select * from dbo.Alert_Type 2 3 6 8