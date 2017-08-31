/*--get list of DQs for group
select
	J001.Description 'DQGroupName'
--	,J001.Questionnaire_Group_ID
	,J003.Description 'DQName'
--	,J003.Questionnaire_Code
from dbo.DQ_Questionnaire_Group J001
Left outer join dbo.DQ_Questionnaire_Groupings J002 on J002.Questionnaire_Group_ID = J001.Questionnaire_Group_ID
left outer join dbo.DQ_Questionnaire J003 on J003.Questionnaire_Code = J002.Questionnaire_Code

where
	1=1
	and J003.Effective_To_Date is null
	and J003.Description is not null
	and J001.Description = concat('Children',Char(39),'s Disabilities')


select * from dbo.FB_Contract_Billing_Item where Description like '%01_015_0107_1_1' -- quote codes


--Client diagnosis
LEFT OUTER JOIN dbo.Diagnosis J011 ON J011.Client_ID = J001.Client_ID
LEFT OUTER JOIN dbo.Diagnosis_Category J012 ON J012.Diagnosis_Category_Code = J011.Diagnosis_Category_Code

select * from dbo.Diagnosis where Client_ID = 10071173


select top 3 * from dbo.Personal_Contact


select * from dbo.Person_Communication_Point where Communication_Point_number like '%@Yahoo.com%'
select * from dbo.Service_Delivery where Client_ID = 10073115
select * from Service_Delivery_Outcome
Serv_Del_Outcome_Code
--*/


--debug
Declare @Client_ID int = 10073115 --has DQ
--Declare @Client_ID int = 10080247

Declare @UseSingleID int = 1
--select * from dbo.Person_Current_Address_Phone where Person_id = @Client_ID

Declare @OrgName VarChar(64) = 'Disabilities Children'

--------------------------------------------------------------
--------------------------------------------------------------
--------------------------------------------------------------
--------------------------------------------------------------

Declare @ClientTable table 
(
	Client_ID int
	,Preferred_Name Varchar(128)
	,Last_Name Varchar(128)
	,Birth_Date date
	,Deceased_Date Date
	,Building_name Varchar(128)
	,Location Varchar(128)
	,dwelling_number VarChar(64)
	,Street Varchar(128)
	,suburb Varchar(128)
	,Post_Code int
	,HasGOC int
	,Diagnosis VarChar(max)
	,ServiceDelivery_StartDate VarChar(256)
)
insert into @ClientTable
select * from
(
select distinct
	J003.Client_ID
	,J004.Preferred_Name
	,J004.Last_Name
	,Convert(date,J004.Birth_Date) 'Birth_Date'
	,CONVERT(date,J004.Deceased_Date) 'Deceased_Date'
	,J005.Building_name
	,J005.Location
	,J005.dwelling_number
	,J005.Street
	,J005.suburb
	,J005.Post_Code
	,J006.HasGOC --If null no contract
	,Stuff
	(
		(
			select distinct
				'~ '
				+ DC.Description 
			from dbo.Diagnosis D 
			left outer join dbo.Diagnosis_Category DC ON DC.Diagnosis_Category_Code = D.Diagnosis_Category_Code 
			where D.Client_ID = J003.Client_ID
			for XML path ('')  
		),1,2,''--stuff args to remove first comma
	)'Diagnosis'
	,STUFF
	(
		(
			select distinct
				'~ '
				+ Concat(ST.Description,' - ',Format(SD.From_Date,'dd-MM-yyyy')) 
			from dbo.Service_Delivery SD 
			left outer join dbo.Service_Type ST ON ST.Service_Type_Code = SD.Service_Type_Code 
			where SD.Client_ID = J003.Client_ID
			for XML path ('')  
		),1,2,''--stuff args to remove first comma
	)'ServiceDelivery_StartDate'
	,STUFF
	(
		(
			select distinct
				'~ '
				+ Concat(ST.Description,' - ',iif(SD.To_Date is null,'-No Discharg Date-' ,Format(SD.To_Date,'dd-MM-yyyy'))) 
			from dbo.Service_Delivery SD 
			left outer join dbo.Service_Type ST ON ST.Service_Type_Code = SD.Service_Type_Code 
			where SD.Client_ID = J003.Client_ID
			for XML path ('')  
		),1,2,''--stuff args to remove first comma
	)'ServiceDelivery_DischargeDate'
From 
(
	select 
		FCM.Description
		,FCM.Funding_Care_Model_ID 
	from dbo.FC_Funding_Care_Model FCM 
	where 
		FCM.Description = @OrgName
)J001
Left outer Join dbo.FC_Funder_Contract J002 on J001.Funding_Care_Model_ID = J002.Funding_Care_Model_ID
Left outer join dbo.FC_Client_Contract J003 on J002.funder_Contract_ID = J003.funder_Contract_ID and J003.Effective_To_Date is null
inner join dbo.Person J004 on J004.Person_ID = J003.Client_ID

LEFT OUTER JOIN dbo.Person_Current_Address_Phone J005 ON J005.Person_id = J003.Client_ID
Left outer join
(
	select distinct
	CC.Client_ID
	,iif(GOC.Client_Contract_ID is not null, 1,0)'HasGOC'
	From dbo.FC_Client_Contract CC
	LEFT OUTER JOIN 
	(
		select distinct
		GOC.Client_Contract_ID
		from dbo.FC_Client_Goal_of_Care GOC
	)GOC on GOC.Client_Contract_ID = CC.Client_Contract_ID
)J006 on J006.Client_ID = J003.Client_ID

where
	1=1
	and 1 = iif(@UseSingleID = 1 , iif(J003.Client_ID = @Client_ID, 1, 0),1)

)T1
Order by
	3,2,1
