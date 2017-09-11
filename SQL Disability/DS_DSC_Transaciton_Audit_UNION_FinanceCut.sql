--use ComCareProd
--use ComCareUAT
use ComCareProd
Declare @Client_ID_ as INT = 10072283
DECLARE @StartDate Date = '2017-04-01'
DECLARE @EndDate Date = '2017-04-01'
declare @Organisation VarChar(64) = 'Disabilities Children'
declare @DuplicateChargeItem as int = 0
declare @FiltType int = 0

Declare @ContractType Table (ContractType varchar(64))
Insert INTO @ContractType 
	select 'No Contract' Description where 1=1
union
select
	Description
from dbo.FC_Funder_Contract
where 
	1=1
	AND ((Description like 'DC %' and @Organisation = 'Disabilities Children') OR (Description like 'DA %' and @Organisation = 'Disabilities Adult'))

---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>FROM HERE DOWN<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

declare @Max_Date date =
( 
	select Max (J001.Visit_Date) from dbo.Actual_Service J001
	where
		Cast(J001.Visit_Date as date) between @StartDate and @EndDate
		or J001.Billed_Date between @StartDate and @EndDate
)

declare @Min_Date date =
( 
	select Min (J001.Visit_Date) from dbo.Actual_Service J001
	where
		Cast(J001.Visit_Date as date) between @StartDate and @EndDate
		or J001.Billed_Date between @StartDate and @EndDate
)

