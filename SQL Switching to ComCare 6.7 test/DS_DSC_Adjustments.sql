/*
select * from [dbo].[FB_Client_Contract_Billing]
select * from [dbo].[FC_Funder_Contract]
select * from [dbo].FB_Client_CB_Bill_Adjustment
select * from [dbo].GST_Type
select * from [dbo].FB_Client_CB_Bill_Adjustment

*/

use ComCareDev

Declare @Client_ID_ as INT
set @Client_ID_ = 10076603

DECLARE @StartDate AS DATETIME = '20170102 00:00:00.000'
DECLARE @EndDate AS DATETIME = '20170115 23:59:59.998'
declare @Organisation varchar(64) = 'Disabilities Children'
--declare @Organisation varchar(64) = 'Disabilities Adults'

declare @ContractFilt table (contract varchar(128))
insert into @ContractFilt
select 
	Description 
from [dbo].[FC_Funder_Contract]

where 
	1=1
	AND (
			(Description like 'DC %' and @Organisation = 'Disabilities Children')
			OR (Description like 'DA %' and @Organisation = 'Disabilities Adult')
		)
--	and Description <> 'DC Case Coordination Mt Gambier'
--	and Description <> 'DC Day Activities'
--	and Description <> 'DC Individualised Services'
--	and Description <> 'DC OATS'
--	and Description <> 'DC Overnight Respite'

--select * from @ContractFilt
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
select
	J001.[Client_ID]
	,Format(J010.Effective_From_Date, 'yyyy-MM-dd') 'Activity_Date'
	,J010.Comments 'Charge_Item_Line_Description'
	,Format(J010.Adjustment_Amount, '#######0.#0') 'UnitPrice'
	,J014.Description 'GST_Type'
	,J012.Description 'Funder_Contract'
	,IIF(J009.Organisation_Name = 'NDIA National Disability Insurance Agency', 'NDIS funded',IIF(J009.Client_ID IS NULL,'No Contract Billing','Self Managed')) 'Funding_type'
--	,J009.RN
--	,J009.ContractBillingGroup
--	,J009.Organisation_Name
--	,J009.Client_Contract_Billed_To_ID
--	,J009.[Client_CB_ID]

from
(
	select
		CCB.[Client_ID] 'Client_ID'
		,CCB.[Client_CB_ID] 'Client_CB_ID'
	--	,CCB.[Funder_Contract_ID] 'Funder_Contract_ID'
	from [dbo].[FB_Client_Contract_Billing] CCB
		LEFT OUTER JOIN [dbo].[FB_Contract_Billing_Group] CBG on CBG.[Contract_Billing_Group_ID] = CCB.[Contract_Billing_Group_ID]
		LEFT OUTER JOIN [dbo].[FB_Client_Contract_Billed_To] CCBT on CCBT.[Client_CB_ID] = CCB.[Client_CB_ID]
		LEFT OUTER JOIN  [dbo].[FB_Client_CB_Split] CCBS on CCBS.[Client_Contract_Billed_To_ID] = CCBT.[Client_Contract_Billed_To_ID]
		LEFT OUTER JOIN [dbo].[Organisation] Org on CCBS.[Organisation_ID] = Org.[Organisation_ID]
	where
		1=1
		and (Org.[Organisation_Name] = 'NDIA National Disability Insurance Agency' or Org.[Organisation_Name] is null)
	group by
		CCB.[Client_ID]
		,CCB.Client_CB_ID
	--	,CCB.[Funder_Contract_ID]
)J001

LEFT OUTER JOIN [dbo].[Service_Delivery] J005 ON J001.[Client_ID] = J005.[Client_ID]

INNER JOIN 
(
	Select 
		SD.[Client_ID]
		,O.[Organisation_Name]
		,SD.[Service_Type_Code]
		,SD.[From_Date]
		,SD.[To_Date]
		,ROW_NUMBER ()
			over 
			(
				Partition by SD.[Client_ID] Order by
					CASE
					WHEN O.[Organisation_Name] = @Organisation THEN '1'
					ELSE O.[Organisation_Name] END ASC
			) AS 'RN'
	from [dbo].[Service_Delivery] SD
		JOIN [dbo].[Period_of_Residency] PR on PR.Person_ID = SD.Client_ID
		JOIN [dbo].[Address] A on A.Address_ID = PR.Address_ID
		JOIN [dbo].[Service_Provision] SP on A.Suburb_ID = SP.Suburb_ID AND SP.Service_Type_Code = SD.Service_Type_Code
		JOIN [dbo].[Organisation] O on Sp.Centre_ID = O.Organisation_ID
	Where PR.To_Date IS NULL AND PR.Display_Indicator  = 1
) J006 ON J006.[Client_ID] = J001.[Client_ID] AND J006.[Service_Type_Code] = J005.[Service_Type_Code]

