--select * from FB_Client_Contract_Billing
--FC_Funder_Contract Funder_Contract_ID
Declare @OrgName VarChar(64) = 'Home Care North'
Declare @Filt_YesNoBoth int = 0
Declare @Client_ID int = 10001545
Declare @Filt_Funder int = 1

--------------------------------------------------------------
--------------------------------------------------------------

Declare @DQ_Name VarChar(128) = 'Community / Home Visiting Safety Checklist'
Declare @ClientTable table 
(
	Client_ID int
	,Preferred_Name Varchar(128)
	,Last_Name Varchar(128)
	,Deceased_Date Date
	,Organisation_Name Varchar(128)
	,CHSP VarChar(4)
)
insert into @ClientTable
select distinct
	J001.Client_ID
	,J004.Preferred_Name
	,J004.Last_Name
	,CONVERT(date,J004.Deceased_Date) 'Deceased_Date'
	,J001.Organisation_Name
	,iif(J006.Description like 'CHSP%','yes','no')
From 
(
	Select Distinct
		SD.Client_ID
		,O.Organisation_Name
	from Service_Delivery SD
	join Period_of_Residency PR on PR.Person_ID = SD.Client_ID
	join Address A on A.Address_ID = PR.Address_ID
	Join Service_Provision SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
	Join Organisation O on Sp.Centre_ID = O.Organisation_ID
	Where 
		PR.To_Date is null 
		and PR.Display_Indicator  = 1
		and O.Organisation_Name in (@OrgName)
)J001

inner join dbo.Person J004 on J004.Person_ID = J001.Client_ID
left outer join dbo.FB_Client_Contract_Billing J005 on J005.Client_ID = J001.Client_ID and GetDate() between J005.Billing_Start_Date and iif(J005.Billing_End_Date is null,datefromParts(2200,01,01),J005.Billing_End_Date)
left outer join dbo.FC_Funder_Contract J006 on J006.Funder_Contract_ID = J005.Funder_Contract_ID
where
	1=1
	and J004.Deceased_Date is null
	and J006.Description is not null
--	and J001.Client_ID = @Client_ID
Order by
	3,2,1
--------------------------------------------------------------
--------------------------------------------------------------
--select * from @ClientTable
--------------------------------------------------------------
--------------------------------------------------------------
select distinct
	J101.Organisation_Name
	,J101.Client_ID 'Client_ID'
	,J101.Last_Name +', '+J101.Preferred_Name 'Client_Name'
	,iif(J001.Date_DQ is null,'No','Yes')'Has_DQ'
	,J001.Date_DQ
	,J101.CHSP
	,J101.RN
from 
(
	select
	*
	,ROW_NUMBER()over(partition by Client_ID order by Client_ID)'RN'
	from @ClientTable
)J101
Left outer join
(
	select distinct
		DQ_E_Q.Respondent_ID
		,DQ_Q.Questionnaire_Code
		,cast(DQ_E_Q.Questionnaire_Date as date)'Date_DQ'
		,ROW_NUMBER()Over(Partition by DQ_Q.Description,DQ_E_Q.Respondent_ID order by DQ_E_Q.Questionnaire_Date Desc)'RN'
	from dbo.DQ_Questionnaire DQ_Q
	left outer join dbo.DQ_Entity_Questionnaire DQ_E_Q on DQ_E_Q.Questionnaire_Code = DQ_Q.Questionnaire_Code
	where 
	1=1
	and DQ_Q.Description = @DQ_Name
)J001 on J001.Respondent_ID = J101.Client_ID and J001.RN = 1
Left outer join dbo.DQ_Questionnaire_Question J002 on J002.Questionnaire_Code = J001.Questionnaire_Code
where 
	1=1
	and 1 = Case
		when @Filt_YesNoBoth = 0 then 1
		when @Filt_YesNoBoth = 1 and J001.Date_DQ is null then 1
		when @Filt_YesNoBoth = 2 and J001.Date_DQ is not null then 1
		else 0
		end
	and 1 = Case
		when @Filt_Funder = 0 and J101.RN = 1 then 1
		when @Filt_Funder = 1 and J101.CHSP = 'no' then 1
		when @Filt_Funder = 2 and J101.CHSP = 'yes' then 1
		else 0
		end
order by
1,3,6