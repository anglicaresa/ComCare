use ComCareProd

/*
select * from dbo.Organisation
Client_CB_Item_ID
2987
select * from dbo.FC_Area
select * from dbo.FC_Funder_Contract
select * from dbo.FC_Contract_Area_Product
select * from dbo.FC_Funding_Care_Model


select * from dbo.FC_Client_Contract where client_id = 10070435
select * from dbo.FC_Funder_Contract where funder_Contract_ID = 26 or funder_Contract_ID = 27
select * from dbo.FC_Funding_Care_Model

select * from dbo.FB_Client_Contract_Billing where client_id = 10084581 and Billing_end_date is null
select * from dbo.FB_Client_Contract_Bill_Item	
	where 
		Client_CB_ID = 2111 

select * from dbo.FB_Contract_Billing_Item 
	where 
		Contract_Billing_Item_ID = 259 
		or Contract_Billing_Item_ID = 236 
select * from dbo.FB_Contract_Billing_Rate 
where 
		Contract_Billing_Item_ID = 259 
		or Contract_Billing_Item_ID = 236 

select * from dbo.FB_Client_CB_Transaction where Person_ID = 10000049
 select * from dbo.FB_Contract_Billing_Group
FC_Supplement

select 
	FCFC.Description 
from dbo.FC_Funding_Care_Model FCCC 
Left outer Join dbo.FC_Funder_Contract FCFC	on FCFC.Funding_Care_Model_ID = FCCC.Funding_Care_Model_ID
where 
	FCCC.Description = 'Disabilities Children'
*/

--Declare @FunderContract as Varchar(128) = 'Central Eastern Care at Home'
Declare @FunderContract as Varchar(128) = 'DC Overnight Respite'
---------------------------------------------------------------------------------------------------------------------------

Declare @ClientTable table 
(
	Client_ID int
	,ClientName Varchar(128)
)
insert into @ClientTable
select --distinct
	J003.Client_ID
	,Concat(J004.Preferred_Name,' ',J004.Last_Name)'ClientName'
From 
(
	select 
		FCM.Description
		,FCM.Funding_Care_Model_ID 
	from dbo.FC_Funding_Care_Model FCM 
	where 
		FCM.Description = 'Disabilities Children'
)J001
Left outer Join dbo.FC_Funder_Contract J002 on J001.Funding_Care_Model_ID = J002.Funding_Care_Model_ID
Left outer join dbo.FC_Client_Contract J003 on J002.funder_Contract_ID = J003.funder_Contract_ID and J003.Effective_To_Date is null
inner join dbo.Person J004 on J004.Person_ID = J003.Client_ID --and
where
	J003.Effective_To_Date is null

Group by
	J003.Client_ID
	,Concat(J004.Preferred_Name,' ',J004.Last_Name)

Order by
	2,1

-------------------------------------------------------------------------------

select distinct
	J101.Client_ID 'Client_ID'
	,J101.ClientName
--	,J101.Effective_From_Date
	,J107.Description 'ContractBillingGroup'
--	,J102.Client_CB_ID
--	,J103.Contract_Billing_Item_ID
	,J109.Effective_From_Date
	,J104.Description
	,cast(case
		When J105.Surcharge_Saturday is not null then J105.Surcharge_Saturday
		when J105.Surcharge_Sunday is not null then J105.Surcharge_Sunday
		when J105.Surcharge_Wkday_After_Hr is not null then J105.Surcharge_Wkday_After_Hr
		when J105.Surcharge_Public_Holiday is not null then J105.Surcharge_Public_Holiday
		else J105.Standard_Rate
		end as Decimal(16,2)) 'Rate'
	,Case
		When J105.Surcharge_Saturday is not null then 'Saturday Rate'
		when J105.Surcharge_Sunday is not null then 'Sunday Rate'
		when J105.Surcharge_Wkday_After_Hr is not null then 'After Hours Rate'
		when J105.Surcharge_Public_Holiday is not null then 'Public Holiday Rate'
		else 'Standard'
		end 'RateType'
	,J106.Description 'UOM'
	,J108.Description 'funderContract'

From @ClientTable J101
inner join dbo.FB_Client_Contract_Billing J102 on J102.Client_ID = J101.Client_ID 
Left outer join dbo.FB_Client_Contract_Bill_Item J103 on J103.Client_CB_ID = J102.Client_CB_ID 
Inner join dbo.FB_Contract_Billing_Item J104 on J104.Contract_Billing_Item_ID = J103.Contract_Billing_Item_ID
Inner join dbo.FB_Contract_Billing_Rate J105 on J105.Contract_Billing_Item_ID = J103.Contract_Billing_Item_ID
left outer join dbo.Unit_of_Measure J106 on J106.UOM_Code = J105.UOM_Code

Left outer join dbo.FB_Contract_Billing_Group J107 on J107.Contract_Billing_Group_ID = J102.Contract_Billing_Group_ID

Left outer join dbo.FC_Funder_Contract J108 on J108.Funder_Contract_ID = J102.Funder_Contract_ID
Left outer Join dbo.FC_Client_Contract J109 on J109.Client_ID = J101.Client_ID and J109.Funder_Contract_ID =  J102.Funder_Contract_ID

where
	1=1
	and J108.Description in (@FunderContract)
	--debug
	and J102.Billing_end_date is null
	and J105.Effective_To_Date is null
	

	--debug
--	and J101.Client_ID = 10084581

order by
2,1,3

-- select * from dbo.FB_Contract_Billing_Group