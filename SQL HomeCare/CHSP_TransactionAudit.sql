/*
select Organisation_Name from dbo.Organisation
where 
	1=1
	and organisation_type_code = 1
	and Organisation_Name like 'Home Care%'

select * from dbo.FC_Funder_Contract
select * from dbo.Organisation where Organisation_Type_Code = 1
*/

use comCareProd

Declare @Client_ID_ as INT = 10000605
DECLARE @StartDate AS Date = '2017-09-19'
DECLARE @EndDate AS DATETIME = '2017-09-19'
Declare @DuplicateChargeItem int = 0
declare @FeeWaver int = 0 -- 0 is omit feewaver clients

declare @Organisation Table (Org VarChar(64))
Insert INTO @Organisation
select Organisation_Name from dbo.Organisation
where 
	1=1
	and organisation_type_code = 1
	and Organisation_Name like 'Home Care%'

Declare @ContractType Table (ContractType varchar(64))
Insert INTO @ContractType 
	select 'No Contract' Description where 1=1
union
select
	Description
from dbo.FC_Funder_Contract
where 
	1=1
	AND (Description like 'CHSP%' or Description = 'Fee for Service' )
order by 1

---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<from here down>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

Declare @NoChargeTasks table (taskTypeCode varchar(16))
insert into @NoChargeTasks values
	('GMHMA')
	,('GECBR')
	,('GECRFS')
	,('GEDA')
	,('GEDAFS')
	,('GEDSI')
	,('GEGEAT')
	,('GEGEFS')
	,('GEHMA')
	,('GEHMAF')
	,('GEHMO')
	,('GEHMOF')
	,('GENU')
	,('GENUFS')
	,('GEPC')
	,('GEPCFS')
	,('GESIFS')
	,('GESSI')
	,('GETR')
	,('GETRFS')
	,('INNFFHCP')
	,('INCBR')
	,('INCRFS')
	,('INDA')
	,('INDAFS')
	,('INGEAT')
	,('INGEFS')
	,('INHCP')
	,('INHMA')
	,('INHMAF')
	,('INHMO')
	,('INHMOF')
	,('INNU')
	,('INNUFS')
	,('INPC')
	,('INPCFS')
	,('INSIFS')
	,('INSSI')
	,('INTR')
	,('INTRFS')
	,('REACH')
	,('RECBR')
	,('RECRFS')
	,('REDA')
	,('REDAFS')
	,('REGEAT')
	,('REGEFS')
	,('RVHCP')
	,('RCHCPF')
	,('REHMA')
	,('REHMAF')
	,('REHMO')
	,('REHMOF')
	,('RENU')
	,('RENUFS')
	,('REPC')
	,('REPCFS')
	,('RESIFS')
	,('RESSI')
	,('RETR')
	,('RETRFS')

