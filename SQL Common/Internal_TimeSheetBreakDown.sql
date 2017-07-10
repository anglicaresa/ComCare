
declare @Start_Date date = cast('2017-05-15' as date)
declare @End_Date date = cast('2017-05-15' as date)
DECLARE @OrgName AS Varchar(64) = 'Home Care north'

--select * from dbo.Actual_Service
/*
select * from dbo.Organisation
select top 100 * from dbo.Activity_Work_Table where travel_Duration is not null
select top 1 * from dbo.Service_Provision_Position
select top 100 * from dbo.Provider_Contract
select top 1 * from dbo.Service_Delivery_Work_Team
select * from dbo.Service_Provision_Position
select * from dbo.Indirect_Activity_Type
select top 1 * from Actual_Service_Charge_Item ASCI order by Actual_Service_Charge_Item_ID DESC

select top 1 * from dbo.Unit_of_Measure

THINGS TO THINK ABOUT
milage?
Group Activity?

--suspect!!!!!!!!!!!
10012268
10012311
10012359
--*/
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

declare @IndirectLookupPayType table
(
	Code int
	,PayTypeFlag int
	,TimeOffset int
)
Insert into @IndirectLookupPayType values
	(1,1,0)		--1 Internal Meeting
	,(2,1,0)	--2 External Meeting
	,(4,1,0)	--4 Internal Training/Education
	,(5,1,0)	--5 External Training/Education
	,(8,1,0)	--8 Networking
	,(10,1,0)	--10 Manual Handling Training
	,(12,1,0)	--12 Performance Review
	,(13,1,0)	--13 Admin/Data
	,(20,1,0)	--20 Phone Calls
	,(27,0,0)	--27 Travel Allowance
	,(38,1,0)	--38 On Call Hours
	,(45,0,0)	--45 Not available for work
	,(46,1,0)	--46 Base Visit
	,(48,1,0)	--48 Top-up
	,(49,1,0)	--49 Client-related travel
	,(51,1,0)	--51 Group Activity
	,(55,1,0)	--55 Disturbed Sleepover
	,(56,0,0)	--56 Reminder Lunch Break
	,(58,1,-30)	--58 Start Shift 30 min break
	,(59,1,-45)	--59 Start Shift 45 min break
	,(60,1,-60)	--60 Start Shift 60 min break
	,(64,1,0)	--64 Online Training
	,(67,1,0)	--67 Buddy Shift
	,(68,1,0)	--68 Tea Break 10mins
	,(69,1,0)	--69 Base Cleaning
	,(70,0,0)	--70 Meal Break 30mins
	,(73,0,0)	--73 Meal Break 45mins
	,(74,0,0)	--74 Meal Break 60mins
	,(75,1,0)	--75 Meal Break 0mins
	,(76,1,0)	--76 Overnight Respite

