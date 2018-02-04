



Declare @Client_ID_ as INT = 10070950
DECLARE @StartDate Date = '2017-08-01'
DECLARE @EndDate Date = '2017-08-05'
declare @Organisation VarChar(64) = 'Disabilities Children'
declare @DuplicateChargeItem as int = 0
declare @FiltType int = 1

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

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>FROM HERE DOWN<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
--Setting up date hunt range for Late processed.

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

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
--------------------------------Base Query from Actual_Service => Actual_Service_Charge_Item
--/*
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
		,J001.Task_Type_Code 'Actual_TaskCode'
		,J033.Schedule_Task_Type 'Schedule_TaskCode'
		,J014.Description 'Client_Not_Home'
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
		,J009.FundingProgram--new
		,J001.Billed_Date
		,1 'AdjustmentType'
		,IIF(cast(J001.Visit_Date as date) between @StartDate and @EndDate,0,1) 'lateData'
		,0 'AdjFix'
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
		where ACSI.Visit_Date between @StartDate and @EndDate
		or 1 = IIF(@FiltType = 1 and (cast(ACSI.Visit_Date AS date) between @Min_Date and @Max_Date),1,0)
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
			,Wi_A.Schedule_Task_Type
		from dbo.wi_activity Wi_A
		left outer join dbo.activity_work_table AWT on AWT.Allocated_Task_ID = Wi_A.Round_Allocation_ID and AWT.activity_date = Wi_A.activity_date

		Where
		 convert (date, Wi_A.Activity_Date) between dateadd(Day,-3,@StartDate) and dateadd(day,+3,@EndDate)
		 or 1 = IIF(@FiltType = 1 and (cast(Wi_A.Activity_Date AS date) between @Min_Date and @Max_Date),1,0)

	)J033 ON 
		J033.Client_ID = J001.Client_ID 
		and J033.Activity_Date = J001.Visit_Date 
		and J033.SPPID = J001.Service_Prov_Position_ID 
		and (J001.Allocated_Task_ID = J033.Allocated_Task_ID or J001.Allocated_Task_ID = J033.Round_Allocation_ID)
			
	left outer join dbo.Task_Type J004 on J004.Task_Type_Code = J001.Task_Type_Code

	Left outer join
	(
		select
		JX001.Service_Prov_Position_ID 'SPPID'
		,JX002.Organisation_Name
		From dbo.Service_Provision_Position JX001
		left outer join dbo.Organisation JX002 on JX002.Organisation_ID = JX001.Centre_ID
	)J006 on J006.SPPID = J001.Service_Prov_Position_ID

	left outer Join
	(
		select 
			JX001.Client_ID 
			,JX001.From_Date
			,JX001.To_Date
			,JX009.Description 'FundingProgram'
			,JX002.CAP_ID
			,JX002.Funding_Prog_Code
			,JX014.Service_Type_Code
			,JX011.Task_Type_Code
			,JX004.Billing_Start_Date
			,JX004.Billing_End_Date
			,JX004.Contract_Billing_ID
			,JX004.Client_CB_ID
			,JX006.Effective_From_Date 'Billed_to_efFrom'
			,JX006.Effective_To_Date 'Billed_to_efTo'
			,JX005.Description 'Contract_Billing_Group'
			,JX008.Organisation_Name
			,JX010.Effective_From_Date
			,JX010.Effective_to_Date
		from dbo.Service_Delivery JX001
		inner join dbo.FC_Contract_Area_Product JX002 on JX002.Funding_Prog_Code = JX001.Funding_Prog_Code
		inner join dbo.Task_Type JX003 on JX003.Service_Type_Code = JX001.Service_Type_Code
		Left outer join dbo.FB_Client_Contract_Billing JX004 on JX004.Client_ID = JX001.Client_ID and JX004.Funder_Contract_ID = JX002.Funder_Contract_ID --connect to billing item
		left outer join dbo.FB_Contract_Billing_Group JX005 on JX005.Contract_Billing_Group_ID = JX004.Contract_Billing_Group_ID

		left outer Join dbo.FB_Client_Contract_Billed_To JX006 on JX006.Client_CB_ID = JX004.Client_CB_ID
		left outer Join dbo.FB_Client_CB_Split JX007 on JX007.Client_Contract_Billed_To_ID = JX006.Client_Contract_Billed_To_ID
		left outer Join dbo.Organisation JX008 on JX007.Organisation_ID = JX008.Organisation_ID

		left outer join dbo.Funding_Program JX009 on JX009.Funding_Prog_Code = JX001.Funding_Prog_Code

		left outer join dbo.FB_Client_Contract_Bill_Item JX010 on JX010.Client_CB_ID = JX004.Client_CB_ID
		left outer join dbo.FC_Product_Mapping JX011 on JX011.task_Type_Code = JX003.Task_Type_Code
		Left outer join dbo.FB_Contract_Billing_Item_UOM JX012 on JX012.Product_Mapping_ID = JX011.Product_Mapping_ID
		inner join dbo.FB_Contract_Billing_Item JX013 on JX013.Contract_Billing_Item_ID = JX012.Contract_Billing_Item_ID and JX013.Contract_Billing_Item_ID = JX010.Contract_Billing_Item_ID

		left outer join dbo.Service_Type JX014 on JX014.Service_Type_Code = JX001.Service_Type_Code

	)J009 on 
		J009.Client_ID = J001.Client_ID
		and J009.Task_Type_Code = J001.Task_Type_Code
		and J009.CAP_ID = J001.CAP_ID
		and J001.Visit_Date between J009.Billing_Start_Date and IIF(J009.Billing_End_Date is null,Cast('2200-01-01' as date),J009.Billing_End_Date)
		and J001.Visit_Date between J009.From_Date and IIF(J009.To_Date is null,Cast('2200-01-01' as date),J009.To_Date)
		and J001.Visit_Date between J009.Effective_From_Date and IIF(J009.Effective_to_Date is null,Cast('2200-01-01' as date),J009.Effective_to_Date)
		and J001.Visit_Date between J009.Billed_to_efFrom and IIF(J009.Billed_to_efTo is null,Cast('2200-01-01' as date),J009.Billed_to_efTo)

	left outer join dbo.FC_Contract_Area_Product J010 ON J010.CAP_ID = J001.CAP_ID
	left outer join dbo.FC_Funder_Contract J011 ON J011.Funder_Contract_ID = J010.Funder_Contract_ID
	Left outer join dbo.Visit_Cancel_Reason J014 on J014.Visit_Cancel_Reason_ID = J001.Visit_Cancel_Reason_ID
	Where 
		1=1
		and @DuplicateChargeItem = 0
--		and J001.Client_ID = @Client_ID_
		and J006.Organisation_Name = @Organisation
		and 1 = Case 
				when cast(J001.Visit_Date AS date) between @StartDate and @EndDate then 1
				When @FiltType = 1 and cast(J001.Billed_Date as date) between  @StartDate and @EndDate then 1
				else 0
				end
		and (J009.Contract_Billing_Group <> 'DCSI' or J009.Contract_Billing_Group is null)
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

Union
--*/
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------In Wi_Activity ONLY