--------------------------------------------------------------
--------------------------------------------------------------
select * from @ClientTable
--------------------------------------------------------------
--------------------------------------------------------------
--/*
declare @ClientContact Table 
(
	Client_ID int
	,ContactName VarChar(128)
	,Contact_Phone VarChar(64)
	,Contact_Email VarChar(128)
	,RN int
--	,concatContactDeets VarChar(Max)
)
insert into @ClientContact
select distinct
	J001.Client_ID
	,iif(J004.Last_Name is not null,CONCAT(J004.Last_Name,', ',J004.Preferred_Name,' [',J003.Description,']'),null) 'ContactName'
	,iif(J005.Phone is null,'-none-',J005.Phone) 'Contact_Phone'
	,iif(J006.Communication_Point_Number is null,'-none-',J006.Communication_Point_Number) 'Contact_Email'
	,J003.RN
from @ClientTable J001

left outer join
(
	Select
		PC.[Person_ID]
		,PC.[Contact_ID]
		,PCT.[Description]
		,ROW_NUMBER() Over
		(
			Partition BY PC.[Person_ID] Order By
				Case
					WHEN PCT.Description = 'Mother' then '1'
					WHEN PCT.Description = 'Father' then '2'
					WHEN PCT.Description = 'Parent' then '3'
					WHEN PCT.Description = 'Grandparent' then '4'
					WHEN PCT.Description = 'Step Mother' then '5'
					WHEN PCT.Description = 'Step Father' then '6'
					WHEN PCT.Description = 'Guardian' then '7'
					WHEN PCT.Description = 'Foster Parent' then '8'
					WHEN PCT.Description = 'Other relative' then '9'
					else PCT.Description
					END
		) AS 'RN' 	
	From dbo.Personal_Contact PC
	Left outer Join dbo.Personal_Contact_Type PCT ON PCT.Personal_Contact_Type_Code = PC.Personal_Contact_Type_Code

)J003 on J003.Person_ID = J001.Client_ID and (J003.RN is null or J003.RN<3)

Left outer Join dbo.Person J004 on J004.Person_ID = J003.Contact_ID
Left outer join dbo.Person_Current_Address_Phone J005 on J005.Person_id = J003.Contact_ID and CHARINDEX('@',J005.Phone) = 0

Left outer join
(
	Select distinct
	PCP.Person_ID
	,PCP.Communication_Point_Number
	,ROW_NUMBER()over
	(
		partition by PCP.Person_ID, iif((CHARINDEX('@',PCP.Communication_Point_Number) > 0),1,0)
		order by Case
			when PCP.Last_Modified_Date is not null then PCP.Last_Modified_Date
			else PCP.Creation_Date
			end desc
	)'RN'
	from dbo.Person_Communication_Point PCP
	where
		1=1
		and CHARINDEX('@',PCP.Communication_Point_Number) > 0
)J006 on J006.Person_ID = J003.Contact_ID

where
	1=1
	and (J006.RN is null or J006.RN<2)
	and 1 = IIF
	(
		(J005.Phone is null and J006.Communication_Point_Number is null)
		,0
		,1
	)
order by
J001.Client_ID
,J003.RN
--*/
--------------------------------------------------------------
--------------------------------------------------------------
--select * from @ClientContact
--------------------------------------------------------------
--------------------------------------------------------------
--/*
Declare @ClientContact_Formated table
(
	Client_ID int
	,ContactName VarChar(255)
	,Contact_Phone VarChar(128)
	,Contact_Email VarChar(255)
)
insert into @ClientContact_Formated
select distinct
	J001.Client_ID
	,STUFF
	(
		(
			select distinct
				'~ '
				+ CC.ContactName
			from @ClientContact CC  
			where CC.Client_ID = J001.Client_ID
			for XML path ('')  
		),1,1,''
	)'ContactName'
	,STUFF
	(
		(
			select distinct
				'~ '
				+ CC.Contact_Phone
			from @ClientContact CC  
			where CC.Client_ID = J001.Client_ID
			for XML path ('')  
		),1,1,''
	)'Contact_Phone'
	,STUFF
	(
		(
			select distinct
				'~ '
				+ CC.Contact_Email
			from @ClientContact CC  
			where CC.Client_ID = J001.Client_ID
			for XML path ('')  
		),1,1,''
	)'Contact_Email'

From @ClientContact J001
--*/
--------------------------------------------------------------
--------------------------------------------------------------
--select * from @ClientContact_Formated
--------------------------------------------------------------
--------------------------------------------------------------