-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
declare @RawData table
(
	Organisation_Name VarChar(128)
	,Team VarChar(128)
	,IndirectActivity VarChar(128)
	,Provider_ID int
	,Provider_Name VarChar(128)
	,Client_ID int
	,Activity_Date Date
	,Actual_Service_Visit_No int
	,Activity_Type VarChar(16)
	,Activity_Start_Time time
	,Activity_Duration Dec(10,2)
	,Indirect_Activity_Type_Code int
	,Indirect_Activity_Type varchar(64)
	,SPPID int
	,Group_Activity_ID int
	,WI_Record_ID int
	,Task_Type_Code varchar(32)
	,AS_Indicator int
	,AS_Client_ID int
	,AS_Duration Dec(10,2) --?
	,ASCI_Indicator int
	,ASCI_Client_ID int
	,ASCI_Amount decimal(10,2)
	,ASCI_Rate_Type VarChar(16)
	,ASCI_Rate decimal(10,2)
	,ASCI_Unit decimal(10,2)
	,ASCI_UOM VarChar(16)
	,IndirectPayTypeFlag int
	,IndirectPayOffset int
	,Row_Count int
	,RowNumber int
)
insert into @RawData
Select
	J001.Organisation_Name
	,J002.Description 'Team'
	,J008.Description 'IndirectActivity'
	,J006.Provider_ID
	,J013.Provider_Name
	,J007.Client_ID
	,cast(J007.Activity_Date as date)'Activity_Date'
	,J007.Actual_Service_Visit_No
	,J007.Activity_Type
	,cast(J007.Activity_Start_Time as time)'Activity_Start_Time'
	,cast(J007.Activity_Duration as Dec(10,2))'Activity_Duration'
	,J007.Indirect_Activity_Type_Code
	,J012.Description 'Indirect_Activity_Type'
	,J007.Service_Prov_Position_ID 'SPPID'
	,J007.Group_Activity_ID
	,J007.WI_Record_ID
	,J007.Task_Type_Code
	,J009.AS_Indicator
	,J009.AS_Client_ID
	,J009.AS_Duration
	,J010.ASCI_Indicator
	,J010.ASCI_Client_ID
	,J010.ASCI_Amount
	,J010.ASCI_Rate_Type 
	,J010.ASCI_Rate
	,J010.ASCI_Unit
	,J010.ASCI_UOM
	,J011.PayTypeFlag 'IndirectPayTypeFlag'
	,J011.TimeOffset 'IndirectPayOffset'
	,Count(J006.Provider_ID)over (partition by null )'Row_Count'
	,Row_Number() 
		over
		(
			Partition by 
				null 
			order by 
				J001.Organisation_Name
				,J006.Provider_ID
				,cast(J007.Activity_Date as date)
				,J007.Task_Type_Code
				,J007.Indirect_Activity_Type_Code
				,cast(J007.Activity_Start_Time as time)
		)'RowNumber'

from dbo.Organisation J001

inner join dbo.Provider_Contract J006 on J006.Organisation_ID = J001.Organisation_ID

Left outer join
(
	select
		*
		,iif(AWT.Indirect_Activity_Type_Code is null,'Task','InternalTask')'Activity_type'
	from dbo.Activity_Work_Table AWT
	where
		AWT.Authorisation_Date is not null
		and cast(AWT.Activity_Date as date) between @Start_Date and @End_Date
)J007 on J007.Provider_ID = J006.Provider_ID

left outer join dbo.Service_Provision_Position J003 on J003.Service_Prov_Position_ID = J007.Service_Prov_Position_ID
Left outer join dbo.Service_Delivery_Work_Team J002 on J002.Team_No = J003.Team_No and J002.Centre_ID = J003.Centre_ID
Left outer join dbo.Indirect_Activity_Type J008 on J008.Indirect_Activity_Type_Code = J007.Indirect_Activity_Type_Code

Left outer join
(
	select
		A_S.Provider_ID
		,A_S.Visit_Date
		,A_S.Visit_No
		,A_S.Client_ID 'AS_Client_ID'
		,A_S.Service_Prov_Position_ID
		,A_S.Task_Type_Code
		,cast(A_S.Visit_Duration as decimal(10,2)) 'AS_Duration'
		,1 'AS_Indicator'
--		,A_S.
	from dbo.Actual_Service A_S
)J009 on 
	J009.Provider_ID = J006.Provider_ID 
	and J009.Visit_Date = J007.Activity_Date 
	and J009.Visit_No = J007.Actual_Service_Visit_No
	and J009.AS_Client_ID = J007.Client_ID
	and J009.Service_Prov_Position_ID = J007.Service_Prov_Position_ID
	and J009.Task_Type_Code = J007.Task_Type_Code