select * from
(

	select
		J001.Client_ID
		,J016.Preferred_Name +' '+ J016.Last_Name 'Client_Name'
		,J001.Provider_ID
		,IIF(J033.WiA_Schedule_TimeKILL = 'true', null, Cast (J033.Schedule_Time as Datetime)) 'Schedule_Visit_Time'	
		,J033.Scheduled_Duration
		,(Cast (cast(J001.Visit_Date as date) as Datetime) + Cast (Cast (J001.Visit_Time as Time) as Datetime)) 'Actual_Visit_Time'
		,J001.Visit_Duration 'Actual_Duration'
		,J001.Travel_Km 'Travel_Km'
		,J001.Actual_Intravisit_Travel_Km 'Intravisit_Travel_Km'
		,J001.Units_of_Service
		--new
		,J009.RateClassification
		--end new
		,IIF (J011.Description is NULL,'No Contract',J011.Description) 'contract_type'
		,J004.Description 'task_Description'
		,J014.Description 'Client_Not_Home'
		,IIF (J002.Client_ID IS NULL, IIF(J066.taskTypeCode is null,0,5), 1) 'Has_Charge_Item'
		,convert (int ,'0') 'In_WiA_Only'
		,J002.Line_Description 'Charge_Item_Line_Description'
		,J002.Unit
		,J002.UOM
		,J002.Rate
		,J002.Rate_Type
		,J002.Amount
		,J009.FundingProgram 'FundingProgram'
--		,J001.Service_Prov_Position_ID 'SPPID'
--		,J009.RN 'J009_RowNum'

	from 
	(
		select 
			* 
		from dbo.Actual_Service A_S 
		where 
			convert(date, A_S.Visit_Date) between @StartDate and @EndDate
			and @DuplicateChargeItem = 0
	)J001

	left outer join dbo.FC_Contract_Area_Product J010 ON J010.CAP_ID = J001.CAP_ID
	left outer join dbo.FC_Funder_Contract J011 ON J011.Funder_Contract_ID = J010.Funder_Contract_ID

	Left outer Join
	(
		select 
			ASCI.Client_ID	
			,ASCI.Visit_Date
			,ASCI.Visit_No
			,ASCI.Provider_ID
			,ASCI.Service_Prov_Position_ID
			,ASCI.Amount
			,ASCI.Line_Description
			,ASCI.Rate_Type
			,ASCI.Rate
			,ASCI.Unit
			,UOM.Description 'UOM'
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

		from dbo.Actual_Service_Charge_Item ASCI
		Inner Join dbo.FB_Contract_Billing_Item CBI on ASCI.Contract_Billing_Item_ID = CBI.Contract_Billing_Item_ID
		LEFT OUTER JOIN dbo.FB_Contract_Billing_Rate CBR on ASCI.Contract_Billing_Rate_ID = CBR.Contract_Billing_Rate_ID
		LEFT OUTER JOIN dbo.Unit_of_Measure UOM ON CBR.UOM_Code = UOM.UOM_Code

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
	from (select * from dbo.WI_Activity Wi_A1 where convert(date, Wi_A1.Activity_Date) between dateadd(Day,-3,@StartDate) and dateadd(day,+3,@EndDate)) Wi_A
	left outer join dbo.activity_work_table AWT on AWT.Allocated_Task_ID = Wi_A.Round_Allocation_ID and AWT.activity_date = Wi_A.activity_date
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
						WHEN O.Organisation_Name in (select * from @Organisation) THEN '1'
--						WHEN O.Organisation_Name in (@Organisation) THEN '1'
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
			JX001.Client_ID
			,JX001.From_Date
			,JX001.To_Date
			,JX009.Description 'FundingProgram'--this one only
			,JX002.CAP_ID
			,JX003.Task_Type_Code
			,JX004.Billing_Start_Date
			,JX004.Billing_End_Date
			,JX006.Description 'RateClassification'
		from dbo.Service_Delivery JX001
		inner join dbo.FC_Contract_Area_Product JX002 on JX002.Funding_Prog_Code = JX001.Funding_Prog_Code
		inner join dbo.Task_Type JX003 on JX003.Service_Type_Code = JX001.Service_Type_Code
		Left outer join dbo.FB_Client_Contract_Billing JX004 on JX004.Client_ID = JX001.Client_ID and JX004.Funder_Contract_ID = JX002.Funder_Contract_ID --connect to billing item
		left outer join dbo.FB_Contract_Billing_Group JX005 on JX005.Contract_Billing_Group_ID = JX004.Contract_Billing_Group_ID
		--new
		Left outer join dbo.FB_Billing_Rate_Classification JX006 on JX006.Billing_Rate_Classification_ID = JX004.Billing_Rate_Classification_ID
		--end new
		left outer join dbo.Funding_Program JX009 on JX009.Funding_Prog_Code = JX001.Funding_Prog_Code

	)J009 on 
		J009.Client_ID = J001.Client_ID
		and J009.Task_Type_Code = J001.Task_Type_Code
		and J009.CAP_ID = J001.CAP_ID
		and J001.Visit_Date between J009.Billing_Start_Date and IIF(J009.Billing_End_Date is null,Cast('2200-01-01' as date),J009.Billing_End_Date)
		and J001.Visit_Date between J009.From_Date and IIF(J009.To_Date is null,Cast('2200-01-01' as date),J009.To_Date)


	

	Left outer join @NoChargeTasks J066 on J066.taskTypeCode = J001.Task_Type_Code-------------------NEW
	Left outer join dbo.Visit_Cancel_Reason J014 on J014.Visit_Cancel_Reason_ID = J001.Visit_Cancel_Reason_ID
	left outer join dbo.Person J016 on J016.Person_ID = J001.Client_ID

	Where 
		1=1
		and (J002.RN < 2 or J002.RN is null)
		and @DuplicateChargeItem = 0
--		and J001.Client_ID = @Client_ID_
		and J006.Organisation_Name in (select * from @Organisation)
--		and J006.Organisation_Name in (@Organisation)
		and convert (Date, J001.Visit_Date) between @StartDate and @EndDate
		AND (IIF (J011.Description is NULL,'No Contract',J011.Description) in (select * from @ContractType))
--		and (IIF (J011.Description is NULL,'No Contract',J011.Description) in (@ContractType))
		
		and 1 = (iif (J009.RateClassification = '0% of Standard Fee' or J009.RateClassification = '100% Fee Reduction',@FeeWaver,1))

) t1

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

