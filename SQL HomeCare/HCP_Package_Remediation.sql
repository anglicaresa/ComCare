/*
select * from [dbo].Actual_Service
where Travel_KM > 0 and Travel_KM is not null

select * from [dbo].wi_activity
where Round_Allocation_ID <> 0 and sppid = 191 and provider_ID = 10012649

select * from dbo.FC_Transaction-- where Client_ID = 10019493
10019493
*/

use ComCareProd

Declare @Client_ID_ as INT = 10019493
DECLARE @StartDate AS DATETIME = '20160102 00:00:00.000'
DECLARE @EndDate AS DATETIME = '20180115 00:00:00.000'

--Declare @Organisation Varchar(128) = 'Home Care West'
Declare @Organisation Varchar(128) = 'Southern Care at Home'

Declare @ContractType Table (ContractType varchar(64))
Insert INTO @ContractType
	select 'No Contract' Description where 1=1
union
select
	Description
from [dbo].[FC_Funder_Contract]
where
	1=1
	AND (Description like '%Care at Home')
order by 1

declare @GroupActivity varchar(128) = 'HideGroupActivity'

---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
--/*
select * from
(
	select
		J001.Client_ID 'Client_ID'
		,J001.Provider_ID 'Provider_ID'
		,IIF(J033.WiA_Schedule_TimeKILL = 'true', null, Cast (J033.Schedule_Time as Datetime)) 'Schedule_Visit_Time'	
		,J033.Scheduled_Duration 'Scheduled_Duration'
		,(Cast (cast(J001.Visit_Date as date) as Datetime) + Cast (Cast (J001.Visit_Time as Time) as Datetime)) 'Actual_Visit_Time'
		,J001.Visit_Duration 'Actual_Duration'
		,J088.CareModel 'CareModel'
		,J004.[Description] 'task_Description'
		,J001.Client_Not_Home 'Client_Not_Home'
		,IIF (J002.Client_ID IS NULL, 0, 1) 'Has_Charge_Item'
		,convert (int ,'0') 'In_WiA_Only'
		,J002.Line_Description 'Charge_Item_Line_Description'
		,J002.Amount 'Amount'
		,J088.funderContract 'funderContract'
		,iif(J001.Group_Activity_ID is Null, 0, 1) 'HasGroupActivity'
		,J001.Travel_Km 'Travel_Km'

	from [dbo].Actual_Service J001

	Left outer Join
	(
		select
			FC_CC.Client_ID 'Client_ID'
			,FC_T.Visit_Date 'Visit_Date'
			,FC_T.Comments 'Line_Description'
			,cast ((select Text from dbo.Split(FC_T.Source_Record_Key, '/') where Record_Number = 3) as int) 'Visit_No'
			,cast ((select Text from dbo.Split(FC_T.Source_Record_Key, '/') where Record_Number = 5) as int) 'Service_Prov_Position_ID'
			,cast ((select Text from dbo.Split(FC_T.Source_Record_Key, '/') where Record_Number = 4) as int) 'Provider_ID'
			,(FC_T.Actual_Amount * -1.0) 'Amount'
			,FC_FC.Description 'funderContract'
			,FC_FCM.Description 'CareModel'
		from [dbo].FC_Client_Contract FC_CC
		Left outer Join [dbo].FC_Funder_Contract FC_FC	on FC_FC.funder_Contract_ID = FC_CC.funder_Contract_ID
		Left outer Join [dbo].FC_Funding_Care_Model FC_FCM on FC_FCM.Funding_Care_Model_ID = FC_FC.Funding_Care_Model_ID
		Left outer join [dbo].FC_Account FC_A on FC_A.client_Contract_ID = FC_CC.client_Contract_ID

		Left outer join 
		(
			select
				FC_T.FC_Account_ID 'FC_Account_ID'
				,FC_T.FC_Transaction_Type_ID 'FC_Transaction_Type_ID'
				,FC_T.Activity_Date 'Visit_Date'
				,FC_T.Transaction_Source 'Transaction_Source'
				,FC_T.Estimated_Amount 'Estimated_Amount'
				,FC_T.Actual_Amount 'Actual_Amount'
				,FC_T.Balance_After_Txn 'Balance_After_Txn'
				,FC_T.Source_Table 'Source_Table'
				,FC_T.Source_Record_Key 'Source_Record_Key'
				,FC_T.Comments 'Comments'
				,ROW_NUMBER() over(
									partition by FC_T.FC_Account_ID, FC_T.Activity_Date
									order by 
									case
									when FC_T.Actual_Amount = 0.0 then 'zzzz'
									else 
									FC_T.Actual_Amount
									end desc
								)'RN'
			from dbo.FC_Transaction FC_T
			where 
				1=1
				and FC_T.FC_Transaction_Type_ID = 3
				and FC_T.Actual_Amount <> 0.0

		)FC_T on FC_T.FC_Account_ID = FC_A.FC_Account_ID

	)J002 ON 
			J002.Client_ID = J001.Client_ID 
			and J002.Visit_Date = J001.Visit_Date 
			and J002.Visit_No = J001.Visit_No
			and J002.Service_Prov_Position_ID = J001.Service_Prov_Position_ID
			and J002.Provider_ID = J001.Provider_ID


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
		left outer join [dbo].activity_work_table AWT on AWT.Allocated_Task_ID = Wi_A.Round_Allocation_ID and AWT.activity_date = Wi_A.activity_date
	)J033 ON 
		J033.Client_ID = J001.Client_ID 
		and J033.Activity_Date = J001.Visit_Date 
		and J033.SPPID = J001.Service_Prov_Position_ID 
		and (J001.Allocated_Task_ID = J033.Allocated_Task_ID or J001.Allocated_Task_ID = J033.Round_Allocation_ID)
	
	Left outer Join
	(
		select
			FC_CC.Client_ID 'Client_ID'
			,FC_FC.Description 'funderContract'
			,FC_FCM.Description 'CareModel'
		from dbo.FC_Client_Contract FC_CC
		Left outer Join dbo.FC_Funder_Contract FC_FC	on FC_FC.funder_Contract_ID = FC_CC.funder_Contract_ID
		Left outer Join dbo.FC_Funding_Care_Model FC_FCM on FC_FCM.Funding_Care_Model_ID = FC_FC.Funding_Care_Model_ID

	)J088 on J088.Client_ID = J001.Client_ID	

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
					Partition by SD.[Client_ID] Order by
						CASE
						WHEN O.Organisation_Name = @Organisation THEN '1'
						ELSE O.Organisation_Name END ASC
				)'RN'
		from [dbo].[Service_Delivery] SD
			join [dbo].Period_of_Residency PR on PR.Person_ID = SD.Client_ID
			join [dbo].[Address] A on A.Address_ID = PR.Address_ID
			Join [dbo].Service_Provision SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
			Join [dbo].[Organisation] O on Sp.Centre_ID = O.Organisation_ID
		Where PR.To_Date is null and PR.Display_Indicator  = 1
	) J006 ON J006.[Client_ID] = J001.[Client_ID] AND J006.[Service_Type_Code] = J005.[Service_Type_Code]

	left outer Join
	(
		select
			CCB.[Client_ID] 'Client_ID'
			,Org.[Organisation_Name] 'Organisation_Name'
			,CBG.[Description] 'ContractBillingGroup'
			,CCB.Contract_Billing_ID 'Contract_Billing_ID'
			,ROW_NUMBER ()
				over 
				(
					Partition by CCB.[Client_ID] Order by
						CASE
						WHEN Org.[Organisation_Name] = @Organisation THEN '1'
						ELSE Org.[Organisation_Name] END ASC
				) 'RN'
		from [dbo].[FB_Client_Contract_Billing] CCB
			left outer join [dbo].[FB_Contract_Billing_Group] CBG on CBG.[Contract_Billing_Group_ID] = CCB.[Contract_Billing_Group_ID]
			left outer Join [dbo].[FB_Client_Contract_Billed_To] CCBT on CCBT.[Client_CB_ID] = CCB.[Client_CB_ID]
			left outer Join [dbo].[FB_Client_CB_Split] CCBS on CCBS.[Client_Contract_Billed_To_ID] = CCBT.[Client_Contract_Billed_To_ID]
			left outer Join [dbo].[Organisation] Org on CCBS.[Organisation_ID] = Org.[Organisation_ID]

	)J009 on J009.[Client_ID] = J001.[Client_ID]

	left outer join [dbo].[FC_Contract_Area_Product] J010 ON J010.[CAP_ID] = J001.[CAP_ID]
	left outer join [dbo].[FC_Funder_Contract] J011 ON J011.[Funder_Contract_ID] = J010.[Funder_Contract_ID]

	Where 
		1=1
--		and J001.Client_ID = @Client_ID_
		and (J006.RN < 2 or J006.RN is NULL)
		and (J009.RN < 2 or J009.rn is null)
		and convert (datetime, J001.Visit_Date) between @StartDate and (DATEADD(s, 84599, @EndDate))
		and J088.CareModel = 'Home Care Package'
		

		and J006.[Organisation_Name] = @Organisation
		AND (IIF (J088.funderContract is NULL,'No Contract',J088.funderContract) in (select * from @ContractType))
--		and (IIF (J088.funderContract is NULL,'No Contract',J088.funderContract) in (@ContractType))

) t1

--group Activity filter

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
--*/
--/*
Union

---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
--/*
select * from
(
	select
		J001.Client_ID 'Client_ID'
		,J001.WiA_Provider_ID 'Provider_ID'
		,IIF(J001.WiA_Schedule_TimeKILL = 'true', null, Cast (J001.WiA_Schedule_Time as Datetime)) 'Schedule_Visit_Time'	
		,J001.WiA_Scheduled_Duration 'Scheduled_Duration'
		,(Cast (J001.AcS_Activity_Start_Time as Datetime)) 'Actual_Visit_Time'
		,J001.AcS_Visit_Duration 'Actual_Duration'
		,J088.CareModel 'CareModel'
		,J004.[Description] 'task_Description'
		,J001.Client_Not_Home 'Client_Not_Home'
		,IIF (J002.Client_ID IS NULL, 0, 1) 'Has_Charge_Item'
		,IIF (J001.Client_Not_Home IS NULL, 1, 0) 'In_WiA_Only'
		,J002.Line_Description 'Charge_Item_Line_Description'
		,J002.Amount 'Amount'
		,J088.funderContract 'funderContract'
		,iif(J001.Group_Activity_ID is Null, 0, 1) 'HasGroupActivity'
		,J001.Travel_Km 'Travel_Km'
	FROM 
	(
		Select
			IIF(Ac_S.Activity_Start_Time IS NULL, 'FALSE', 'TRUE') 'In_Actual_Service'
			,Wi_A.SPPID 'WiA_SPPID'
			,Ac_S.Service_Prov_Position_ID 'AcS_SPPID'
			,Ac_S.Provider_ID 'AcS_Provider_ID'
			,Wi_A.[Activity_Date] 'WiA_Activity_Date'
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
			,IIF(Ac_S.Task_Type_Code is null,Wi_A.Schedule_Task_Type, Ac_S.Task_Type_Code) 'Task_Type_Code'
			,Wi_A.[CAP_ID] 'CAP_ID'
			,Wi_A.[Absence_Code]
			,Wi_A.Group_Activity_ID 'Group_Activity_ID'
			,AC_S.Travel_Km 'Travel_Km'
			,ROW_NUMBER () -- sort by importance of 'covered' 'absent' and 'Un-Alocated'.
			over 
			(
				Partition by Wi_A.Client_ID, Wi_A.[Activity_Date], Wi_A.[SPPID], Wi_A.Schedule_Time
				 Order by 
					Case
						when ((Wi_A.[Provider_ID] > 0) and (Wi_A.[Absence_Code] is NULL)) then '1'
						when (Wi_A.[Provider_ID] > 0) and (Wi_A.[Absence_Code] is not NULL) then '2'
					else 'z'
				end
			) AS 'RN'
		from dbo.WI_Activity Wi_A
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
			FC_CC.Client_ID 'Client_ID'
			,FC_T.Visit_Date 'Visit_Date'
			,FC_T.Comments 'Line_Description'
			,cast ((select Text from dbo.Split(FC_T.Source_Record_Key, '/') where Record_Number = 3) as int) 'Visit_No'
			,cast ((select Text from dbo.Split(FC_T.Source_Record_Key, '/') where Record_Number = 5) as int) 'Service_Prov_Position_ID'
			,cast ((select Text from dbo.Split(FC_T.Source_Record_Key, '/') where Record_Number = 4) as int) 'Provider_ID'
			,(FC_T.Actual_Amount * -1.0) 'Amount'
			,FC_FC.Description 'funderContract'
			,FC_FCM.Description 'CareModel'
		from [dbo].FC_Client_Contract FC_CC
		Left outer Join [dbo].FC_Funder_Contract FC_FC	on FC_FC.funder_Contract_ID = FC_CC.funder_Contract_ID
		Left outer Join [dbo].FC_Funding_Care_Model FC_FCM on FC_FCM.Funding_Care_Model_ID = FC_FC.Funding_Care_Model_ID
		Left outer join [dbo].FC_Account FC_A on FC_A.client_Contract_ID = FC_CC.client_Contract_ID
		

		Left outer join 
		(
			select 
				FC_T.FC_Account_ID 'FC_Account_ID'
				,FC_T.FC_Transaction_Type_ID 'FC_Transaction_Type_ID'
				,FC_T.Activity_Date 'Visit_Date'
				,FC_T.Transaction_Source 'Transaction_Source'
				,FC_T.Estimated_Amount 'Estimated_Amount'
				,FC_T.Actual_Amount 'Actual_Amount'
				,FC_T.Balance_After_Txn 'Balance_After_Txn'
				,FC_T.Source_Table 'Source_Table'
				,FC_T.Source_Record_Key 'Source_Record_Key'
				,FC_T.Comments 'Comments'
				,ROW_NUMBER() over(
									partition by FC_T.FC_Account_ID, FC_T.Activity_Date
									order by 
									case
									when FC_T.Actual_Amount = 0.0 then 'zzzz'
									else 
									FC_T.Actual_Amount --desc
									end desc
								)'RN'
			from [dbo].FC_Transaction FC_T
			where 
				1=1
				and FC_T.FC_Transaction_Type_ID = 3
				and FC_T.Actual_Amount <> 0.0

		)FC_T on FC_T.FC_Account_ID = FC_A.FC_Account_ID

	)J002 ON 
			J002.Client_ID = J001.Client_ID 
			and J002.Visit_Date = J001.AcS_Visit_Date 
			and J002.Visit_No = J001.Visit_No
			and J002.Service_Prov_Position_ID = J001.AcS_SPPID
			and J002.Provider_ID = J001.AcS_Provider_ID

	Left outer Join
	(
		select
			FC_CC.Client_ID 'Client_ID'
			,FC_FC.Description 'funderContract'
			,FC_FCM.Description 'CareModel'
		from [dbo].FC_Client_Contract FC_CC
		Left outer Join [dbo].FC_Funder_Contract FC_FC	on FC_FC.funder_Contract_ID = FC_CC.funder_Contract_ID
		Left outer Join [dbo].FC_Funding_Care_Model FC_FCM on FC_FCM.Funding_Care_Model_ID = FC_FC.Funding_Care_Model_ID

	)J088 on J088.Client_ID = J001.Client_ID

	Left outer Join [dbo].[Task_Type] J004 on J004.Task_Type_Code = J001.Task_Type_Code
	Left Outer Join [dbo].[Service_Delivery] J005 ON J001.[Client_ID] = J005.[Client_ID]

	Left outer JOIN 
	(
		Select 
			SD.[Client_ID]
			,O.[Organisation_Name]
			,SD.[Service_Type_Code]
			,ROW_NUMBER ()
				over 
				(
					Partition by SD.[Client_ID] Order by
						CASE
						WHEN O.[Organisation_Name] = @Organisation THEN '1'
						ELSE O.[Organisation_Name] END ASC
				) AS 'RN'
		from [dbo].[Service_Delivery] SD
			join [dbo].[Period_of_Residency] PR on PR.Person_ID = SD.Client_ID
			join [dbo].[Address] A on A.Address_ID = PR.Address_ID
			Join [dbo].[Service_Provision] SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
			Join [dbo].[Organisation] O on Sp.Centre_ID = O.Organisation_ID
		Where PR.To_Date is null and PR.Display_Indicator  = 1
	) J006 ON J006.[Client_ID] = J001.[Client_ID] AND J006.[Service_Type_Code] = J005.[Service_Type_Code]

	Left outer Join
	(
		select
			CCB.[Client_ID] 'Client_ID'
			,Org.[Organisation_Name] 'Organisation_Name'
			,CBG.[Description] 'ContractBillingGroup'
			,ROW_NUMBER ()
				over 
				(
					Partition by CCB.[Client_ID] Order by
						CASE
						WHEN Org.[Organisation_Name] = @Organisation THEN '1'
						ELSE Org.[Organisation_Name] END ASC
				) 'RN'
		from [dbo].[FB_Client_Contract_Billing] CCB
			left outer join [dbo].[FB_Contract_Billing_Group] CBG on CBG.[Contract_Billing_Group_ID] = CCB.[Contract_Billing_Group_ID]
			left outer Join [dbo].[FB_Client_Contract_Billed_To] CCBT on CCBT.[Client_CB_ID] = CCB.[Client_CB_ID]
			left outer Join [dbo].[FB_Client_CB_Split] CCBS on CCBS.[Client_Contract_Billed_To_ID] = CCBT.[Client_Contract_Billed_To_ID]
			left outer Join [dbo].[Organisation] Org on CCBS.[Organisation_ID] = Org.[Organisation_ID]

	)J009 on J009.[Client_ID] = J001.[Client_ID]

	Left Outer Join [dbo].[FC_Contract_Area_Product] J010 ON J010.[CAP_ID] = J001.[CAP_ID]
	LEFT OUTER JOIN [dbo].[FC_Funder_Contract] J011 ON J011.[Funder_Contract_ID] = J010.[Funder_Contract_ID]

	Where 
		1=1
--		and J001.Client_ID = @Client_ID_
		
		and 1 = iif(J001.RN > 1 and J001.WiA_Provider_ID = 0, 0, 1)
		and (J006.RN < 2 or J006.RN is null)
		and (J009.RN < 2 or J009.RN is null)
		and convert(datetime, J001.WiA_Schedule_Time) between @StartDate and (DATEADD(s, 84599, @EndDate))
		and J001.Client_ID IS NOT NULL
		and J088.CareModel = 'Home Care Package'

		and J006.[Organisation_Name] = @Organisation
		AND (IIF (J088.funderContract is NULL,'No Contract',J088.funderContract) in (select * from @ContractType))
--		and (IIF (J011.Description is NULL,'No Contract',J011.Description) in (@ContractType))


	Group by
		J001.Client_ID
		,J001.WiA_Provider_ID 
		,IIF(J001.WiA_Schedule_TimeKILL = 'true', null, Cast (J001.WiA_Schedule_Time as Datetime)) 	
		,J001.WiA_Scheduled_Duration 
		,(Cast (J001.AcS_Activity_Start_Time as Datetime)) 
		,J001.AcS_Visit_Duration
		,J088.CareModel 
		,J004.[Description] 
		,J001.Client_Not_Home
		,IIF (J002.Client_ID IS NULL, 0, 1) 
		,IIF (J001.Client_Not_Home IS NULL, 1, 0) 
		,J002.Line_Description 
		,J002.Amount
		,J088.funderContract
		,iif(J001.Group_Activity_ID is Null, 0, 1)
		,J001.Travel_Km
)t2


--*/
--*/
order by
1,3,5,12