Left outer join
(
	select
	ASCI.Provider_ID
	,ASCI.Visit_Date
	,ASCI.Visit_No
	,ASCI.Client_ID 'ASCI_Client_ID'
	,ASCI.Service_Prov_Position_ID
	,ASCI.Amount 'ASCI_Amount'
	,ASCI.Rate_Type 'ASCI_Rate_Type'
	,ASCI.Rate 'ASCI_Rate'
	,ASCI.Unit 'ASCI_Unit'
	,UOM.Description 'ASCI_UOM'
	,1 'ASCI_Indicator'
	,ROW_NUMBER() 
		over 
		(
			partition by 
				ASCI.Provider_ID, ASCI.Visit_Date, ASCI.Visit_No, ASCI.Client_ID, ASCI.Service_Prov_Position_ID
			order by
				Case
				when ASCI.Rate_Type = 'N/A' then 'Z'
				else ASCI.Rate_Type
				end
		)'RN'
	from Actual_Service_Charge_Item ASCI
--	/*
	Inner Join [dbo].[FB_Contract_Billing_Item] CBI on ASCI.Contract_Billing_Item_ID = CBI.Contract_Billing_Item_ID
	LEFT OUTER JOIN [dbo].[FB_Contract_Billing_Rate] CBR on ASCI.Contract_Billing_Rate_ID = CBR.Contract_Billing_Rate_ID
	LEFT OUTER JOIN [dbo].[Unit_of_Measure] UOM ON CBR.[UOM_Code] = UOM.[UOM_Code]
--	*/
)J010 on
	J009.Provider_ID = J010.Provider_ID 
	and J009.Visit_Date = J010.Visit_Date 
	and J009.Visit_No = J010.Visit_No
	and J009.AS_Client_ID = J010.ASCI_Client_ID
	and J009.Service_Prov_Position_ID = J010.Service_Prov_Position_ID

Left outer join @IndirectLookupPayType J011 on J007.Indirect_Activity_Type_Code = J011.Code
left outer join dbo.Indirect_Activity_Type J012 on J012.Indirect_Activity_Type_Code = J007.Indirect_Activity_Type_Code
inner join 
(
	select
	Concat (P.Preferred_Name,' ',P.Last_Name)'Provider_Name'
	,P.Person_ID
	from dbo.person P
)J013 on J013.Person_ID = J006.Provider_ID

where
	J001.Organisation_Name = @OrgName
	and (J010.RN < 2 or J010.RN is null)
	and cast(J007.Activity_Date as date) between @Start_Date and @End_Date

--	and J006.Provider_ID = 10013562

Group by
	J001.Organisation_Name
	,J002.Description
	,J008.Description
	,J006.Provider_ID
	,J013.Provider_Name
	,J007.Client_ID
	,cast(J007.Activity_Date as date)
	,J007.Actual_Service_Visit_No
	,J007.Activity_Type
	,cast(J007.Activity_Start_Time as time)
	,J007.Activity_Duration
	,J007.Indirect_Activity_Type_Code
	,J012.Description
	,J007.Service_Prov_Position_ID
	,J007.Group_Activity_ID
	,J007.WI_Record_ID
	,J007.Task_Type_Code
	,J009.AS_Indicator
	,J009.AS_Client_ID
	,J009.AS_Duration 
	,J010.ASCI_Indicator
	,J010.ASCI_Client_ID
	,J010.ASCI_Amount
	,J010.ASCI_Rate_Type 
	,J010.ASCI_Rate
	,J010.ASCI_Unit
	,J010.ASCI_UOM
	,J011.PayTypeFlag
	,J011.TimeOffset

Order by
	J001.Organisation_Name
	,J006.Provider_ID
	,cast(J007.Activity_Date as date)
	,J007.Task_Type_Code
	,J007.Indirect_Activity_Type_Code
	,cast(J007.Activity_Start_Time as time)
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
select * from @RawData

Declare @i_RowNum int = 1
Declare @i_MaxRow int = (select top 1 RR.Row_Count from @RawData RR)
Declare @i_PID int = null
Declare @t_ActivityDate DateTime = null
declare @J_Task_Type VarChar(255) = null
declare @J_IndTask_Type VarChar(255) = null
declare @i_BaseCount int = 1
Declare @i_TriggerFirstTaskEntry int	= 0
Declare @Joined_Task table (Provider_ID int, Activity_Date datetime,Joined_Task_Types VarChar(255), Joined_Indirect_Task_Types VarChar(255))
declare @i_Temp int = 0
declare @VC_PrevTtype varchar(128)=''
declare @VC_CurTtype varchar(128)=''
declare @VC_Prev_iTtype varchar(128)=''
declare @VC_Cur_iTtype varchar(128)=''