LEFT OUTER JOIN 
(
	select
		CCB.[Client_ID] 'Client_ID'
		,Org.[Organisation_Name] 'Organisation_Name'
		,CBG.[Description] 'ContractBillingGroup'
		,CCB.Client_CB_ID 'Client_CB_ID'
		,CCB.Funder_Contract_ID 'Funder_Contract_ID'
		,CCBT.[Client_Contract_Billed_To_ID] 'Client_Contract_Billed_To_ID'
		,ROW_NUMBER ()
			over 
			(
				Partition by CCB.[Client_ID] Order by
					CASE
					WHEN Org.[Organisation_Name] = 'NDIA National Disability Insurance Agency' THEN '1'
					ELSE Org.[Organisation_Name] END ASC
			) 'RN'
	from [dbo].[FB_Client_Contract_Billing] CCB
		LEFT OUTER JOIN [dbo].[FB_Contract_Billing_Group] CBG on CBG.[Contract_Billing_Group_ID] = CCB.[Contract_Billing_Group_ID]
		LEFT OUTER JOIN [dbo].[FB_Client_Contract_Billed_To] CCBT on CCBT.[Client_CB_ID] = CCB.[Client_CB_ID]
		LEFT OUTER JOIN  [dbo].[FB_Client_CB_Split] CCBS on CCBS.[Client_Contract_Billed_To_ID] = CCBT.[Client_Contract_Billed_To_ID]
		LEFT OUTER JOIN [dbo].[Organisation] Org on CCBS.[Organisation_ID] = Org.[Organisation_ID]
	where
		1=1
		and Org.[Organisation_Name] = 'NDIA National Disability Insurance Agency'
		or Org.[Organisation_Name] is null

)J009 on J009.[Client_ID] = J001.[Client_ID]

--LEFT OUTER JOIN [dbo].[Card_Holder] J007 ON J007.[Person_ID] = J001.[Client_ID]
--LEFT OUTER JOIN [dbo].[Card_Type] J008 ON J008.[Card_Type_ID] = J007.[Card_Type_ID]


LEFT OUTER JOIN [dbo].FB_Client_CB_Bill_Adjustment J010 ON J010.[Client_CB_ID] = J009.[Client_CB_ID]
LEFT OUTER JOIN [dbo].FB_Adjustment_Type J011 ON J011.Adjustment_Type_Code = J010.Adjustment_Type_Code

left outer join [dbo].[FC_Funder_Contract] J012 ON J012.[Funder_Contract_ID] = J009.[Funder_Contract_ID]

left outer join [dbo].GST_Type J014 on J014.GST_Type_Code = J010.GST_Type_Code

Where 
	1=1
	and J006.[Organisation_Name] = @Organisation
	and (J006.RN < 2 or J006.RN is null)
--	and (J009.RN < 2 or J009.RN is null)
	and J010.Effective_to_Date between @StartDate and @EndDate
	and (J009.ContractBillingGroup <> 'DCSI' or J009.ContractBillingGroup is null)
	and (J012.Description in (select * from @ContractFilt) or J012.Description is null)
--	and J012.Description in (@ContractFilt)

--	and J001.Client_ID = 10071595
--*/
group by
	J001.[Client_ID]
	,Format(J010.Effective_From_Date, 'yyyy-MM-dd')
	,J010.Comments
	,Format(J010.Adjustment_Amount, '#######0.#0')
	,J014.Description
	,J012.Description
	,IIF(J009.Organisation_Name = 'NDIA National Disability Insurance Agency', 'NDIS funded',IIF(J009.Client_ID IS NULL,'No Contract Billing','Self Managed'))
	,J009.RN
--	,J009.ContractBillingGroup
--	,J009.Organisation_Name
--	,J009.Client_Contract_Billed_To_ID
--	,J009.[Client_CB_ID]

Order by
2,1