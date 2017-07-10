use ComCareProd

/*

Client_CB_Item_ID
2987
select * from dbo.FC_Area
select * from dbo.FC_Funder_Contract
select * from dbo.FC_Contract_Area_Product

select * from dbo.FC_Client_Contract where	client_ID = 10063049 and End_Date_of_Claim is null
select * from dbo.FC_Account  where Client_Contract_ID = 1789 and FC_Account_Type_ID = 1
select * from dbo.FC_Client_Supplement where Client_Contract_ID = 1789
select * from dbo.FC_Supplement where Supplement_ID = 
select * from dbo.FC_Supplement_Type

select * from dbo.FC_Supplement_Rate


select * from dbo.FB_Client_Contract_Billing where client_id = 10001545 and Billing_end_date is null
select * from dbo.FB_Client_Contract_Bill_Item	where Client_CB_ID = 867					--Client_CB_Item_ID,Client_CB_ID
select * from dbo.FB_Contract_Billing_Item where Contract_Billing_Item_ID = 121
select * from dbo.FB_Contract_Billing_Rate where Contract_Billing_Item_ID = 121 and Effective_To_Date is null and Billing_Rate_Classification_ID = 1

select * from dbo.FB_Contract_Billing_Exception_Rate where Contract_Billing_Rate_ID = 258

select * from dbo.FB_Client_CB_Transaction where Person_ID = 10000049

FC_Supplement

select 
	FCFC.Description 
from dbo.FC_Funding_Care_Model FCCC 
Left outer Join dbo.FC_Funder_Contract FCFC	on FCFC.Funding_Care_Model_ID = FCCC.Funding_Care_Model_ID
where 
	FCCC.Description = 'Home Care Package'
*/
DECLARE @StartDate AS DATE = '20160101 00:00:00.000'
DECLARE @EndDate AS DATE = '20170601 00:00:00.000'
Declare @FunderContract as Varchar(128) = 'Central Eastern Care at Home'

---------------------------------------------------------------------------------------------------------------------------
--/*
select
	J001.Client_ID 'Client_ID'
	,Concat(J006.Preferred_Name,' ',J006.Last_Name)'ClientName'
	,J001.Effective_From_Date
	,J001.Program_Level_ID
	,J009.Description
	,J007.Supplement_Rate
	,J008.Period_Type_Code 'UOM'
	,J012.Description 'funderContract'
from dbo.FC_Client_Contract J001
Left outer Join dbo.FC_Funder_Contract J002	on J002.funder_Contract_ID = J001.funder_Contract_ID
Left outer Join dbo.FC_Funding_Care_Model J003 on J003.Funding_Care_Model_ID = J002.Funding_Care_Model_ID
Left outer join dbo.FC_Account J004 on J004.client_Contract_ID = J001.client_Contract_ID and J004.FC_Account_Type_ID = 1

inner join 
(
	select
	*
	from dbo.FC_Client_Supplement CS
)J005 on 
	J005.client_Contract_ID = J004.client_Contract_ID


inner join dbo.Person J006 on J006.Person_ID = J001.Client_ID
Left outer join dbo.FC_Supplement_Rate J007 on J007.FC_Supplement_ID = J005.FC_Supplement_ID and J007.Program_Level_ID = J001.Program_Level_ID
left outer join dbo.FC_Supplement J008 on J008.FC_Supplement_ID = J005.FC_Supplement_ID
left outer join dbo.FC_Supplement_Type J009 on J009.FC_Supplement_Type_ID = J008.FC_Supplement_Type_ID and J009.Effective_To_Date is null
Left outer join dbo.FC_Funder_Contract J012 on J012.Funder_Contract_ID = J001.Funder_Contract_ID

where
	J003.Description  = 'Home Care Package'
	and J002.Description in (@FunderContract)

	and J007.Effective_To_Date is null
	and J001.Effective_To_Date is null
	and J005.Effective_To_Date is null
		--Debug
	and J001.Client_ID = 10063049

Union
--*/
select --distinct
	J101.Client_ID 'Client_ID'
	,Concat(J106.Preferred_Name,' ',J106.Last_Name)'ClientName'
	,J101.Effective_From_Date
	,J101.Program_Level_ID
	,J109.Description
	,J110.Standard_Rate 'Rate'
	,J111.Description 'UOM'
	,J112.Description 'funderContract'
from dbo.FC_Client_Contract J101
Left outer Join dbo.FC_Funder_Contract J102	on J102.funder_Contract_ID = J101.funder_Contract_ID
Left outer Join dbo.FC_Funding_Care_Model J103 on J103.Funding_Care_Model_ID = J102.Funding_Care_Model_ID
inner join dbo.Person J106 on J106.Person_ID = J101.Client_ID
left outer join dbo.FB_Client_Contract_Billing J107 on J107.Client_ID = J101.Client_ID 
left outer join dbo.FB_Client_Contract_Bill_Item J108 on J108.Client_CB_ID = J107.Client_CB_ID and J108.Effective_To_Date is null
left outer join dbo.FB_Contract_Billing_Item J109 on J109.Contract_Billing_Item_ID = J108.Contract_Billing_Item_ID
left outer join dbo.FB_Contract_Billing_Rate J110 on J110.Contract_Billing_Item_ID = J108.Contract_Billing_Item_ID and J110.Billing_Rate_Classification_ID = J107.Billing_Rate_Classification_ID 
left outer join dbo.Unit_of_Measure J111 on J111.UOM_Code = J110.UOM_Code
Left outer join dbo.FC_Funder_Contract J112 on J112.Funder_Contract_ID = J107.Funder_Contract_ID

where
	J103.Description  = 'Home Care Package'
	and J102.Description in (@FunderContract)
	and J112.Description not like 'CHSP %'
	and J101.Effective_To_Date is null
	and J107.Billing_end_date is null
	and J110.Effective_To_Date is null
		--Debug
	and J101.Client_ID = 10063049