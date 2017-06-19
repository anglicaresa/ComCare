	

--	select top 1 * from dbo.FB_Client_CB_Split --Client_Contract_Billed_To_ID,Person_ID,Organisation_ID,Client_CB_Split_ID

/*
select * from
(
	select 
	*
	,Row_Number()over(Partition by Client_Contract_Billed_To_ID order by Client_CB_Split_ID)RN
	 from dbo.FB_Client_CB_Split --Client_Contract_Billed_To_ID,Person_ID,Organisation_ID,Client_CB_Split_ID
)J001
where cast(J001.Split_Percentage as float) < 70.00
	order by
	2


HCP Fee for Service Contract
HCP Intake Contract
Central Eastern Care at Home
Northern Care at Home
Northern Extended Aged Care at Home
Southern Care at Home
Western Care at Home
CHSP East- Asst. with Care and Housing
CHSP East-Comm and Home Support
CHSP North-Asst with Care and Housing
CHSP North-Comm and Home Support
CHSP North-Care Rel and Carer Support
CHSP North-Resthaven
CHSP South-Onkaparinga Council
CHSP South-Comm and Home Support
CHSP West-Asst with Care and Housing
CHSP West-Comm and Home Support
CHSP Yorke North Barossa - Comm and Home Support
--Housing Support for Older People
Fee for Service
CHSP South- Asst. with Care and Housing
--DC Individualised Services
--DC Day Activities
--DC Overnight Respite
--DC Case Coordination Mt Gambier
--DC OATS
*/
/*
select top 1 * from dbo.FC_Funder_Contract --Funder_Contract_ID
select top 1 * from dbo.FB_Client_Contract_Billing --Client_CB_ID,Funder_Contract_ID,Client_ID
select top 1 * from dbo.FB_Client_Contract_Billed_To --Client_CB_ID,Client_Contract_Billed_To_ID
select top 1 * from dbo.FB_Client_CB_Split --Client_Contract_Billed_To_ID,Person_ID,Organisation_ID,Client_CB_Split_ID
*/

--/*

Declare @Contract Varchar(128) = 'Northern Care at Home'
Declare @filtOutSame int = 0

select
	J002.Client_ID
	,Concat (J005.Preferred_Name,' ', J005.Last_Name) 'ClientName'
	,J004.Person_ID
	,Concat (J006.Preferred_Name,' ', J006.Last_Name)'BillToName'
	,J004.Organisation_ID
	,J007.Organisation_Name
	,J001.Description 'Contract'
from dbo.FC_Funder_Contract J001
inner Join dbo.FB_Client_Contract_Billing J002 on J001.Funder_Contract_ID = J002.Funder_Contract_ID
Inner Join dbo.FB_Client_Contract_Billed_To J003 on J002.Client_CB_ID = J003.Client_CB_ID
Inner Join dbo.FB_Client_CB_Split J004 on J003.Client_Contract_Billed_To_ID = J004.Client_Contract_Billed_To_ID
Left Outer Join dbo.Person J005 on J005.Person_ID = J002.Client_ID
Left Outer Join dbo.Person J006 on J006.Person_ID = J004.Person_ID
Left Outer Join dbo.Organisation J007 on J007.Organisation_ID =  J004.Organisation_ID

where
	1=1
	and J002.Billing_End_Date is null
	and J001.Description in (@Contract)
	and J003.Effective_To_Date is null
	and 1=iif(J002.Client_ID = J004.Person_ID,@filtOutSame,1)

--*/
/*
Select 
	J001.Description 
from dbo.FC_Funder_Contract J001
where
	J001.Description Like 'CHSP %'
	or J001.Description like '% Care at home%'
	or J001.Description = 'Fee for Service'
	or J001.Description like 'HCP %'
--*/