--/*
--get DQ_answers for client, make into sub query
--------------------------------------------------------------------------------------
Declare @DQ_Name VarChar(128) = 'DA Service Quote'

Declare @DQ_Results Table
(
	Client_ID int
	,Sessions int
	,HoursPerSession Dec(10,2)
	,QuoteContractAmount Dec (10,2)
	,QuoteCode varchar(64)
	,PortalServBookingDone varchar(8)
	,ServAgreeSigned Varchar(8)
	,SetUpInCC varchar(8)
	,KMsPerServ Dec(10,2)
)
insert into @DQ_Results
select-- distinct
	J101.Client_ID 'Client_ID'
	,cast(A001.Sessions as int)'Sessions'
	,A002.HoursPerSession
	,A003.QuoteContractAmount
	,A004.Answer_Selection 'QuoteCode'
	,A005.Answer_Selection 'PortalServBookingDone'
	,A006.Answer_Selection 'ServAgreeSigned'
	,A007.Answer_Selection 'SetUpInCC'
	,A008.KMsPerServ

from @ClientTable J101

Left outer join
(
	select distinct
		DQ_E_Q.Respondent_ID
		,DQ_E_Q.Entity_Questionnaire_ID
	from dbo.DQ_Questionnaire DQ_Q
	inner join dbo.DQ_Entity_Questionnaire DQ_E_Q on DQ_E_Q.Questionnaire_Code = DQ_Q.Questionnaire_Code
	where 
	1=1
	and DQ_Q.Description = @DQ_Name
	and DQ_Q.Effective_To_Date is null
)J001 on J001.Respondent_ID = J101.Client_ID

Left outer join
(
	Select distinct
		DQ_Answer.Entity_Questionnaire_ID
		,DQ_Answer.Numeric_Value 'Sessions'
	From dbo.DQ_Entity_Questionnaire_Answer DQ_Answer
	where DQ_Answer.Question_No = 1
)A001 on A001.Entity_Questionnaire_ID = J001.Entity_Questionnaire_ID

Left outer join
(
	Select distinct
		DQ_Answer.Entity_Questionnaire_ID
		,DQ_Answer.Numeric_Value 'HoursPerSession'
	From dbo.DQ_Entity_Questionnaire_Answer DQ_Answer
	where DQ_Answer.Question_No = 2
)A002 on A002.Entity_Questionnaire_ID = J001.Entity_Questionnaire_ID

Left outer join
(
	Select distinct
		DQ_Answer.Entity_Questionnaire_ID
		,DQ_Answer.Numeric_Value 'QuoteContractAmount'
	From dbo.DQ_Entity_Questionnaire_Answer DQ_Answer
	where DQ_Answer.Question_No = 6
)A003 on A003.Entity_Questionnaire_ID = J001.Entity_Questionnaire_ID

Left outer join
(
	Select distinct
		DQ_Answer.Entity_Questionnaire_ID
		,DQ_QSL.Description 'Answer_Selection'
	From dbo.DQ_Entity_Questionnaire_Answer DQ_Answer
	Left outer join dbo.DQ_Entity_Questionnaire_Answer_List DQ_EQA on DQ_EQA.Questionnaire_Code = DQ_Answer.Questionnaire_Code and DQ_EQA.Entity_Questionnaire_Answer_ID = DQ_Answer.Entity_Questionnaire_Answer_ID
	Left outer join dbo.DQ_Question_Selection_List DQ_QSL on DQ_QSL.Questionnaire_Code = DQ_Answer.Questionnaire_Code and DQ_QSL.Question_No = 4 and DQ_EQA.Question_Selection_List_No = DQ_QSL.Question_Selection_List_No
	where DQ_Answer.Question_No = 4
)A004 on A004.Entity_Questionnaire_ID = J001.Entity_Questionnaire_ID

Left outer join
(
	Select distinct
		DQ_Answer.Entity_Questionnaire_ID
		,DQ_QSL.Description 'Answer_Selection'
	From dbo.DQ_Entity_Questionnaire_Answer DQ_Answer
	Left outer join dbo.DQ_Entity_Questionnaire_Answer_List DQ_EQA on DQ_EQA.Questionnaire_Code = DQ_Answer.Questionnaire_Code and DQ_EQA.Entity_Questionnaire_Answer_ID = DQ_Answer.Entity_Questionnaire_Answer_ID
	Left outer join dbo.DQ_Question_Selection_List DQ_QSL on DQ_QSL.Questionnaire_Code = DQ_Answer.Questionnaire_Code and DQ_QSL.Question_No = 7 and DQ_EQA.Question_Selection_List_No = DQ_QSL.Question_Selection_List_No
	where DQ_Answer.Question_No = 7
)A005 on A005.Entity_Questionnaire_ID = J001.Entity_Questionnaire_ID

Left outer join
(
	Select distinct
		DQ_Answer.Entity_Questionnaire_ID
		,DQ_QSL.Description 'Answer_Selection'
	From dbo.DQ_Entity_Questionnaire_Answer DQ_Answer
	Left outer join dbo.DQ_Entity_Questionnaire_Answer_List DQ_EQA on DQ_EQA.Questionnaire_Code = DQ_Answer.Questionnaire_Code and DQ_EQA.Entity_Questionnaire_Answer_ID = DQ_Answer.Entity_Questionnaire_Answer_ID
	Left outer join dbo.DQ_Question_Selection_List DQ_QSL on DQ_QSL.Questionnaire_Code = DQ_Answer.Questionnaire_Code and DQ_QSL.Question_No = 8 and DQ_EQA.Question_Selection_List_No = DQ_QSL.Question_Selection_List_No
	where DQ_Answer.Question_No = 8
)A006 on A006.Entity_Questionnaire_ID = J001.Entity_Questionnaire_ID

Left outer join
(
	Select distinct
		DQ_Answer.Entity_Questionnaire_ID
		,DQ_QSL.Description 'Answer_Selection'
	From dbo.DQ_Entity_Questionnaire_Answer DQ_Answer
	Left outer join dbo.DQ_Entity_Questionnaire_Answer_List DQ_EQA on DQ_EQA.Questionnaire_Code = DQ_Answer.Questionnaire_Code and DQ_EQA.Entity_Questionnaire_Answer_ID = DQ_Answer.Entity_Questionnaire_Answer_ID
	Left outer join dbo.DQ_Question_Selection_List DQ_QSL on DQ_QSL.Questionnaire_Code = DQ_Answer.Questionnaire_Code and DQ_QSL.Question_No = 9 and DQ_EQA.Question_Selection_List_No = DQ_QSL.Question_Selection_List_No
	where DQ_Answer.Question_No = 9
)A007 on A007.Entity_Questionnaire_ID = J001.Entity_Questionnaire_ID

Left outer join
(
	Select distinct
		DQ_Answer.Entity_Questionnaire_ID
		,DQ_Answer.Numeric_Value 'KMsPerServ'
	From dbo.DQ_Entity_Questionnaire_Answer DQ_Answer
	where DQ_Answer.Question_No = 10
)A008 on A008.Entity_Questionnaire_ID = J001.Entity_Questionnaire_ID


--*/
where
	1=1 
	and J001.Respondent_ID is not null
