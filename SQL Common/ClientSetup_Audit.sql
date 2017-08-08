
/*
select top 1 * from dbo.FB_Client_CB_Split
select * from dbo.FC_Funder_Contract
Select * from dbo.FB_Contract_Billing_Group
Select * from dbo.FB_Client_Contract_Billing where client_ID = 10069222
Select * from dbo.FC_Client_Contract where client_ID = 10014025

select O.Organisation_Name from dbo.Organisation O where O.Organisation_Type_Code = 1

*/
use ComCareProd

declare @FunderContractFilt table (FunderContract varchar(128))
insert into @FunderContractFilt
select 'No Contract' Description where 1=1
union
select
	Description
from [dbo].[FC_Funder_Contract]
where 
	1=1
	AND (Description like 'DC %' )
	
order by 1

declare @Org_name Varchar(128) = 'Disabilities Children'






--/*
Declare @ServiceCollection_Table Table (Client_ID int, Service_ Varchar(256), FunderProgram VarChar(256))
insert into @ServiceCollection_Table
select distinct
	JX001.Client_ID
	,Concat (JX003.Description,' ',format (JX002.From_Date, 'dd/MM/yyy' )) 'Service_'
	,JX004.Description 'FunderProgram' 
	--,JX002.From_Date
From
(
	Select Distinct
			SD.Client_ID
			,O.Organisation_Name as 'Organisation_Name'
			--,FP.Description 'FunderProgram'
		From dbo.Organisation O
		join dbo.Service_Provision SP on SP.Centre_ID = O.Organisation_ID
		join dbo.Address A on A.Suburb_ID = SP.Suburb_ID
		join dbo.Period_of_Residency PR on PR.Address_ID = A.Address_ID
		join dbo.Service_Delivery SD on SD.Client_ID = PR.Person_ID and SD.Service_Type_Code = SP.Service_Type_Code
		
	Where 
			PR.To_Date is null 
			and PR.Display_Indicator = 1
			and O.Organisation_Name in (@Org_Name)
)JX001
Inner JOIN dbo.Service_Delivery JX002 ON JX002.Client_ID = JX001.Client_ID
Left outer Join dbo.Funding_Program JX004 on JX004.Funding_Prog_Code = JX002.Funding_Prog_Code
Left outer Join dbo.Service_Type JX003 on JX003.Service_Type_Code = JX002.Service_Type_Code
where JX002.To_Date is null
--select * from @ServiceCollection_Table

Declare @ServiceCollection_Table_Joined Table (Client_ID int, Services_ Varchar(MAX), FunderProgram VarChar(Max))

insert into @ServiceCollection_Table_Joined
select distinct
	T1.Client_ID
	,Services_=STUFF((select ', ' + ST.Service_ from @ServiceCollection_Table ST where ST.Client_ID = T1.Client_ID For XML Path('')),1,1,'')
	,Services_=STUFF((select ', ' + ST.FunderProgram from @ServiceCollection_Table ST where ST.Client_ID = T1.Client_ID For XML Path('')),1,1,'')
	from @ServiceCollection_Table T1

--select * from @ServiceCollection_Table_Joined
--*/




select distinct
	J001.Client_ID 'Client_ID'
	,J013.Client_Name
	,replace(J012.Services_,', ',' <br>')'Services_'
	,replace(J012.FunderProgram,', ',' <br>')'FunderProgram'
	,J006.Description 'FunderCotract'
	,cast(J004.Effective_From_Date as date)'Effective_From_Date'
	,J002.Description 'ContractBillingGroup'
	,cast(J001.Billing_Start_Date as date) 'Billing_Start_Date'
	,J003.Client_Contract_Billed_To_ID 'Client_Contract_Billed_To_ID'
	,J005.BilledTo_Name 'Billed_To'
	,J011.Description 'BillingItem'
from dbo.FB_Client_Contract_Billing J001

LEFT OUTER JOIN dbo.FB_Contract_Billing_Group J002 on J002.Contract_Billing_Group_ID = J001.Contract_Billing_Group_ID
LEFT OUTER JOIN dbo.FB_Client_Contract_Billed_To J003 on J003.Client_CB_ID = J001.Client_CB_ID
left outer join dbo.FC_Client_Contract J004 on J004.Client_ID = J001.Client_ID and J004.Funder_Contract_ID = J001.Funder_Contract_ID
--Client_Contract_ID

LEFT OUTER JOIN
( 
	select
	CS.Client_Contract_Billed_To_ID
	,iif(CS.Organisation_ID is null,concat(P.Last_Name,', ',P.Preferred_Name),Org.Organisation_Name) 'BilledTo_Name'
	From dbo.FB_Client_CB_Split CS
	LEFT OUTER JOIN dbo.Organisation Org on Org.Organisation_ID = CS.Organisation_ID
	left outer join dbo.Person P on P.Person_ID = CS.Person_ID
)J005 on J005.Client_Contract_Billed_To_ID = J003.Client_Contract_Billed_To_ID

left outer join dbo.FC_Funder_Contract J006 ON J006.Funder_Contract_ID = J004.Funder_Contract_ID

INNER JOIN 
(
	Select Distinct
		SD.Client_ID
		,O.Organisation_Name as 'Organisation_Name'
		--,FP.Description 'FunderProgram'
	from dbo.Service_Delivery SD
		join dbo.Period_of_Residency PR on PR.Person_ID = SD.Client_ID
		join dbo.Address A on A.Address_ID = PR.Address_ID
		Join dbo.Service_Provision SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
		Join dbo.Organisation O on Sp.Centre_ID = O.Organisation_ID
		
	Where PR.To_Date is null and PR.Display_Indicator  = 1
) J008 ON J008.Client_ID = J001.Client_ID

Left outer Join dbo.FB_Client_Contract_Bill_Item J010 on J010.Client_CB_ID = J001.Client_CB_ID
Left outer join dbo.FB_Contract_Billing_Item J011 on J011.Contract_Billing_Item_ID = J010.Contract_Billing_Item_ID
Left outer join @ServiceCollection_Table_Joined J012 on J012.Client_ID = J001.Client_ID

Inner join 
(
	select 
		p.Person_ID
		,Concat(p.Last_Name,', ',p.Preferred_Name)'Client_Name'
	From dbo.person p
	where 
		p.Deceased_Date is null
)J013 on J013.Person_ID = J001.Client_ID

where
	1=1
	--and J001.Client_ID = 10069222
	and J001.Billing_End_Date is null
	and J008.Organisation_Name = @Org_Name
	and IIF (J006.Description is NULL,'No Contract',J006.Description) in (@FunderContractFilt)
--	and IIF (J006.Description is NULL,'No Contract',J006.Description) in (select * from @FunderContractFilt)
	--and J005.Organisation_Name = 'NDIA National Disability Insurance Agency'
	--or J005.Organisation_Name is null

Order by
	J001.Client_ID
	,J013.Client_Name
	,replace(J012.Services_,', ',' <br>')
	,J006.Description
	,J002.Description
	,J003.Client_Contract_Billed_To_ID
	,J005.BilledTo_Name
	,J011.Description