select * from
(
	select distinct
		J001.Client_ID
		,J001.Provider_ID
		,IIF(J033.WiA_Schedule_TimeKILL = 'true', null, Cast (J033.Schedule_Time as Datetime)) 'Schedule_Visit_Time'	
		,J033.Scheduled_Duration
		,(Cast (cast(J001.Visit_Date as date) as Datetime) + Cast (Cast (J001.Visit_Time as Time) as Datetime)) 'Actual_Visit_Time'
		,J001.Visit_Duration 'Actual_Duration'
		,IIF (J011.Description is NULL,'No Contract',J011.Description) 'contract_type'
		,J004.Description 'task_Description'
		,J001.Client_Not_Home
		,IIF (J002.Client_ID IS NULL, 0, 1) 'Has_Charge_Item'
		,convert (int ,'0') 'In_WiA_Only'
		,J002.Line_Description 'Charge_Item_Line_Description'
		,J002.Amount
		,IIF
		(
			J009.Organisation_Name = 'NDIA National Disability Insurance Agency'
			, 'NDIS funded'
			,IIF(J009.Client_ID IS NULL,'No Contract Billing','Self Managed')
		) 'Funding_type'
		,J001.Billed_Date
		,1 'AdjustmentType'
		,IIF(cast(J001.Visit_Date as date) between @StartDate and @EndDate,0,1) 'lateData'

	from 
	(
		select 
		* 
		from dbo.Actual_Service A_S 
		where 
		(
			convert(date, A_S.Visit_Date) between @StartDate and @EndDate
			or 1 = iif( @FiltType = 1 and (A_S.Billed_Date between @StartDate and @EndDate), 1, 0 )
		)
		and @DuplicateChargeItem = 0
	)J001

	Left outer Join
	(
		select 
			ACSI.Client_ID	
			,ACSI.Visit_Date
			,ACSI.Visit_No
			,ACSI.Provider_ID
			,ACSI.Service_Prov_Position_ID
			,ACSI.Amount
			,ACSI.Line_Description
		from dbo.Actual_Service_Charge_Item ACSI
	)J002 ON
			J002.Client_ID = J001.Client_ID
			and J002.Visit_Date = J001.Visit_Date
			and J002.Visit_No = J001.Visit_No
			and J002.Service_Prov_Position_ID = J001.Service_Prov_Position_ID

	left outer join
	(
		select
			Wi_A.Client_ID
			,Wi_A.Wi_Record_ID 'Wi_Record_ID'
			,Wi_A.Activity_Date
			,Wi_A.SPPID
			,Wi_A.Schedule_Time 'Schedule_Time'
			,Wi_A.Schedule_Duration 'Scheduled_Duration'
			,Wi_A.ReSchedule 'ReSchedule'
			,Wi_A.Activity_Start_time 'Activity_Start_time'
			,iif(Wi_A.ReSchedule is not null and Wi_A.Activity_Start_time is not null, 'True', 'Flase') 'WiA_Schedule_TimeKILL'
			,AWT.Allocated_Task_ID 'Allocated_Task_ID'
			,Wi_A.Round_Allocation_ID 'Round_Allocation_ID'
		from dbo.wi_activity Wi_A
		left outer join dbo.activity_work_table AWT on AWT.Allocated_Task_ID = Wi_A.Round_Allocation_ID and AWT.activity_date = Wi_A.activity_date

		Where
		 convert (date, Wi_A.Activity_Date) between dateadd(Day,-7,@StartDate) and dateadd(day,+7,@EndDate)
		 or 1 = IIF(@FiltType = 1 and (cast(Wi_A.Activity_Date AS date) between @Min_Date and @Max_Date),1,0)

	)J033 ON 
		J033.Client_ID = J001.Client_ID 
		and J033.Activity_Date = J001.Visit_Date 
		and J033.SPPID = J001.Service_Prov_Position_ID 
		and (J001.Allocated_Task_ID = J033.Allocated_Task_ID or J001.Allocated_Task_ID = J033.Round_Allocation_ID)
			
	left outer join dbo.Task_Type J004 on J004.Task_Type_Code = J001.Task_Type_Code
	left outer join dbo.Service_Delivery J005 ON J001.Client_ID = J005.Client_ID

	left outer join 
	(
		Select 
			SD.Client_ID
			,O.Organisation_Name
			,SD.Service_Type_Code
			,ROW_NUMBER ()
				over 
				(
					Partition by SD.Client_ID Order by
						CASE
						WHEN O.Organisation_Name = @Organisation THEN '1'
						ELSE O.Organisation_Name END ASC
				)'RN'
		from dbo.Service_Delivery SD
			join dbo.Period_of_Residency PR on PR.Person_ID = SD.Client_ID
			join dbo.Address A on A.Address_ID = PR.Address_ID
			Join dbo.Service_Provision SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
			Join dbo.Organisation O on Sp.Centre_ID = O.Organisation_ID
		Where PR.To_Date is null and PR.Display_Indicator  = 1
	) J006 ON J006.Client_ID = J001.Client_ID AND J006.Service_Type_Code = J005.Service_Type_Code

	left outer Join
	(
		select
			CCB.Client_ID 'Client_ID'
			,Org.Organisation_Name 'Organisation_Name'
			,CBG.Description 'ContractBillingGroup'
			,CCB.Contract_Billing_ID 'Contract_Billing_ID'
			,ROW_NUMBER () over 
			(
				Partition by CCB.Client_ID Order by
					CASE
					WHEN Org.Organisation_Name = 'NDIA National Disability Insurance Agency' THEN '1'
					when Org.Organisation_Name is null then '2'
					ELSE Org.Organisation_Name END ASC
			) 'RN'
		from dbo.FB_Client_Contract_Billing CCB
		left outer join dbo.FB_Contract_Billing_Group CBG on CBG.Contract_Billing_Group_ID = CCB.Contract_Billing_Group_ID
		left outer Join dbo.FB_Client_Contract_Billed_To CCBT on CCBT.Client_CB_ID = CCB.Client_CB_ID
		left outer Join dbo.FB_Client_CB_Split CCBS on CCBS.Client_Contract_Billed_To_ID = CCBT.Client_Contract_Billed_To_ID
		left outer Join dbo.Organisation Org on CCBS.Organisation_ID = Org.Organisation_ID

	)J009 on J009.Client_ID = J001.Client_ID

	left outer join dbo.FC_Contract_Area_Product J010 ON J010.CAP_ID = J001.CAP_ID
	left outer join dbo.FC_Funder_Contract J011 ON J011.Funder_Contract_ID = J010.Funder_Contract_ID

	Where 
		1=1
		and @DuplicateChargeItem = 0
--		and J001.Client_ID = @Client_ID_
		and J006.Organisation_Name = @Organisation
		and (J006.RN < 2 or J006.RN is NULL)
		and (J009.RN < 2 or J009.rn is null)
		and 1 = Case 
				when cast(J001.Visit_Date AS date) between @StartDate and @EndDate then 1
				When @FiltType = 1 and cast(J001.Billed_Date as date) between  @StartDate and @EndDate then 1
				else 0
				end
		and (J009.ContractBillingGroup <> 'DCSI' or J009.ContractBillingGroup is null)
		AND (IIF (J011.Description is NULL,'No Contract',J011.Description) in (select * from @ContractType))
--		and (IIF (J011.Description is NULL,'No Contract',J011.Description) in (@ContractType))

) t1
where
	1=1
	and t1.Schedule_Visit_Time is null 
	and t1.Actual_Visit_Time is not null

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
--*/
--/*---------All below this
Union

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
--/*
select * from
(
	select --distinct
		J001.Client_ID
		,J001.WiA_Provider_ID 'Provider_ID'
		,IIF(J001.WiA_Schedule_TimeKILL = 'true', null, Cast (J001.WiA_Schedule_Time as Datetime)) 'Schedule_Visit_Time'	
		,J001.WiA_Scheduled_Duration 'Scheduled_Duration'
		,(Cast (J001.AcS_Activity_Start_Time as Datetime)) 'Actual_Visit_Time'
		,J001.AcS_Visit_Duration as 'Actual_Duration'
		,IIF (J011.Description is NULL,'No Contract',J011.Description) 'contract_type'
		,J004.Description 'task_Description'
		,J001.Client_Not_Home
		,IIF (J002.Client_ID IS NULL, 0, 1) 'Has_Charge_Item'
		,IIF (J001.Client_Not_Home IS NULL, 1, 0) 'In_WiA_Only'
		,J002.Line_Description 'Charge_Item_Line_Description'
		,J002.Amount
		,IIF(J009.Organisation_Name = 'NDIA National Disability Insurance Agency', 'NDIS funded',IIF(J009.Client_ID IS NULL,'No Contract Billing','Self Managed')) 'Funding_Type'
		,J001.Billed_Date
		,1 'AdjustmentType'
		,0 'lateData'
	FROM 
	(
		Select
			IIF(Ac_S.Activity_Start_Time IS NULL, 'FALSE', 'TRUE') 'In_Actual_Service'
			,Wi_A.SPPID 'WiA_SPPID'
			,Ac_S.Service_Prov_Position_ID 'AcS_SPPID'
			,Wi_A.Activity_Date 'WiA_Activity_Date'
			,Wi_A.Activity_Start_Time 'WiA_Activity_Start_Time'
			,Wi_A.Activity_End_Time 'WiA_Activity_End_Time'
			,Wi_A.Client_ID 'Client_ID'
			,Wi_A.Provider_ID 'WiA_Provider_ID'
			,Wi_A.Schedule_Sequence_No 'WiA_Schedule_Sequence_No'
			,Wi_A.Schedule_Task_Type 'WiA_Schedule_Task_Type'
			,iif(Wi_A.ReSchedule is not null and Wi_A.Activity_Start_time is not null, 'True', 'Flase') 'WiA_Schedule_TimeKILL'
			,Convert (DateTime, Wi_A.Schedule_Time) 'WiA_Schedule_Time'
			,IIF
				( 
					Ac_S.Activity_Start_Time is not null
					, Ac_S.Activity_Start_Time
					,cast (cast (Ac_S.Visit_Date as Date ) as DateTime ) 
					+ cast(cast ( Ac_S.Visit_Time as Time ) as DateTime)
				) 'AcS_Activity_Start_Time'
			,Wi_A.Schedule_Duration 'WiA_Scheduled_Duration'
			,Wi_A.Activity_ID 'WiA_Activity_ID'
			,Ac_S.Visit_Duration 'AcS_Visit_Duration'
			,Ac_S.Client_Not_Home 'Client_Not_Home'
			,Ac_S.Visit_Date 'AcS_Visit_Date'
			,Ac_S.Visit_No 'Visit_No'
			,Ac_S.Billed_Date
			,IIF(Ac_S.Task_Type_Code is null,Wi_A.Schedule_Task_Type, Ac_S.Task_Type_Code) 'Task_Type_Code'
			,Wi_A.CAP_ID 'CAP_ID'
			,Wi_A.Absence_Code
			,ROW_NUMBER () -- sort by importance of 'covered' 'absent' and 'Un-Alocated'.
			over 
			(
				Partition by Wi_A.Client_ID, Wi_A.Activity_Date, Wi_A.SPPID Order by 
					Case
						when ((Wi_A.Provider_ID > 0) and (Wi_A.Absence_Code is NULL)) then '1'
						when (Wi_A.Provider_ID > 0) and (Wi_A.Absence_Code is not NULL) then '2'
					else 'z'
				end
			) AS 'RN'
		from 
		(
			select 
			* 
			from dbo.WI_Activity Wi_A1 
			where 
				convert(date, Wi_A1.Activity_Date) between dateadd(Day,-3,@StartDate) and dateadd(day,+3,@EndDate)
				and @DuplicateChargeItem = 0
				
		) Wi_A
		Left Outer Join dbo.Actual_Service Ac_S 
		ON 
			1=1
			and Wi_A.Client_ID = Ac_S.Client_ID 
			and Wi_A.SPPID = Ac_S.Service_Prov_Position_ID
			and Wi_A.Activity_Date = Ac_S.Visit_Date
			and Wi_A.Round_Allocation_ID = Ac_S.Allocated_Task_ID
		where
			1=1
			and Wi_A.Cancellation_Date is NULL
			and Wi_A.Client_ID IS NOT NULL	
	)J001

	Left outer Join
	(
		select 
			ACSI.Client_ID	
			,ACSI.Visit_Date
			,ACSI.Visit_No
			,ACSI.Provider_ID
			,ACSI.Service_Prov_Position_ID
			,ACSI.Amount
			,ACSI.Line_Description
		from dbo.Actual_Service_Charge_Item ACSI

	)J002 ON 
		J002.Client_ID = J001.Client_ID 
		and J002.Visit_Date = J001.AcS_Visit_Date 
		and J002.Visit_No = J001.Visit_No 
		and J002.Service_Prov_Position_ID = J001.AcS_SPPID

	Left outer Join dbo.Task_Type J004 on J004.Task_Type_Code = J001.Task_Type_Code
	Left Outer Join dbo.Service_Delivery J005 ON J001.Client_ID = J005.Client_ID

	Left outer JOIN 
	(
		Select 
			SD.Client_ID
			,O.Organisation_Name
			,SD.Service_Type_Code
			,ROW_NUMBER ()
				over 
				(
					Partition by SD.Client_ID Order by
						CASE
						WHEN O.Organisation_Name = @Organisation THEN '1'
						ELSE O.Organisation_Name END ASC
				) AS 'RN'
		from dbo.Service_Delivery SD
			join dbo.Period_of_Residency PR on PR.Person_ID = SD.Client_ID
			join dbo.Address A on A.Address_ID = PR.Address_ID
			Join dbo.Service_Provision SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
			Join dbo.Organisation O on Sp.Centre_ID = O.Organisation_ID
		Where PR.To_Date is null and PR.Display_Indicator  = 1
	) J006 ON J006.Client_ID = J001.Client_ID AND J006.Service_Type_Code = J005.Service_Type_Code

	Left outer Join
	(
		select
			CCB.Client_ID 'Client_ID'
			,Org.Organisation_Name 'Organisation_Name'
			,CBG.Description 'ContractBillingGroup'
			,ROW_NUMBER ()
				over 
				(
					Partition by CCB.Client_ID Order by
						CASE
						WHEN Org.Organisation_Name = 'NDIA National Disability Insurance Agency' THEN '1'
						when Org.Organisation_Name is null then '2'
						ELSE Org.Organisation_Name END ASC
				) 'RN'
		from dbo.FB_Client_Contract_Billing CCB
			left outer join dbo.FB_Contract_Billing_Group CBG on CBG.Contract_Billing_Group_ID = CCB.Contract_Billing_Group_ID
			left outer Join dbo.FB_Client_Contract_Billed_To CCBT on CCBT.Client_CB_ID = CCB.Client_CB_ID
			left outer Join dbo.FB_Client_CB_Split CCBS on CCBS.Client_Contract_Billed_To_ID = CCBT.Client_Contract_Billed_To_ID
			left outer Join dbo.Organisation Org on CCBS.Organisation_ID = Org.Organisation_ID

	)J009 on J009.Client_ID = J001.Client_ID

	Left Outer Join dbo.FC_Contract_Area_Product J010 ON J010.CAP_ID = J001.CAP_ID
	LEFT OUTER JOIN dbo.FC_Funder_Contract J011 ON J011.Funder_Contract_ID = J010.Funder_Contract_ID

	Where 
		1=1
		and @DuplicateChargeItem = 0
--		and J001.Client_ID = @Client_ID_
		and J006.Organisation_Name = @Organisation
		and 1 = iif(J001.RN > 1 and J001.WiA_Provider_ID = 0, 0, 1)
		and (J006.RN < 2 or J006.RN is null)
		and (J009.RN < 2 or J009.RN is null)
		and convert(date, J001.WiA_Schedule_Time) between @StartDate and @EndDate
		and 1 = Case 
				when @FiltType = 0 and cast(J001.WiA_Schedule_Time AS date) between @StartDate and @EndDate then 1
				When @FiltType = 1 and cast(J001.Billed_Date as date) between  @StartDate and @EndDate then 1
				else 0
				end
		and (J009.ContractBillingGroup <> 'DCSI' or J009.ContractBillingGroup is null)
		and J001.Client_ID IS NOT NULL
		AND (IIF (J011.Description is NULL,'No Contract',J011.Description) in (select * from @ContractType))
--		and (IIF (J011.Description is NULL,'No Contract',J011.Description) in (@ContractType))


--/*
	Group by
		J001.Client_ID
		,J001.WiA_Provider_ID 
		,IIF(J001.WiA_Schedule_TimeKILL = 'true', null, Cast (J001.WiA_Schedule_Time as Datetime))
		,J001.WiA_Scheduled_Duration
		,(Cast (J001.AcS_Activity_Start_Time as Datetime))
		,J001.AcS_Visit_Duration
		,IIF (J011.Description is NULL,'No Contract',J011.Description)
		,J004.Description
		,J001.Client_Not_Home
		,IIF (J002.Client_ID IS NULL, 0, 1)
		,IIF (J001.Client_Not_Home IS NULL, 1, 0)
		,J002.Line_Description
		,J002.Amount
		,IIF(J009.Organisation_Name = 'NDIA National Disability Insurance Agency', 'NDIS funded',IIF(J009.Client_ID IS NULL,'No Contract Billing','Self Managed'))
		,J001.Billed_Date
--*/
)t2