select * from
(
	select distinct
		J001.Client_ID
		,J001.WiA_Provider_ID 'Provider_ID'
		,IIF(J001.WiA_Schedule_TimeKILL = 'true', null, Cast (J001.WiA_Schedule_Time as Datetime)) 'Schedule_Visit_Time'	
		,J001.WiA_Scheduled_Duration 'Scheduled_Duration'
		,(Cast (J001.AcS_Activity_Start_Time as Datetime)) 'Actual_Visit_Time'
		,J001.AcS_Visit_Duration as 'Actual_Duration'
		,IIF (J011.Description is NULL,'No Contract',J011.Description) 'contract_type'
		,J004.Description 'task_Description'
		,J001.Actual_TaskCode
		,J001.Schedule_TaskCode
		,J014.Description 'Client_Not_Home'
		,IIF (J002.Client_ID IS NULL, 0, 1) 'Has_Charge_Item'
		,IIF (J001.Client_ID_Ac_S IS NULL, 1, 0) 'In_WiA_Only'
		,J002.Line_Description 'Charge_Item_Line_Description'
		,J002.Amount
		,IIF(J009.Organisation_Name = 'NDIA National Disability Insurance Agency', 'NDIS funded',IIF(J009.Client_ID IS NULL,'No Contract Billing','Self Managed')) 'Funding_Type'
		,J009.FundingProgram--new
		,J001.Billed_Date
		,1 'AdjustmentType'
		,0 'lateData'
		,0 'AdjFix'
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
			,Ac_S.Client_ID 'Client_ID_Ac_S'
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
			,Ac_S.Visit_Cancel_Reason_ID
			,Ac_S.Visit_Date 'AcS_Visit_Date'
			,Ac_S.Visit_No 'Visit_No'
			,Ac_S.Billed_Date
			,IIF(Ac_S.Task_Type_Code is null,Wi_A.Schedule_Task_Type, Ac_S.Task_Type_Code) 'Task_Type_Code'
			,Wi_A.CAP_ID 'CAP_ID'
			,Wi_A.Absence_Code
			,IIF(Ac_S.Visit_Date is null,Wi_A.Activity_Date,Ac_S.Visit_Date)'BKP_date'
			,Wi_A.Schedule_Task_Type 'Schedule_TaskCode'
			,Ac_S.Task_Type_Code 'Actual_TaskCode'
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
				(
					convert(date, Wi_A1.Activity_Date) between dateadd(Day,-3,@StartDate) and dateadd(day,+3,@EndDate)
				--	or 1 = IIF(@FiltType = 1 and (cast(Wi_A1.Activity_Date AS date) between @Min_Date and @Max_Date),1,0)
				)
				and @DuplicateChargeItem = 0
				
		) Wi_A
		left outer join dbo.Task_Schedule_Allocation TSA on TSA.Schedule_Sequence_No = Wi_A.Schedule_Sequence_No and TSA.Client_ID = Wi_A.Client_ID
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
			and 
			(
				1 = iif(Ac_S.Client_ID is null and Wi_A.Activity_Date Between TSA.Start_Date and iif(TSA.End_Date is null, cast('2200-01-01' as date),TSA.End_Date),1,0) 
				or Ac_S.Client_ID is not null
			)
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
		where ACSI.Visit_Date between @StartDate and @EndDate
	)J002 ON 
		J002.Client_ID = J001.Client_ID 
		and J002.Visit_Date = J001.AcS_Visit_Date 
		and J002.Visit_No = J001.Visit_No 
		and J002.Service_Prov_Position_ID = J001.AcS_SPPID

	Left outer Join dbo.Task_Type J004 on J004.Task_Type_Code = J001.Task_Type_Code

	Left outer join
	(
		select
		JX001.Service_Prov_Position_ID 'SPPID'
		,JX002.Organisation_Name
		From dbo.Service_Provision_Position JX001
		left outer join dbo.Organisation JX002 on JX002.Organisation_ID = JX001.Centre_ID
	)J006 on J006.SPPID = J001.WiA_SPPID

	left outer Join
	(
		select 
			JX001.Client_ID
			,JX001.From_Date
			,JX001.To_Date
			,JX009.Description 'FundingProgram'
			,JX002.CAP_ID
			,JX002.Funding_Prog_Code
			,JX014.Service_Type_Code
			,JX011.Task_Type_Code
			,JX004.Billing_Start_Date
			,JX004.Billing_End_Date
			,JX004.Contract_Billing_ID
			,JX004.Client_CB_ID
			,JX006.Effective_From_Date 'Billed_to_efFrom'
			,JX006.Effective_To_Date 'Billed_to_efTo'
			,JX005.Description 'Contract_Billing_Group'
			,JX008.Organisation_Name
			,JX010.Effective_From_Date
			,JX010.Effective_to_Date
		from dbo.Service_Delivery JX001
		inner join dbo.FC_Contract_Area_Product JX002 on JX002.Funding_Prog_Code = JX001.Funding_Prog_Code
		inner join dbo.Task_Type JX003 on JX003.Service_Type_Code = JX001.Service_Type_Code
		Left outer join dbo.FB_Client_Contract_Billing JX004 on JX004.Client_ID = JX001.Client_ID and JX004.Funder_Contract_ID = JX002.Funder_Contract_ID --connect to billing item
		left outer join dbo.FB_Contract_Billing_Group JX005 on JX005.Contract_Billing_Group_ID = JX004.Contract_Billing_Group_ID

		left outer Join dbo.FB_Client_Contract_Billed_To JX006 on JX006.Client_CB_ID = JX004.Client_CB_ID
		left outer Join dbo.FB_Client_CB_Split JX007 on JX007.Client_Contract_Billed_To_ID = JX006.Client_Contract_Billed_To_ID
		left outer Join dbo.Organisation JX008 on JX007.Organisation_ID = JX008.Organisation_ID

		left outer join dbo.Funding_Program JX009 on JX009.Funding_Prog_Code = JX001.Funding_Prog_Code

		left outer join dbo.FB_Client_Contract_Bill_Item JX010 on JX010.Client_CB_ID = JX004.Client_CB_ID
		left outer join dbo.FC_Product_Mapping JX011 on JX011.task_Type_Code = JX003.Task_Type_Code
		Left outer join dbo.FB_Contract_Billing_Item_UOM JX012 on JX012.Product_Mapping_ID = JX011.Product_Mapping_ID
		inner join dbo.FB_Contract_Billing_Item JX013 on JX013.Contract_Billing_Item_ID = JX012.Contract_Billing_Item_ID and JX013.Contract_Billing_Item_ID = JX010.Contract_Billing_Item_ID

		left outer join dbo.Service_Type JX014 on JX014.Service_Type_Code = JX001.Service_Type_Code

	)J009 on 
		J009.Client_ID = J001.Client_ID
		and J009.Task_Type_Code = J001.Task_Type_Code
		and J009.CAP_ID = J001.CAP_ID
		and J001.BKP_date between J009.Billing_Start_Date and IIF(J009.Billing_End_Date is null,Cast('2200-01-01' as date),J009.Billing_End_Date)
		and J001.BKP_date between J009.From_Date and IIF(J009.To_Date is null,Cast('2200-01-01' as date),J009.To_Date)
		and J001.BKP_date between J009.Effective_From_Date and IIF(J009.Effective_to_Date is null,Cast('2200-01-01' as date),J009.Effective_to_Date)
		and J001.BKP_date between J009.Billed_to_efFrom and IIF(J009.Billed_to_efTo is null,Cast('2200-01-01' as date),J009.Billed_to_efTo)

	Left Outer Join dbo.FC_Contract_Area_Product J010 ON J010.CAP_ID = J001.CAP_ID
	LEFT OUTER JOIN dbo.FC_Funder_Contract J011 ON J011.Funder_Contract_ID = J010.Funder_Contract_ID
	Left outer join dbo.Visit_Cancel_Reason J014 on J014.Visit_Cancel_Reason_ID = J001.Visit_Cancel_Reason_ID
	Where 
		1=1
		and @DuplicateChargeItem = 0