--------------------------------------------------------------
--------------------------------------------------------------
--select * from @DQ_Results
--------------------------------------------------------------
--------------------------------------------------------------
--*/

--ServiceDelivery INFO collection
Declare @ServDeliv_collected table
(
	Client_ID int
	,Service varchar(256)
	,ToDate Varchar(64)
)
insert into @ServDeliv_collected
select
	J001.Client_ID
	,J002.Description 'Service'
	,iif(J001.To_Date is null, '-none-',cast(cast(J001.To_Date as datetime) as varchar(64)))'To_Date'
From @ClientTable J101
Left outer join dbo.Service_Delivery J001 on J001.Client_ID = J101.Client_ID
Left outer join dbo.Service_Type J002 on J002.Service_Type_Code = J001.Service_Type_Code and J002.Effective_To_Date is null
--------------------------------------------------------------
--------------------------------------------------------------
--select * from @ServDeliv_collected
--------------------------------------------------------------
--------------------------------------------------------------
Declare @ServDeliv_Formated table
(
	Client_ID int
	,Service varchar(max)
	,ToDate Varchar(256)
)
insert into @ServDeliv_Formated
select distinct
J001.Client_ID
	,STUFF
	(
		(
			select-- distinct
				'~ '
				+ SD_C.Service
			from @ServDeliv_collected SD_C  
			where SD_C.Client_ID = J001.Client_ID-- and SD_C.RN = J001.RN
			for XML path ('')  
		),1,1,''
	)'Service'
	,STUFF
	(
		(
			select --distinct
				'~ '
				+ SD_C.ToDate
			from @ServDeliv_collected SD_C  
			where SD_C.Client_ID = J001.Client_ID-- and SD_C.RN = J001.RN
			for XML path ('')  
		),1,1,''
	)'ToDate'