Union

select * from
(
	select
		J002.Client_ID
		,J002.Provider_ID
		,cast(J002.Visit_Date as datetime) 'Schedule_Visit_Time'
		,null 'Scheduled_Duration'
		,null 'Actual_Visit_Time'
		,null 'Actual_Duration'
		,'Inconclusive' 'contract_type'
		,'---' 'task_Description'
		,null 'Client_Not_Home'
		,2 'Has_Charge_Item'
		,null 'In_WiA_Only'
		,J002.Line_Description 'Charge_Item_Line_Description'
		,J002.Amount
		,IIF(J009.Organisation_Name = 'NDIA National Disability Insurance Agency', 'NDIS funded',IIF(J009.Client_ID IS NULL,'No Contract Billing','Self Managed')) 'Funding_Type'
		,null 'Billed_Date'
		,1 'AdjustmentType'
		,0 'lateData'
	from
	(
		select 
			ACSI.Client_ID	
			,ACSI.Visit_Date
			,ACSI.Visit_No
			,ACSI.Provider_ID
			,ACSI.Service_Prov_Position_ID
			,ACSI.Amount
			,ACSI.Line_Description
			,row_number()over(partition by ACSI.Client_ID,ACSI.Provider_ID,ACSI.Visit_Date,ACSI.Visit_No,ACSI.Line_Description order by ACSI.Visit_Date,ACSI.Visit_No)'RN'
		from dbo.Actual_Service_Charge_Item ACSI

	)J002
	Left Outer Join dbo.Service_Delivery J005 ON J002.Client_ID = J005.Client_ID
	left outer join
	(
		Select 
			SD.Client_ID
			,O.Organisation_Name
			,SD.Service_Type_Code
			,ROW_NUMBER ()
				over 
				(
					Partition by SD.Client_ID Order by
						CASE
						WHEN O.Organisation_Name = @Organisation THEN '1'
						ELSE O.Organisation_Name END ASC
				)'RN'
		from dbo.Service_Delivery SD
			join dbo.Period_of_Residency PR on PR.Person_ID = SD.Client_ID
			join dbo.Address A on A.Address_ID = PR.Address_ID
			Join dbo.Service_Provision SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
			Join dbo.Organisation O on Sp.Centre_ID = O.Organisation_ID
		Where PR.To_Date is null and PR.Display_Indicator  = 1
	) J006 ON J006.Client_ID = J002.Client_ID AND J006.Service_Type_Code = J005.Service_Type_Code

	Left outer Join
	(
		select
			CCB.Client_ID 'Client_ID'
			,Org.Organisation_Name 'Organisation_Name'
			,CBG.Description 'ContractBillingGroup'
			,ROW_NUMBER ()
				over 
				(
					Partition by CCB.Client_ID Order by
						CASE
						WHEN Org.Organisation_Name = 'NDIA National Disability Insurance Agency' THEN '1'
						when Org.Organisation_Name is null then '2'
						ELSE Org.Organisation_Name END ASC
				) 'RN'
		from dbo.FB_Client_Contract_Billing CCB
			left outer join dbo.FB_Contract_Billing_Group CBG on CBG.Contract_Billing_Group_ID = CCB.Contract_Billing_Group_ID
			left outer Join dbo.FB_Client_Contract_Billed_To CCBT on CCBT.Client_CB_ID = CCB.Client_CB_ID
			left outer Join dbo.FB_Client_CB_Split CCBS on CCBS.Client_Contract_Billed_To_ID = CCBT.Client_Contract_Billed_To_ID
			left outer Join dbo.Organisation Org on CCBS.Organisation_ID = Org.Organisation_ID
	)J009 on J009.Client_ID = J002.Client_ID

	where
	J002.RN > 1
--	and J002.Client_ID = @Client_ID_
	and (J009.RN < 2 or J009.RN is null)
	and convert(date, J002.Visit_Date) between @StartDate and @EndDate
	and J006.Organisation_Name = @Organisation
	and (J009.ContractBillingGroup <> 'DCSI' or J009.ContractBillingGroup is null)
)t3
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
Union
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
select * from
(
	select distinct
		J001.Client_ID
		,null 'Provider_ID'
		,null 'Schedule_Visit_Time'
		,null 'Scheduled_Duration'
		,Cast(J010.Effective_From_Date as Date) 'Actual_Visit_Time'
		,null 'Actual_Duration'
		,J012.Description 'contract_type'
		,'Finance Adjustment' 'task_Description'
		,null 'Client_Not_Home'
		,6 'Has_Charge_Item'
		,null 'In_WiA_Only'
		,J010.Comments 'Charge_Item_Line_Description'
		,J010.Adjustment_Amount
		,IIF(J009.Organisation_Name = 'NDIA National Disability Insurance Agency', 'NDIS funded',IIF(J009.Client_ID IS NULL,'No Contract Billing','Self Managed')) 'Funding_Type'
		,J015.Processing_Date 'Billed_Date'
		,iif(J011.Description like '%eduction%',-1,1)'AdjustmentType'
		,IIF(cast(J010.Effective_From_Date AS date) between @StartDate and @EndDate,0,1) 'lateData'
	from
	(
		select
			CCB.Client_ID 'Client_ID'
			,CCB.Client_CB_ID 'Client_CB_ID'
		from dbo.FB_Client_Contract_Billing CCB
			LEFT OUTER JOIN dbo.FB_Contract_Billing_Group CBG on CBG.Contract_Billing_Group_ID = CCB.Contract_Billing_Group_ID
			LEFT OUTER JOIN dbo.FB_Client_Contract_Billed_To CCBT on CCBT.Client_CB_ID = CCB.Client_CB_ID
			LEFT OUTER JOIN dbo.FB_Client_CB_Split CCBS on CCBS.Client_Contract_Billed_To_ID = CCBT.Client_Contract_Billed_To_ID
			LEFT OUTER JOIN dbo.Organisation Org on CCBS.Organisation_ID = Org.Organisation_ID
		where
			1=1
			and (Org.Organisation_Name = 'NDIA National Disability Insurance Agency' or Org.Organisation_Name is null)
		group by
			CCB.Client_ID
			,CCB.Client_CB_ID
	)J001

	LEFT OUTER JOIN dbo.Service_Delivery J005 ON J001.Client_ID = J005.Client_ID

	INNER JOIN 
	(
		Select 
			SD.Client_ID
			,O.Organisation_Name
			,SD.Service_Type_Code
			,SD.From_Date
			,SD.To_Date
			,ROW_NUMBER ()
				over 
				(
					Partition by SD.Client_ID Order by
						CASE
						WHEN O.Organisation_Name = @Organisation THEN '1'
						ELSE O.Organisation_Name END ASC
				) AS 'RN'
		from dbo.Service_Delivery SD
			JOIN dbo.Period_of_Residency PR on PR.Person_ID = SD.Client_ID
			JOIN dbo.Address A on A.Address_ID = PR.Address_ID
			JOIN dbo.Service_Provision SP on A.Suburb_ID = SP.Suburb_ID AND SP.Service_Type_Code = SD.Service_Type_Code
			JOIN dbo.Organisation O on Sp.Centre_ID = O.Organisation_ID
		Where PR.To_Date IS NULL AND PR.Display_Indicator  = 1
	) J006 ON J006.Client_ID = J001.Client_ID AND J006.Service_Type_Code = J005.Service_Type_Code

	LEFT OUTER JOIN 
	(
		select
			CCB.Client_ID 'Client_ID'
			,Org.Organisation_Name 'Organisation_Name'
			,CBG.Description 'ContractBillingGroup'
			,CCB.Client_CB_ID 'Client_CB_ID'
			,CCB.Funder_Contract_ID 'Funder_Contract_ID'
			,CCBT.Client_Contract_Billed_To_ID 'Client_Contract_Billed_To_ID'
			,ROW_NUMBER ()
				over 
				(
					Partition by CCB.Client_ID Order by
						CASE
						WHEN Org.Organisation_Name = 'NDIA National Disability Insurance Agency' THEN '1'
						ELSE Org.Organisation_Name END ASC
				) 'RN'
		from dbo.FB_Client_Contract_Billing CCB
			LEFT OUTER JOIN dbo.FB_Contract_Billing_Group CBG on CBG.Contract_Billing_Group_ID = CCB.Contract_Billing_Group_ID
			LEFT OUTER JOIN dbo.FB_Client_Contract_Billed_To CCBT on CCBT.Client_CB_ID = CCB.Client_CB_ID
			LEFT OUTER JOIN dbo.FB_Client_CB_Split CCBS on CCBS.Client_Contract_Billed_To_ID = CCBT.Client_Contract_Billed_To_ID
			LEFT OUTER JOIN dbo.Organisation Org on CCBS.Organisation_ID = Org.Organisation_ID
		where
			1=1
			and Org.Organisation_Name = 'NDIA National Disability Insurance Agency'
			or Org.Organisation_Name is null

	)J009 on J009.Client_ID = J001.Client_ID

	LEFT OUTER JOIN dbo.FB_Client_CB_Bill_Adjustment J010 ON J010.Client_CB_ID = J009.Client_CB_ID
	LEFT OUTER JOIN dbo.FB_Adjustment_Type J011 ON J011.Adjustment_Type_Code = J010.Adjustment_Type_Code
	left outer join dbo.FC_Funder_Contract J012 ON J012.Funder_Contract_ID = J009.Funder_Contract_ID
	left outer join dbo.GST_Type J014 on J014.GST_Type_Code = J010.GST_Type_Code
	left outer join dbo.FB_Client_CB_Transaction J015 on J015.Client_CB_ID = J010.Client_CB_ID and J015.Client_CB_Adj_ID = J010.Client_CB_Adj_ID

	Where 
		1=2
		and @DuplicateChargeItem = 0
		and J006.Organisation_Name = @Organisation
		and (J006.RN < 2 or J006.RN is null)
	--	and (J009.RN < 2 or J009.RN is null)

		and 1 = Case 
				when cast(J010.Effective_From_Date AS date) between @StartDate and @EndDate then 1
				When @FiltType = 1 and cast(J015.Processing_Date as date) between  @StartDate and @EndDate then 1
				else 0
				end
		and (J009.ContractBillingGroup <> 'DCSI' or J009.ContractBillingGroup is null)
	--	and (J012.Description in (select * from @ContractFilt) or J012.Description is null)


)t4


------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
--*/

order by
1,3,5,8,2,12

--*/
