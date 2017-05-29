use ComCareProd
Declare @Client_ID_ as INT = 10075769
DECLARE @StartDate AS DATETIME = '20170104 00:00:00.000'
DECLARE @EndDate AS DATETIME = '20170304 00:00:00.000'
declare @Organisation VarChar(64) = 'Disabilities Children'
declare @DuplicateChargeItem as int = 1

Declare @ContractType Table (ContractType varchar(64))
Insert INTO @ContractType 
	select 'No Contract' Description where 1=1
union
select
	Description
from [dbo].[FC_Funder_Contract]
where 
	1=1
	AND ((Description like 'DC %' and @Organisation = 'Disabilities Children')OR (Description like 'DA %' and @Organisation = 'Disabilities Adult'))


	select
		J002.Client_ID
		,J002.Provider_ID
		,cast(J002.Visit_Date as datetime) 'Schedule_Visit_Time'
		,null 'Scheduled_Duration'
		,null 'Actual_Visit_Time'
		,null 'Actual_Duration'
		,null 'contract_type'
		,null 'task_Description'
		,null 'Client_Not_Home'
		,null 'Has_Charge_Item'
		,null 'In_WiA_Only'
		,J002.Line_Description 'Charge_Item_Line_Description'
		,J002.Amount
		,IIF(J009.Organisation_Name = 'NDIA National Disability Insurance Agency', 'NDIS funded',IIF(J009.Client_ID IS NULL,'No Contract Billing','Self Managed')) 'Funding_Type'
		,J002.RN 'ChrgDup'
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
					Partition by SD.[Client_ID] Order by
						CASE
						WHEN O.[Organisation_Name] = @Organisation THEN '1'
						ELSE O.[Organisation_Name] END ASC
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
					Partition by CCB.[Client_ID] Order by
						CASE
						WHEN Org.[Organisation_Name] = 'NDIA National Disability Insurance Agency' THEN '1'
						ELSE Org.[Organisation_Name] END ASC
				) 'RN'
		from [dbo].[FB_Client_Contract_Billing] CCB
			left outer join [dbo].[FB_Contract_Billing_Group] CBG on CBG.[Contract_Billing_Group_ID] = CCB.[Contract_Billing_Group_ID]
			left outer Join [dbo].[FB_Client_Contract_Billed_To] CCBT on CCBT.[Client_CB_ID] = CCB.[Client_CB_ID]
			left outer Join [dbo].[FB_Client_CB_Split] CCBS on CCBS.[Client_Contract_Billed_To_ID] = CCBT.[Client_Contract_Billed_To_ID]
			left outer Join [dbo].[Organisation] Org on CCBS.[Organisation_ID] = Org.[Organisation_ID]

	)J009 on J009.[Client_ID] = J002.[Client_ID]

	where
	J002.RN = 2
	and convert(date, J002.Visit_Date) between @StartDate and @EndDate
	and J006.[Organisation_Name] = @Organisation

	Group by
	J002.Client_ID
		,J002.Provider_ID
		,cast(J002.Visit_Date as datetime)

		,J002.Line_Description
		,J002.Amount
		,IIF(J009.Organisation_Name = 'NDIA National Disability Insurance Agency', 'NDIS funded',IIF(J009.Client_ID IS NULL,'No Contract Billing','Self Managed'))
		,J002.RN