from @ServDeliv_collected J001
--------------------------------------------------------------
--------------------------------------------------------------
--select * from @ServDeliv_Formated
--------------------------------------------------------------
--------------------------------------------------------------

Declare @BillingGroup table
(
	Client_ID int
	,BillingGroup VarChar(128)
	,Billing_End_Date VarChar(64)
)
insert into @BillingGroup
select
J001.Client_ID
,J003.Description 'BillingGroup'
,iif(J002.Billing_End_Date is null,'-none-',Cast(Cast(J002.Billing_End_Date as datetime) as varChar(64)))'Billing_End_Date'

From @ClientTable J001
LEFT outer join dbo.FB_Client_Contract_Billing J002 on J002.Client_ID = J001.Client_ID
LEFT OUTER JOIN dbo.FB_Contract_Billing_Group J003 on J003.Contract_Billing_Group_ID = J002.Contract_Billing_Group_ID

--------------------------------------------------------------
--------------------------------------------------------------
--select * from @BillingGroup
--------------------------------------------------------------
--------------------------------------------------------------
declare @BillingGroup_Formated table
(
	Client_ID int
	,BillingGroup VarChar(Max)
	,Billing_End_Date VarChar(256)
)
insert into @BillingGroup_Formated
select distinct
J001.Client_ID
	,STUFF
	(
		(
			select-- distinct
				'~ '
				+ BG.BillingGroup
			from @BillingGroup BG  
			where BG.Client_ID = J001.Client_ID-- and SD_C.RN = J001.RN
			for XML path ('')  
		),1,1,''
	)'BillingGroup'
	,STUFF
	(
		(
			select --distinct
				'~ '
				+ BG.Billing_End_Date
			from @BillingGroup BG  
			where BG.Client_ID = J001.Client_ID-- and SD_C.RN = J001.RN
			for XML path ('')  
		),1,1,''
	)'Billing_End_Date'
from @BillingGroup J001

--------------------------------------------------------------
--------------------------------------------------------------
--select * from @BillingGroup_Formated
--------------------------------------------------------------
--------------------------------------------------------------