select Distinct * from
(
	select
		J001.Client_ID
		,J016.Preferred_Name +' '+ J016.Last_Name 'Client_Name'
		,J001.WiA_Provider_ID 'Provider_ID'
		,IIF(J001.WiA_Schedule_TimeKILL = 'true', null, Cast (J001.WiA_Schedule_Time as Datetime)) 'Schedule_Visit_Time'	
		,J001.WiA_Scheduled_Duration 'Scheduled_Duration'
		,(Cast (J001.AcS_Activity_Start_Time as Datetime)) 'Actual_Visit_Time'
		,J001.AcS_Visit_Duration as 'Actual_Duration'
		,J001.Travel_Km 'Travel_Km'
		,J001.Actual_Intravisit_Travel_Km 'Intravisit_Travel_Km'
		,J001.Units_of_Service
		--new
		,J009.RateClassification
		--end new
		,IIF (J011.Description is NULL,'No Contract',J011.Description) 'contract_type'
		,J004.Description 'task_Description'
		,J014.Description 'Client_Not_Home'
		,IIF (J002.Client_ID IS NULL, IIF(J066.taskTypeCode is null,0,5), 1) 'Has_Charge_Item'
		,IIF (J001.Client_ID_Ac_S IS NULL, 1, 0) 'In_WiA_Only'
		,J002.Line_Description 'Charge_Item_Line_Description'
		,J002.Unit
		,J002.UOM
		,J002.Rate
		,J002.Rate_Type
		,J002.Amount
		,J009.FundingProgram 'FundingProgram'
--		,J001.WiA_SPPID 'SPPID'
--		,J009.RN 'J009_RowNum'

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
			,IIF(Ac_S.Task_Type_Code is null,Wi_A.Schedule_Task_Type, Ac_S.Task_Type_Code) 'Task_Type_Code'
			,Wi_A.CAP_ID 'CAP_ID'
			,Wi_A.Absence_Code
			,Ac_S.Travel_Km
			,Ac_S.Actual_Intravisit_Travel_Km
			,Ac_S.Units_of_Service
			,IIF(Ac_S.Visit_Date is null,Wi_A.Activity_Date,Ac_S.Visit_Date)'BKP_date'
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

	Left Outer Join dbo.FC_Contract_Area_Product J010 ON J010.CAP_ID = J001.CAP_ID
	LEFT OUTER JOIN dbo.FC_Funder_Contract J011 ON J011.Funder_Contract_ID = J010.Funder_Contract_ID

	Left outer Join
	(
		select 
			ASCI.Client_ID	
			,ASCI.Visit_Date
			,ASCI.Visit_No
			,ASCI.Provider_ID
			,ASCI.Service_Prov_Position_ID
			,ASCI.Amount
			,ASCI.Line_Description
			,ASCI.Rate_Type
			,ASCI.Rate
			,ASCI.Unit
			,UOM.Description 'UOM'
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

		from dbo.Actual_Service_Charge_Item ASCI
		Inner Join [dbo].[FB_Contract_Billing_Item] CBI on ASCI.Contract_Billing_Item_ID = CBI.Contract_Billing_Item_ID
		LEFT OUTER JOIN [dbo].[FB_Contract_Billing_Rate] CBR on ASCI.Contract_Billing_Rate_ID = CBR.Contract_Billing_Rate_ID
		LEFT OUTER JOIN [dbo].[Unit_of_Measure] UOM ON CBR.[UOM_Code] = UOM.[UOM_Code]

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
						WHEN O.Organisation_Name in (select * from @Organisation) THEN '1'
--						WHEN O.Organisation_Name in (@Organisation) THEN '1'
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
			JX001.Client_ID
			,JX001.From_Date
			,JX001.To_Date
			,JX009.Description 'FundingProgram'--this one only
			,JX002.CAP_ID
			,JX003.Task_Type_Code
			,JX004.Billing_Start_Date
			,JX004.Billing_End_Date
			,JX006.Description 'RateClassification'
		from dbo.Service_Delivery JX001
		inner join dbo.FC_Contract_Area_Product JX002 on JX002.Funding_Prog_Code = JX001.Funding_Prog_Code
		inner join dbo.Task_Type JX003 on JX003.Service_Type_Code = JX001.Service_Type_Code
		Left outer join dbo.FB_Client_Contract_Billing JX004 on JX004.Client_ID = JX001.Client_ID and JX004.Funder_Contract_ID = JX002.Funder_Contract_ID --connect to billing item
		left outer join dbo.FB_Contract_Billing_Group JX005 on JX005.Contract_Billing_Group_ID = JX004.Contract_Billing_Group_ID
		--new
		Left outer join dbo.FB_Billing_Rate_Classification JX006 on JX006.Billing_Rate_Classification_ID = JX004.Billing_Rate_Classification_ID
		--end new
		left outer join dbo.Funding_Program JX009 on JX009.Funding_Prog_Code = JX001.Funding_Prog_Code

	)J009 on 
		J009.Client_ID = J001.Client_ID
		and J009.Task_Type_Code = J001.Task_Type_Code
		and J009.CAP_ID = J001.CAP_ID
		and J001.BKP_date between J009.Billing_Start_Date and IIF(J009.Billing_End_Date is null,Cast('2200-01-01' as date),J009.Billing_End_Date)
		and J001.BKP_date between J009.From_Date and IIF(J009.To_Date is null,Cast('2200-01-01' as date),J009.To_Date)
	
	

	Left outer join @NoChargeTasks J066 on J066.taskTypeCode = J001.Task_Type_Code
	Left outer join dbo.Visit_Cancel_Reason J014 on J014.Visit_Cancel_Reason_ID = J001.Visit_Cancel_Reason_ID
	left outer join dbo.Person J016 on J016.Person_ID = J001.Client_ID
	Where 
		1=1
		and (J002.RN < 2 or J002.RN is null)
		and @DuplicateChargeItem = 0
--		and J001.Client_ID = @Client_ID_
		and J006.Organisation_Name in (select * from @Organisation)
--		and J006.Organisation_Name in (@Organisation)
		and 1 = iif(J001.RN > 1 and J001.WiA_Provider_ID = 0, 0, 1)
		and (J006.RN < 2 or J006.RN is null)
		and J001.Client_ID IS NOT NULL
		and convert (Date, J001.BKP_date) between @StartDate and @EndDate

		AND (IIF (J011.Description is NULL,'No Contract',J011.Description) in (select * from @ContractType))
--		and (IIF (J011.Description is NULL,'No Contract',J011.Description) in (@ContractType))
		
		and 1 = (iif (J009.RateClassification = '0% of Standard Fee' or J009.RateClassification = '100% Fee Reduction',@FeeWaver,1))

)t2
--/*
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
------------------------------------new section ported over from
Union
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
select * from
(
	select
		J002.Client_ID
		,J016.Preferred_Name +' '+ J016.Last_Name 'Client_Name'
		,J002.Provider_ID 
		,cast(J002.Visit_Date as datetime) 'Schedule_Visit_Time'
		,null 'Scheduled_Duration' 
		,null 'Actual_Visit_Time'
		,null 'Actual_Duration'
		,null 'Travel_Km'
		,null 'Intravisit_Travel_Km'
		,null 'Units_of_Service'
		,J012.RateClassification
		,J012.Description 'contract_type'
		,'---' 'task_Description'
		,null 'Client_Not_Home'
		,2 'Has_Charge_Item'
		,null 'In_WiA_Only'
		,J002.Line_Description 'Charge_Item_Line_Description'
		,J002.Unit
		,J002.UOM
		,J002.Rate
		,J002.Rate_Type
		,J002.Amount 
		,null 'FundingProgram'
--		,J002.Service_Prov_Position_ID
--		,null 'J009_RowNum'

	from
	(
		select 
			ASCI.Client_ID	
			,ASCI.Visit_Date
			,ASCI.Visit_No
			,ASCI.Provider_ID
			,ASCI.Service_Prov_Position_ID
			,ASCI.Amount
			,ASCI.Line_Description
			,ASCI.Rate_Type
			,ASCI.Rate
			,ASCI.Unit
			,UOM.Description 'UOM'
			,ASCI.FC_Product_ID
			,ASCI.Contract_Billing_Item_ID
			,row_number()over(partition by ASCI.Client_ID,ASCI.Provider_ID,ASCI.Visit_Date,ASCI.Visit_No,ASCI.Line_Description order by ASCI.Visit_Date,ASCI.Visit_No)'RN'
		from dbo.Actual_Service_Charge_Item ASCI
		Inner Join [dbo].[FB_Contract_Billing_Item] CBI on ASCI.Contract_Billing_Item_ID = CBI.Contract_Billing_Item_ID
		LEFT OUTER JOIN [dbo].[FB_Contract_Billing_Rate] CBR on ASCI.Contract_Billing_Rate_ID = CBR.Contract_Billing_Rate_ID
		LEFT OUTER JOIN [dbo].[Unit_of_Measure] UOM ON CBR.[UOM_Code] = UOM.[UOM_Code]

	)J002

	Left outer join
	(
		select
		JX001.Service_Prov_Position_ID 'SPPID'
		,JX002.Organisation_Name
		From dbo.Service_Provision_Position JX001
		left outer join dbo.Organisation JX002 on JX002.Organisation_ID = JX001.Centre_ID
	)J006 on J006.SPPID = J002.Service_Prov_Position_ID

	
	Left outer join
	(
		select distinct
		CCBI.Contract_Billing_Item_ID
		,FC.Description
		,CCB.Client_ID
		,BRC.Description 'RateClassification'
		,CCB.Billing_Rate_Classification_ID
		from dbo.FB_Client_Contract_Bill_Item CCBI
		left outer join dbo.FB_Client_Contract_Billing CCB on CCB.Client_CB_ID = CCBI.Client_CB_ID 
		left outer join dbo.FC_Funder_Contract FC on FC.Funder_Contract_ID = CCB.Funder_Contract_ID
		--new
		Left outer join dbo.FB_Billing_Rate_Classification BRC on BRC.Billing_Rate_Classification_ID = CCB.Billing_Rate_Classification_ID
		--end new
	)J012 on J012.Contract_Billing_Item_ID = J002.Contract_Billing_Item_ID and J012.Client_ID = J002.Client_ID

	left outer join dbo.FC_Product_Mapping J013 on J013.FC_Product_ID = J002.FC_Product_ID and J013.Effective_To_Date is null-- J013.task_Type_code like '%HCP%'
	left outer join dbo.Person J016 on J016.Person_ID = J002.Client_ID

	where
	J002.RN > 1
--	and J002.Client_ID = @Client_ID_
	and convert(date, J002.Visit_Date) between @StartDate and @EndDate
	and J006.Organisation_Name in (select * from @Organisation)
--	and J006.Organisation_Name in (@Organisation)
	AND (IIF (J012.Description is NULL,'No Contract',J012.Description) in (select * from @ContractType))
--	and (IIF (J012.Description is NULL,'No Contract',J012.Description) in (@ContractType))
	and J013.Task_Type_Code not like '%HCP%'

	and 1 = (iif (J012.RateClassification = '0% of Standard Fee' or J012.RateClassification = '100% Fee Reduction',@FeeWaver,1))
)t3

--*/
order by
1,3,5,9,2,14