--Start Main processing
--print '------------------------------------------'
while @i_RowNum <= @i_MaxRow
begin
	-----------------------------------------------------------------------------------------------------------
	--Define current provider for current entry
	set @i_PID = (select RR.Provider_ID from @RawData RR where RR.RowNumber = @i_RowNum)--baseValue setup
	Set @t_ActivityDate = (select RR.Activity_Date from @RawData RR where RR.RowNumber = @i_RowNum)
	Set @VC_CurTtype = (select RR.Task_Type_Code from @RawData RR where RR.RowNumber = @i_RowNum)
	set @VC_Cur_iTtype = (select RR.Indirect_Activity_Type from @RawData RR where RR.RowNumber = @i_RowNum)

	if @i_BaseCount = 1
	begin
		set @J_Task_Type = (select RR.Task_Type_Code from @RawData RR where RR.RowNumber = @i_RowNum)--Define Edit action (OS,A,OU,StartEnd,F)
		set @VC_PrevTtype = 'null'
		set @J_IndTask_Type = (select RR.Indirect_Activity_Type from @RawData RR where RR.RowNumber = @i_RowNum)
		set @VC_Prev_iTtype = 'null'
	end

	if @VC_CurTtype is null begin set @VC_CurTtype = 'null' end
	if @VC_Cur_iTtype is null begin set @VC_Cur_iTtype = 'null' end

	if @i_BaseCount <> 1
	begin
		set @VC_PrevTtype = (select RR.Task_Type_Code from @RawData RR where RR.RowNumber = @i_RowNum -1)
		set @VC_Prev_iTtype = (select RR.Indirect_Activity_Type from @RawData RR where RR.RowNumber = @i_RowNum -1)
	end
	
	if @VC_PrevTtype is null begin set @VC_PrevTtype = 'null' end
	if @VC_Prev_iTtype is null begin set @VC_Prev_iTtype = 'null' end


	----------------------------------------------------------------------------------------------------------------------

	if @i_BaseCount <> 1 and @VC_PrevTtype <> @VC_CurTtype and @VC_CurTtype != 'null'
	begin
		if @VC_PrevTtype = 'null' begin set @J_Task_Type = @VC_CurTtype end
		else begin set @J_Task_Type = @J_Task_Type + ', ' + @VC_CurTtype end
	end

	if @i_BaseCount <> 1 and @VC_Prev_iTtype <> @VC_Cur_iTtype and @VC_Cur_iTtype != 'null'
	begin

		if @VC_Prev_iTtype = 'null' begin set @J_IndTask_Type = @VC_Cur_iTtype end
		else begin set @J_IndTask_Type = @J_IndTask_Type + ', ' + @VC_Cur_iTtype end
	end

	 --Cycle mechanic
	set @i_Temp = @i_BaseCount
	set  @i_BaseCount = @i_Temp + 1
	set @i_Temp = @i_RowNum

	-----------------------------------------------------------------------------------------------------------
	--end base setup
	-----------------------------------------------------------------------------------------------------------
	if --Check to see if the provider ID has changed or the Date
	(@i_PID <> (select RR.Provider_ID from @RawData RR where RR.RowNumber = @i_RowNum+1)) 
	or (@t_ActivityDate <> (select RR.Activity_Date from @RawData RR where RR.RowNumber = @i_RowNum+1)) 
	or  @i_RowNum = @i_MaxRow
	begin
		set @i_TriggerFirstTaskEntry = 1
	end
	
	if @i_TriggerFirstTaskEntry = 1
	begin
		insert into @Joined_Task Values ( @i_PID,@t_ActivityDate,@J_Task_Type,@J_IndTask_Type)
		set @i_TriggerFirstTaskEntry = 0
		set @i_BaseCount = 1
	end
	set @i_RowNum = @i_Temp + 1

end
---------------------------------------------
/*
insert into @Join_Employee
	select
		P.Employee_No 
	from @Joined_Task JT
	inner join dbo.Provider P on P.Provider_ID = JT.Provider_ID

--*/
---------------------------------------------
--select * from @Joined_Task

