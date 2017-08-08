/*
select * from dbo.FB_Contract_Billing_Item where Contract
select * from [dbo].FC_Product where FC_Product_ID = 14
select * from [dbo].FC_Contract_Area_Product where FC_Product_ID = 14
select * from [dbo].FB_Contract_Billing_Rate where Contract_Billing_Rate_ID = 430

select * from [dbo].Allocated_Task where Service_Prov_Position_ID = 181

select * from [dbo].[Actual_Service_Charge_Item] ACSI where ACSI.Client_ID = 10014025 and cast(ACSI.Visit_Date as date) = '2017-07-28'

select * from dbo.FB_Client_Contract_Bill_Item CCBI where CCBI.Contract_Billing_Item_ID = 19
select * from dbo.FB_Contract_Billing_Item where Contract_Billing_Item_ID = 19
select * from dbo.FB_Contract_Billing_Item_Region where Contract_Billing_Item_ID = 19
select * from dbo.FB_Client_Contract_Bill_Item where Contract_Billing_Item_ID = 19

select * from dbo.FB_Contract_Billing_Item_UOM where Contract_Billing_Item_ID = 19


select * from dbo.FC_Contract_Area_Product where FC_Product_ID = 14

select * from [dbo].[Actual_Service_Charge_Item] ACSI where ACSI.Client_ID = 10014025 and cast(ACSI.Visit_Date as date) = '2017-07-28'
select * from dbo.FC_Client_Contract where client_id = 10014025 and End_Date_of_Claim is not null
select * from dbo.FC_Product_Mapping where FC_Product_ID = 14
select * from dbo.FC_Product_Mapping where task_Type_code like '%HCP%'

Contract_Billing_Rate_ID
Service_Prov_Position_ID
*/

use ComCareProd
--28/07/2017
Declare @Client_ID_ as INT = 10075769
DECLARE @StartDate AS DATETIME = '20170701 00:00:00.000'
DECLARE @EndDate AS DATETIME = '20170730 00:00:00.000'
Declare @DuplicateChargeItem int = 0

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
	AND (Description like 'CHSP%' )
order by 1




select
		J002.Client_ID
		,J002.Provider_ID
		,cast(J002.Visit_Date as datetime) 'Schedule_Visit_Time'
		,null 'Scheduled_Duration'
		,null 'Actual_Visit_Time'
		,null 'Actual_Duration'
		,J012.Description 'contract_type'
		,'---' 'task_Description'
		,null 'Client_Not_Home'
		,2 'Has_Charge_Item'
		,null 'In_WiA_Only'
		,J002.Line_Description 'Charge_Item_Line_Description'
		,J002.Amount
		,IIF(J009.Organisation_Name = 'NDIA National Disability Insurance Agency', 'NDIS funded',IIF(J009.Client_ID IS NULL,'No Contract Billing','Self Managed')) 'Funding_Type'
--		,J002.RN 'ChrgDup'
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
			,ACSI.Contract_Billing_Item_ID
			,ACSI.FC_Product_ID
			,row_number()over(partition by ACSI.Client_ID,ACSI.Provider_ID,ACSI.Visit_Date,ACSI.Visit_No,ACSI.Line_Description order by ACSI.Visit_Date,ACSI.Visit_No)'RN'
		from [dbo].[Actual_Service_Charge_Item] ACSI

	)J002
	Left Outer Join dbo.Service_Delivery J005 ON J002.[Client_ID] = J005.[Client_ID]

	left outer join
	(
		Select 
			SD.[Client_ID]
			,O.[Organisation_Name]
			,SD.[Service_Type_Code]
			,ROW_NUMBER ()
				over 
				(
					Partition by SD.Client_ID Order by
						CASE
						WHEN O.Organisation_Name in (select * from @Organisation) THEN '1'
--						WHEN O.Organisation_Name in (@Organisation) THEN '1'
						ELSE O.Organisation_Name END ASC
				)'RN'
		from [dbo].[Service_Delivery] SD
			join [dbo].[Period_of_Residency] PR on PR.Person_ID = SD.Client_ID
			join [dbo].[Address] A on A.Address_ID = PR.Address_ID
			Join [dbo].[Service_Provision] SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
			Join [dbo].[Organisation] O on Sp.Centre_ID = O.Organisation_ID
		Where PR.To_Date is null and PR.Display_Indicator  = 1
	) J006 ON J006.[Client_ID] = J002.[Client_ID] AND J006.[Service_Type_Code] = J005.[Service_Type_Code]

	Left outer Join
	(
		select
			CCB.[Client_ID] 'Client_ID'
			,Org.[Organisation_Name] 'Organisation_Name'
			,CBG.[Description] 'ContractBillingGroup'
			,ROW_NUMBER ()
				over 
				(
					Partition by CCB.Client_ID Order by Org.Organisation_Name ASC
				) 'RN'
		from [dbo].[FB_Client_Contract_Billing] CCB
			left outer join [dbo].[FB_Contract_Billing_Group] CBG on CBG.[Contract_Billing_Group_ID] = CCB.Contract_Billing_Group_ID
			left outer Join [dbo].[FB_Client_Contract_Billed_To] CCBT on CCBT.[Client_CB_ID] = CCB.[Client_CB_ID]
			left outer Join [dbo].[FB_Client_CB_Split] CCBS on CCBS.[Client_Contract_Billed_To_ID] = CCBT.[Client_Contract_Billed_To_ID]
			left outer Join [dbo].[Organisation] Org on CCBS.[Organisation_ID] = Org.[Organisation_ID]
			--select * from [FB_Client_Contract_Billing]Contract_Billing_Group_ID
	)J009 on J009.[Client_ID] = J002.[Client_ID]

	Left outer join
	(
		select distinct
		CCBI.Contract_Billing_Item_ID
		,FC.Description
		,CCB.Client_ID
		from dbo.FB_Client_Contract_Bill_Item CCBI
		left outer join dbo.FB_Client_Contract_Billing CCB on CCB.Client_CB_ID = CCBI.Client_CB_ID 
		left outer join dbo.FC_Funder_Contract FC on FC.Funder_Contract_ID = CCB.Funder_Contract_ID
	)J012 on J012.Contract_Billing_Item_ID = J002.Contract_Billing_Item_ID and J012.Client_ID = J002.Client_ID

	left outer join dbo.FC_Product_Mapping J013 on J013.FC_Product_ID = J002.FC_Product_ID and J013.Effective_To_Date is null-- J013.task_Type_code like '%HCP%'

	where
	J002.RN > 1
--	and J002.Client_ID = @Client_ID_
	and J013.Task_Type_Code not like '%HCP%'
	and (J009.RN < 2 or J009.RN is null)
	and J002.Client_ID = 10014025
	and convert(date, J002.Visit_Date) between @StartDate and @EndDate
	and J006.Organisation_Name in (select * from @Organisation)
--	and J006.Organisation_Name in (@Organisation)