--		and J001.Client_ID = @Client_ID_
		and J006.Organisation_Name = @Organisation
		and 1 = iif(J001.RN > 1 and J001.WiA_Provider_ID = 0, 0, 1)
		and convert(date, J001.WiA_Schedule_Time) between @StartDate and @EndDate
		and 1 = Case 
				when cast(J001.WiA_Schedule_Time AS date) between @StartDate and @EndDate then 1
				When @FiltType = 1 and cast(J001.Billed_Date as date) between  @StartDate and @EndDate then 1
				else 0
				end
		and (J009.Contract_Billing_Group Not like '%DCSI%' or J009.Contract_Billing_Group is null)
		and J001.Client_ID IS NOT NULL
		AND (IIF (J011.Description is NULL,'No Contract',J011.Description) in (select * from @ContractType))
--		and (IIF (J011.Description is NULL,'No Contract',J011.Description) in (@ContractType))

)t2
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
--/*
Union

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------Duplicate Charge Items
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
		,null 'Actual_TaskCode'
		,null 'Schedule_TaskCode'
		,null 'Client_Not_Home'
		,2 'Has_Charge_Item'
		,null 'In_WiA_Only'
		,J002.Line_Description 'Charge_Item_Line_Description'
		,J002.Amount
		,IIF(J009.Organisation_Name = 'NDIA National Disability Insurance Agency', 'NDIS funded',IIF(J009.Client_ID IS NULL,'No Contract Billing','Self Managed')) 'Funding_Type'
		,null 'FundingProgram'--new
		,null 'Billed_Date'
		,1 'AdjustmentType'
		,0 'lateData'
		,0 'AdjFix'
	from
	(
		select 
			ACSI.Client_ID	
			,ACSI.FC_Product_ID
			,ACSI.Contract_Billing_Item_ID
			,ACSI.Visit_Date
			,ACSI.Visit_No
			,ACSI.Provider_ID
			,ACSI.Service_Prov_Position_ID
			,ACSI.Amount
			,ACSI.Line_Description
			,row_number()over(partition by ACSI.Client_ID,ACSI.Provider_ID,ACSI.Visit_Date,ACSI.Visit_No,ACSI.Line_Description order by ACSI.Visit_Date,ACSI.Visit_No)'RN'
		from dbo.Actual_Service_Charge_Item ACSI
		where ACSI.Visit_Date between @StartDate and @EndDate

	)J002

	Left outer join
	(
		select
		JX001.Service_Prov_Position_ID 'SPPID'
		,JX002.Organisation_Name
		From dbo.Service_Provision_Position JX001
		left outer join dbo.Organisation JX002 on JX002.Organisation_ID = JX001.Centre_ID
	)J006 on J006.SPPID = J002.Service_Prov_Position_ID

	left outer Join
	(
		select Distinct
			JX004.Client_ID
			,JX105.FC_Product_ID
			,JX104.Contract_Billing_Item_ID
			,JX104.Client_CB_Item_ID
			,JX004.Billing_Start_Date
			,JX004.Billing_End_Date
			,JX004.Contract_Billing_ID
			,JX005.Description 'ContractBillingGroup'
			,JX006.Effective_From_Date 'Billed_to_efFrom'
			,JX006.Effective_To_Date 'Billed_to_efTo'
			,JX008.Organisation_Name
			,JX104.Effective_From_Date
			,JX104.Effective_to_Date
		from dbo.FB_Client_Contract_Billing JX004
		inner join dbo.FB_Client_Contract_Bill_Item JX104 on JX104.Client_CB_ID = JX004.Client_CB_ID
		inner join dbo.FB_Contract_Billing_Item_UOM JX105 on JX105.Contract_Billing_Item_ID = JX104.Contract_Billing_Item_ID
		left outer join dbo.FB_Contract_Billing_Group JX005 on JX005.Contract_Billing_Group_ID = JX004.Contract_Billing_Group_ID
		left outer Join dbo.FB_Client_Contract_Billed_To JX006 on JX006.Client_CB_ID = JX004.Client_CB_ID
		left outer Join dbo.FB_Client_CB_Split JX007 on JX007.Client_Contract_Billed_To_ID = JX006.Client_Contract_Billed_To_ID
		left outer Join dbo.Organisation JX008 on JX007.Organisation_ID = JX008.Organisation_ID
	)J009 on 
		J009.Client_Id = J002.Client_ID
		and J009.FC_Product_ID = J002.FC_Product_ID
		and J009.Contract_Billing_Item_ID = J002.Contract_Billing_Item_ID
		and J002.Visit_Date between J009.Billing_Start_Date and IIF(J009.Billing_End_Date is null,Cast('2200-01-01' as date),J009.Billing_End_Date)
		and J002.Visit_Date between J009.Effective_From_Date and IIF(J009.Effective_to_Date is null,Cast('2200-01-01' as date),J009.Effective_to_Date)
		and J002.Visit_Date between J009.Billed_to_efFrom and IIF(J009.Billed_to_efTo is null,Cast('2200-01-01' as date),J009.Billed_to_efTo)

	where
	J002.RN > 1
--	and J002.Client_ID = @Client_ID_
	and convert(date, J002.Visit_Date) between @StartDate and @EndDate
	and J006.Organisation_Name = @Organisation

)t3
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------

Union

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
-------------------------------------Adjustments
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
		,null 'Actual_TaskCode'
		,null 'Schedule_TaskCode'
		,null 'Client_Not_Home'
		,6 'Has_Charge_Item'
		,null 'In_WiA_Only'
		,J010.Comments 'Charge_Item_Line_Description'
		,J010.Adjustment_Amount 'Amount'
		,IIF(J001.Organisation_Name = 'NDIA National Disability Insurance Agency', 'NDIS funded','Self Managed') 'Funding_Type'
		,null 'FundingProgram'
		,J015.Processing_Date 'Billed_Date'
		,iif(J011.Description like '%eduction%',-1,1)'AdjustmentType'
		,IIF(cast(J010.Effective_From_Date AS date) between @StartDate and @EndDate,0,1) 'lateData'
		,J010.Client_CB_Adj_ID 'AdjFix'
	from
	(
		select distinct
			CCB.Client_ID 'Client_ID'
			,CCB.Client_CB_ID 'Client_CB_ID'
			,CCB.Funder_Contract_ID
			,CBG.Description 'ContractBillingGroup'
			,Org.Organisation_Name
		from dbo.FB_Client_Contract_Billing CCB
			LEFT OUTER JOIN dbo.FB_Contract_Billing_Group CBG on CBG.Contract_Billing_Group_ID = CCB.Contract_Billing_Group_ID
			LEFT OUTER JOIN dbo.FB_Client_Contract_Billed_To CCBT on CCBT.Client_CB_ID = CCB.Client_CB_ID
			LEFT OUTER JOIN dbo.FB_Client_CB_Split CCBS on CCBS.Client_Contract_Billed_To_ID = CCBT.Client_Contract_Billed_To_ID
			LEFT OUTER JOIN dbo.Organisation Org on CCBS.Organisation_ID = Org.Organisation_ID
		where
			1=1
			and (Org.Organisation_Name = 'NDIA National Disability Insurance Agency' or Org.Organisation_Name is null)

	)J001
		
	LEFT OUTER JOIN dbo.FB_Client_CB_Bill_Adjustment J010 ON J010.Client_CB_ID = J001.Client_CB_ID
	LEFT OUTER JOIN dbo.FB_Adjustment_Type J011 ON J011.Adjustment_Type_Code = J010.Adjustment_Type_Code
	left outer join dbo.FC_Funder_Contract J012 ON J012.Funder_Contract_ID = J001.Funder_Contract_ID
	left outer join dbo.GST_Type J014 on J014.GST_Type_Code = J010.GST_Type_Code
	left outer join dbo.FB_Client_CB_Transaction J015 on J015.Client_CB_ID = J010.Client_CB_ID and J015.Client_CB_Adj_ID = J010.Client_CB_Adj_ID

	Where 
		1=1
--		and J001.Client_ID = @Client_ID_
		and @DuplicateChargeItem = 0

		AND (IIF (J012.Description is NULL,'No Contract',J012.Description) in (select * from @ContractType))
--		and (IIF (J012.Description is NULL,'No Contract',J012.Description) in (@ContractType))

		and 1 = Case 
				when cast(J010.Effective_From_Date AS date) between @StartDate and @EndDate then 1
				When @FiltType = 1 and cast(J015.Processing_Date as date) between  @StartDate and @EndDate then 1
				else 0
				end

)t4
--*/
order by
1,3,5,8,2,12