select * from
(
	select
		JS001.Organisation_Name
--		,JS001.Team
		,JS001.Provider_ID
		,JS001.Provider_Name
		,JS001.Activity_Date
		,JS002.Joined_Task_Types 'Task_Types'
		,JS002.Joined_Indirect_Task_Types 'Indirect_Task_Types'
		,Count (JS001.Client_ID) over(partition by JS001.Provider_ID, JS001.Activity_Date) 'TS_ClientCount'
		,sum (iif (JS001.Activity_Type = 'Task' and JS001.Group_Activity_ID is null, JS001.Activity_Duration/60.0,0.0)) over(Partition by JS001.Provider_ID, JS001.Activity_Date) 'TS_TaskLogged'
		,sum (iif (JS001.Activity_Type != 'Task' and JS001.Group_Activity_ID is null and JS001.IndirectPayTypeFlag = 0, JS001.Activity_Duration/60.0,0.0)) over(Partition by JS001.Provider_ID, JS001.Activity_Date) 'TS_InternalTaskUnPaid'
		,sum (iif (JS001.Activity_Type != 'Task' and JS001.Group_Activity_ID is null and JS001.IndirectPayTypeFlag = 1,(JS001.Activity_Duration - JS001.IndirectPayOffset)/60.0,0.0)) over(Partition by JS001.Provider_ID, JS001.Activity_Date) 'TS_InternalTaskPaid'
		,sum (iif (JS001.Activity_Type = 'Task' and JS001.Group_Activity_ID is not null, JS001.Activity_Duration/60.0,0.0)) over(Partition by JS001.Provider_ID, JS001.Activity_Date) 'TS_GroupClientTotalTime'
		,Count (JS001.AS_Client_ID) over(partition by JS001.Provider_ID, JS001.Activity_Date) 'AS_ClientCount'
		,sum (iif (JS001.Group_Activity_ID is null, JS001.AS_Duration/60.0,0.0)) over(Partition by JS001.Provider_ID, JS001.Activity_Date) 'AS_TaskLogged'
		,sum (iif (JS001.Group_Activity_ID is not null, JS001.AS_Duration/60.0,0)) over(Partition by JS001.Provider_ID, JS001.Activity_Date) 'AS_GroupClientTotalTime'
		,Count (JS001.ASCI_Client_ID) over(partition by JS001.Provider_ID, JS001.Activity_Date) 'CI_ClientCount'
		,sum (iif (JS001.ASCI_UOM = 'Hour', JS001.ASCI_Unit,0.0)) over(Partition by JS001.Provider_ID, JS001.Activity_Date) 'CI_Hours'
		,sum (iif (JS001.ASCI_UOM = 'Visit', JS001.ASCI_Unit,0.0)) over(Partition by JS001.Provider_ID, JS001.Activity_Date) 'CI_Visit'
		,sum (iif (JS001.ASCI_UOM = 'Unit', JS001.ASCI_Unit,0.0)) over(Partition by JS001.Provider_ID, JS001.Activity_Date) 'CI_Unit'
		,sum (JS001.ASCI_Amount) over(Partition by JS001.Provider_ID, JS001.Activity_Date) 'CI_TotalCharge'
		,JS003.Employee_No
		,CONCAT(JS003.Employee_No,'_',JS001.Activity_Date)'Key_1'

	from @RawData JS001
	left outer join @Joined_Task JS002 on JS002.Provider_ID = JS001.Provider_ID and JS002.Activity_Date = JS001.Activity_Date
	left outer join dbo.Provider JS003 on JS003.Provider_ID = JS001.Provider_ID

)T1
where
	1=1
--	and T1.Key_1 = '6630_2017-05-15'

group by
	T1.Organisation_Name
--	,T1.Team
	,T1.Provider_ID
	,T1.Provider_Name
	,T1.Activity_Date
	,T1.Task_Types
	,T1.Indirect_Task_Types
	,T1.TS_ClientCount
	,T1.TS_TaskLogged
	,T1.TS_InternalTaskUnPaid
	,T1.TS_InternalTaskPaid
	,T1.TS_GroupClientTotalTime
	,T1.AS_ClientCount
	,T1.AS_TaskLogged
	,T1.AS_GroupClientTotalTime
	,T1.CI_ClientCount
	,T1.CI_Hours
	,T1.CI_Visit
	,T1.CI_Unit
	,T1.CI_TotalCharge
	,T1.Employee_No
	,T1.Key_1
