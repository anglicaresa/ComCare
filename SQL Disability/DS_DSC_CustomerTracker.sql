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
--Declare @Client_ID int = 10073115 --has DQ
--Declare @Client_ID int = 10072693
--Declare @Client_ID int = 10080247
--Declare @Client_ID int = 10071624
--Declare @Client_ID int = 10072283

--with DQ 
Declare @Client_ID int = 10073115
--Declare @Client_ID int = 10072734

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
	,dwelling_number VarChar(128)
	,Street Varchar(255)
	,suburb Varchar(255)
	,Post_Code int
	,HasGOC VarChar(255)
	,Diagnosis VarChar(max)
	,ServiceDelivery_StartDate VarChar(Max)
	,ServiceDelivery_EndDate VarChar(Max)
	,ServiceDelivery_DischargeDate VarChar(Max)
	,NDIS_Number varchar(64)
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
				'~br^ '+ DC.Description 
			from dbo.Diagnosis D 
			left outer join dbo.Diagnosis_Category DC ON DC.Diagnosis_Category_Code = D.Diagnosis_Category_Code 
			where D.Client_ID = J003.Client_ID
			for XML path ('')  
		),1,5,''--stuff args to remove first comma
	)'Diagnosis'
	,STUFF
	(
		(
			select distinct
				'~br^ '+ Concat(ST.Description,' - ',Format(SD.From_Date,'dd/MM/yyyy')) 
			from 
			(
				select
				SD_inner.*
				,ROW_NUMBER()
				Over
				(
					Partition by SD_Inner.Client_ID, SD_Inner.Service_Type_Code 
					Order By Case 
						When SD_Inner.To_Date is null then 'zzz'
						else cast(SD_Inner.To_Date as varchar(64))
						end Desc
				)'RN'
				From dbo.Service_Delivery SD_inner 
			) SD 
			left outer join dbo.Service_Type ST ON ST.Service_Type_Code = SD.Service_Type_Code 
			where 
				1=1
			--	and SD.Client_ID = 10073115
				and SD.Client_ID = J003.Client_ID
				and (RN is null or RN =1)
			for XML path ('')  
		),1,5,''--stuff args to remove first comma
	)'ServiceDelivery_StartDate'
	,STUFF
	(
		(
			select distinct
				'~br^ '
				+ Concat(ST.Description,' - ',iif(SD.To_Date is null,'No End Date' ,Format(SD.To_Date,'dd/MM/yyyy'))) 
			from 
			(
				select
				SD_inner.*
				,ROW_NUMBER()
				Over
				(
					Partition by SD_Inner.Client_ID, SD_Inner.Service_Type_Code 
					Order By Case 
						When SD_Inner.To_Date is null then 'zzz'
						else cast(SD_Inner.To_Date as varchar(64))
						end Desc
				)'RN'
				From dbo.Service_Delivery SD_inner 
			) SD
			left outer join dbo.Service_Type ST ON ST.Service_Type_Code = SD.Service_Type_Code 
			
			where 
				SD.Client_ID = J003.Client_ID
				and (RN is null or RN =1)
			for XML path ('')  
		),1,5,''--stuff args to remove first comma
	)'ServiceDelivery_EndDate'
		,STUFF
	(
		(
			select distinct
				'~br^ '
				+ Concat(ST.Description,' - ',iif(SD.To_Date is null and SD.Serv_Del_Outcome_Code Is null,'No End Date' ,Concat(Format(SD.To_Date,'dd/MM/yyyy'),' - ',SDO.Description))) 
			from 
			(
				select
				SD_inner.*
				,ROW_NUMBER()
				Over
				(
					Partition by SD_Inner.Client_ID, SD_Inner.Service_Type_Code 
					Order By Case 
						When SD_Inner.To_Date is null then 'zzz'
						else cast(SD_Inner.To_Date as varchar(64))
						end Desc
				)'RN'
				From dbo.Service_Delivery SD_inner 
			) SD
			left outer join dbo.Service_Type ST ON ST.Service_Type_Code = SD.Service_Type_Code 
			left outer join dbo.Service_Delivery_Outcome SDO on SDO.Serv_Del_Outcome_Code = SD.Serv_Del_Outcome_Code
			where 
				SD.Client_ID = J003.Client_ID
				and (RN is null or RN =1)
			for XML path ('')  
		),1,5,''--stuff args to remove first comma
	)'ServiceDelivery_DischargeDate'
	,iif(J007.Status = 1 ,Cast( J007.Card_No AS varchar(64)),Cast( J007.Card_No AS varchar(64))+' [Expired]') 'NDIS_Number'
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
Left outer join dbo.FC_Client_Contract J003 on J002.funder_Contract_ID = J003.funder_Contract_ID and (J003.Effective_To_Date is null or J003.Effective_To_Date > GETDATE())
inner join dbo.Person J004 on J004.Person_ID = J003.Client_ID

LEFT OUTER JOIN dbo.Person_Current_Address_Phone J005 ON J005.Person_id = J003.Client_ID
Left outer join
(
	select distinct
	CC.Client_ID
	,iif(GOC.Client_Contract_ID is not null, 'Yes','No')'HasGOC'
	,ROW_NUMBER()Over
	(
		partition by CC.Client_ID Order By case 
			when GOC.Client_Contract_ID is not null then '1'
			Else '2'
			end
	)'RN'
	From dbo.FC_Client_Contract CC
	LEFT OUTER JOIN
	(
		select distinct
		GOC.Client_Contract_ID
		from dbo.FC_Client_Goal_of_Care GOC
	)GOC on GOC.Client_Contract_ID = CC.Client_Contract_ID
)J006 on J006.Client_ID = J003.Client_ID and (J006.RN < 2 or J006.RN is null)

LEFT OUTER JOIN 
(
	Select
	CH.Card_Type_ID
	,CH.Person_ID
	,CH.Valid_From_Date
	,CH.Expiry_Date
	,CH.Card_No
	,iif (GetDate() Between CH.Valid_From_Date and CH.Expiry_Date,1,0)'Status'
	,ROW_NUMBER()over(Partition by CH.Person_ID,CH.Card_Type_ID order by CH.Valid_From_Date Desc)RN
	From dbo.Card_Holder CH
)J007 ON J007.Person_ID = J003.Client_ID and J007.Card_Type_ID = 15 and J007.RN = 1


where
	1=1
	and 1 = iif(@UseSingleID = 1 , iif(J003.Client_ID = @Client_ID, 1, 0),1)

)T1
Order by
	3,2,1
--------------------------------------------------------------
--------------------------------------------------------------
--select * from @ClientTable
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
		PC.Person_ID
		,PC.Contact_ID
		,PCT.Description
		,ROW_NUMBER() Over
		(
			Partition BY PC.Person_ID Order By
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
				'~br^ '
				+ CC.ContactName
			from @ClientContact CC  
			where CC.Client_ID = J001.Client_ID
			for XML path ('')  
		),1,5,''
	)'ContactName'
	,STUFF
	(
		(
			select distinct
				'~br^ '
				+ CC.Contact_Phone
			from @ClientContact CC  
			where CC.Client_ID = J001.Client_ID
			for XML path ('')  
		),1,5,''
	)'Contact_Phone'
	,STUFF
	(
		(
			select distinct
				'~br^ '
				+ CC.Contact_Email
			from @ClientContact CC  
			where CC.Client_ID = J001.Client_ID
			for XML path ('')  
		),1,5,''
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

Declare @DQ_Name VarChar(128) = 'DC Service Quote'

Declare @DQ_Results Table
(
	Client_ID int
	,DQ_Group int
	,Sessions int
	,HoursPerSession Dec(10,2)
	,QuoteContractAmount Dec (10,2)
	,QuoteCode varchar(64)
	,PortalServBookingDone varchar(8)
	,ServAgreeSigned Varchar(8)
	,SetUpInCC varchar(8)
	,KMsPerServ Dec(10,2)
	,DQ_Date Date
	,Quote_StartDate date
	,Quote_EndDate date
)
insert into @DQ_Results
select-- distinct
	J101.Client_ID 'Client_ID'
	,A001.Group_1
	,cast(A001.Sessions as int)'Sessions'
	,A002.HoursPerSession
	,A003.QuoteContractAmount
	,A004.QuoteCode
	,A005.PortalServBookingDone
	,A006.ServAgreeSigned
	,A007.SetUpInCC
	,A008.KMsPerServ
	,J001.Questionnaire_Date
	,A009.Quote_StartDate
	,A010.Quote_EndDate
from @ClientTable J101

Left outer join
(
	select distinct
		DQ_E_Q.Respondent_ID
		,DQ_Q.Questionnaire_Code
		,DQ_Q.Description
		,DQ_E_Q.Entity_Questionnaire_ID
		,DQ_E_Q.Questionnaire_Date
		,ROW_NUMBER()Over(Partition by DQ_Q.Description,DQ_E_Q.Respondent_ID order by DQ_E_Q.Questionnaire_Date Desc)'RN'
	from dbo.DQ_Questionnaire DQ_Q
	left outer join dbo.DQ_Entity_Questionnaire DQ_E_Q on DQ_E_Q.Questionnaire_Code = DQ_Q.Questionnaire_Code
	where 
	1=1
	and DQ_Q.Description = @DQ_Name
--	and DQ_Q.Effective_To_Date is null
)J001 on J001.Respondent_ID = J101.Client_ID and J001.RN = 1

Left outer join
(
	Select --distinct
		DQ_Answer.Entity_Questionnaire_ID
		,DQ_Quest.Questionnaire_Code
		,DQ_Answer.Numeric_Value 'Sessions'
		,Format(Cast(Replace(DQ_Quest.Question_Group_Code ,DQ_Quest.Questionnaire_Code+'_G' , '') as int),'0#')'Group_1'
	From dbo.DQ_Questionnaire_Question DQ_Quest
	left outer join dbo.DQ_Entity_Questionnaire_Answer DQ_Answer on DQ_Answer.Question_No = DQ_Quest.Question_No and DQ_Answer.Questionnaire_Code = DQ_Quest.Questionnaire_Code
	where DQ_Quest.Description = 'Number of Sessions'
)A001 on A001.Entity_Questionnaire_ID = J001.Entity_Questionnaire_ID and A001.Questionnaire_Code = J001.Questionnaire_Code

Left outer join
(
	Select --distinct
		DQ_Answer.Entity_Questionnaire_ID
		,DQ_Quest.Questionnaire_Code
		,DQ_Answer.Numeric_Value 'HoursPerSession'
		,Format(Cast(Replace(DQ_Quest.Question_Group_Code ,DQ_Quest.Questionnaire_Code+'_G' , '') as int),'0#')'Group_1'
	From dbo.DQ_Questionnaire_Question DQ_Quest
	left outer join dbo.DQ_Entity_Questionnaire_Answer DQ_Answer on DQ_Answer.Question_No = DQ_Quest.Question_No and DQ_Answer.Questionnaire_Code = DQ_Quest.Questionnaire_Code
	where DQ_Quest.Description = 'Number of Hours'
)A002 on A002.Entity_Questionnaire_ID = A001.Entity_Questionnaire_ID and A002.Questionnaire_Code = A001.Questionnaire_Code and A002.Group_1 = A001.Group_1

Left outer join
(
	Select distinct
		DQ_Answer.Entity_Questionnaire_ID
		,DQ_Quest.Questionnaire_Code
		,DQ_Answer.Numeric_Value 'QuoteContractAmount'
		,Format(Cast(Replace(DQ_Quest.Question_Group_Code ,DQ_Quest.Questionnaire_Code+'_G' , '') as int),'0#')'Group_1'
	From dbo.DQ_Questionnaire_Question DQ_Quest
	left outer join dbo.DQ_Entity_Questionnaire_Answer DQ_Answer on DQ_Answer.Question_No = DQ_Quest.Question_No and DQ_Answer.Questionnaire_Code = DQ_Quest.Questionnaire_Code
	where DQ_Quest.Description = 'Line Total'
)A003 on A003.Entity_Questionnaire_ID = J001.Entity_Questionnaire_ID and A003.Questionnaire_Code = J001.Questionnaire_Code and A001.Group_1 = A003.Group_1

Left outer join
(
	Select distinct
		DQ_Answer.Entity_Questionnaire_ID
		,DQ_Quest.Questionnaire_Code
		,DQ_Answer.Text_Value 'QuoteCode'
		,Format(Cast(Replace(DQ_Quest.Question_Group_Code ,DQ_Quest.Questionnaire_Code+'_G' , '') as int),'0#')'Group_1'
	From dbo.DQ_Questionnaire_Question DQ_Quest
	left outer join dbo.DQ_Entity_Questionnaire_Answer DQ_Answer on DQ_Answer.Question_No = DQ_Quest.Question_No and DQ_Answer.Questionnaire_Code = DQ_Quest.Questionnaire_Code
	where DQ_Quest.Description = 'NDIA Item Code'
)A004 on A004.Entity_Questionnaire_ID = J001.Entity_Questionnaire_ID and A004.Questionnaire_Code = J001.Questionnaire_Code and A001.Group_1 = A004.Group_1

Left outer join
(
	Select distinct
		DQ_Answer.Entity_Questionnaire_ID
		,DQ_Quest.Questionnaire_Code
		,DQ_QSL.Description 'PortalServBookingDone'
		,Format(Cast(Replace(DQ_Quest.Question_Group_Code ,DQ_Quest.Questionnaire_Code+'_G' , '') as int),'0#')'Group_1'
	From dbo.DQ_Questionnaire_Question DQ_Quest
	left outer join dbo.DQ_Entity_Questionnaire_Answer DQ_Answer on DQ_Answer.Question_No = DQ_Quest.Question_No and DQ_Answer.Questionnaire_Code = DQ_Quest.Questionnaire_Code
	Left outer join dbo.DQ_Entity_Questionnaire_Answer_List DQ_EQA on DQ_EQA.Questionnaire_Code = DQ_Answer.Questionnaire_Code and DQ_EQA.Entity_Questionnaire_Answer_ID = DQ_Answer.Entity_Questionnaire_Answer_ID
	Left outer join dbo.DQ_Question_Selection_List DQ_QSL on DQ_QSL.Questionnaire_Code = DQ_Answer.Questionnaire_Code and DQ_QSL.Question_No = 7 and DQ_EQA.Question_Selection_List_No = DQ_QSL.Question_Selection_List_No
	where DQ_Quest.Description = 'Is the Portal Service Booking complete?'
)A005 on A005.Entity_Questionnaire_ID = J001.Entity_Questionnaire_ID and A005.Questionnaire_Code = J001.Questionnaire_Code and A001.Group_1 = A005.Group_1

Left outer join
(
	Select distinct
		DQ_Answer.Entity_Questionnaire_ID
		,DQ_Quest.Questionnaire_Code
		,DQ_QSL.Description 'ServAgreeSigned'
		,Format(Cast(Replace(DQ_Quest.Question_Group_Code ,DQ_Quest.Questionnaire_Code+'_G' , '') as int),'0#')'Group_1'
	From dbo.DQ_Questionnaire_Question DQ_Quest
	left outer join dbo.DQ_Entity_Questionnaire_Answer DQ_Answer on DQ_Answer.Question_No = DQ_Quest.Question_No and DQ_Answer.Questionnaire_Code = DQ_Quest.Questionnaire_Code
	Left outer join dbo.DQ_Entity_Questionnaire_Answer_List DQ_EQA on DQ_EQA.Questionnaire_Code = DQ_Answer.Questionnaire_Code and DQ_EQA.Entity_Questionnaire_Answer_ID = DQ_Answer.Entity_Questionnaire_Answer_ID
	Left outer join dbo.DQ_Question_Selection_List DQ_QSL on DQ_QSL.Questionnaire_Code = DQ_Answer.Questionnaire_Code and DQ_QSL.Question_No = 8 and DQ_EQA.Question_Selection_List_No = DQ_QSL.Question_Selection_List_No
	where DQ_Quest.Description = 'Is the Service Agreement signed and on file?'
)A006 on A006.Entity_Questionnaire_ID = J001.Entity_Questionnaire_ID and A006.Questionnaire_Code = J001.Questionnaire_Code and A001.Group_1 = A006.Group_1

Left outer join
(
	Select distinct
		DQ_Answer.Entity_Questionnaire_ID
		,DQ_Quest.Questionnaire_Code
		,DQ_QSL.Description 'SetUpInCC'
		,Format(Cast(Replace(DQ_Quest.Question_Group_Code ,DQ_Quest.Questionnaire_Code+'_G' , '') as int),'0#')'Group_1'
	From dbo.DQ_Questionnaire_Question DQ_Quest
	left outer join dbo.DQ_Entity_Questionnaire_Answer DQ_Answer on DQ_Answer.Question_No = DQ_Quest.Question_No and DQ_Answer.Questionnaire_Code = DQ_Quest.Questionnaire_Code
	Left outer join dbo.DQ_Entity_Questionnaire_Answer_List DQ_EQA on DQ_EQA.Questionnaire_Code = DQ_Answer.Questionnaire_Code and DQ_EQA.Entity_Questionnaire_Answer_ID = DQ_Answer.Entity_Questionnaire_Answer_ID
	Left outer join dbo.DQ_Question_Selection_List DQ_QSL on DQ_QSL.Questionnaire_Code = DQ_Answer.Questionnaire_Code and DQ_QSL.Question_No = 9 and DQ_EQA.Question_Selection_List_No = DQ_QSL.Question_Selection_List_No
	where DQ_Quest.Description = 'Is this service entered into ComCare?'
)A007 on A007.Entity_Questionnaire_ID = J001.Entity_Questionnaire_ID and A007.Questionnaire_Code = J001.Questionnaire_Code and A001.Group_1 = A007.Group_1

Left outer join
(
	Select distinct
		DQ_Answer.Entity_Questionnaire_ID
		,DQ_Quest.Questionnaire_Code
		,DQ_Answer.Numeric_Value 'KMsPerServ'
		,Format(Cast(Replace(DQ_Quest.Question_Group_Code ,DQ_Quest.Questionnaire_Code+'_G' , '') as int),'0#')'Group_1'
	From dbo.DQ_Questionnaire_Question DQ_Quest
	left outer join dbo.DQ_Entity_Questionnaire_Answer DQ_Answer on DQ_Answer.Question_No = DQ_Quest.Question_No and DQ_Answer.Questionnaire_Code = DQ_Quest.Questionnaire_Code
	Left outer join dbo.DQ_Entity_Questionnaire_Answer_List DQ_EQA on DQ_EQA.Questionnaire_Code = DQ_Answer.Questionnaire_Code and DQ_EQA.Entity_Questionnaire_Answer_ID = DQ_Answer.Entity_Questionnaire_Answer_ID
	where DQ_Quest.Description like 'Total KLM%s quoted per service.'
)A008 on A008.Entity_Questionnaire_ID = J001.Entity_Questionnaire_ID and A008.Questionnaire_Code = J001.Questionnaire_Code and A001.Group_1 = A008.Group_1

Left outer join
(
	Select distinct
		DQ_Answer.Entity_Questionnaire_ID
		,DQ_Quest.Questionnaire_Code
		,DQ_Answer.Date_Value 'Quote_StartDate'
		,Format(Cast(Replace(DQ_Quest.Question_Group_Code ,DQ_Quest.Questionnaire_Code+'_G' , '') as int),'0#')'Group_1'
	From dbo.DQ_Questionnaire_Question DQ_Quest
	left outer join dbo.DQ_Entity_Questionnaire_Answer DQ_Answer on DQ_Answer.Question_No = DQ_Quest.Question_No and DQ_Answer.Questionnaire_Code = DQ_Quest.Questionnaire_Code
	where DQ_Quest.Description = 'Service Quote Start Date'
)A009 on A009.Entity_Questionnaire_ID = J001.Entity_Questionnaire_ID and A009.Questionnaire_Code = J001.Questionnaire_Code and A009.Group_1 = 01

Left outer join
(
	Select distinct
		DQ_Answer.Entity_Questionnaire_ID
		,DQ_Quest.Questionnaire_Code
		,DQ_Answer.Date_Value 'Quote_EndDate'
		,Format(Cast(Replace(DQ_Quest.Question_Group_Code ,DQ_Quest.Questionnaire_Code+'_G' , '') as int),'0#')'Group_1'
	From dbo.DQ_Questionnaire_Question DQ_Quest
	left outer join dbo.DQ_Entity_Questionnaire_Answer DQ_Answer on DQ_Answer.Question_No = DQ_Quest.Question_No and DQ_Answer.Questionnaire_Code = DQ_Quest.Questionnaire_Code
	where DQ_Quest.Description = 'Service Quote Expiration Date'
)A010 on A010.Entity_Questionnaire_ID = J001.Entity_Questionnaire_ID and A010.Questionnaire_Code = J001.Questionnaire_Code and A010.Group_1 = 01

where
	1=1 
	and J001.Respondent_ID is not null
	and A004.QuoteCode is not null
order by
1,2
--*/
--------------------------------------------------------------
--------------------------------------------------------------
--select * from @DQ_Results
--------------------------------------------------------------
--------------------------------------------------------------
--/*
Declare @DQ_Results_Formated Table
(
	Client_ID int
	,Sessions VarChar(128)
	,HoursPerSession VarChar(128)
	,QuoteContractAmount VarChar(128)
	,QuoteCode varchar(max)
	,PortalServBookingDone varchar(128)
	,ServAgreeSigned Varchar(128)
	,SetUpInCC varchar(128)
	,KMsPerServ VarChar(128)
	,DQ_Date Date
	,Quote_StartDate Date
	,Quote_EndDate Date
)
insert into @DQ_Results_Formated
select distinct
	J001.Client_ID
	,STUFF
	(
		(
			Select
			'~br^ '+ cast(iif(DQR.Sessions is null,'---',DQR.Sessions) as varchar(128))
			From @DQ_Results DQR where DQR.Client_ID = J001.Client_ID
			For XML path ('')
		)
		,1,5,''
	) 'Sessions'
	,STUFF
	(
		(
			Select
			'~br^ '+ cast(iif(DQR.HoursPerSession is null,'---',DQR.HoursPerSession) as varchar(128))
			From @DQ_Results DQR where DQR.Client_ID = J001.Client_ID
			For XML path ('')
		)
		,1,5,''
	) 'HoursPerSession'
	,STUFF
	(
		(
			Select
			'~br^ '+ cast(iif(DQR.QuoteContractAmount is null,'---',DQR.QuoteContractAmount) as varchar(128))
			From @DQ_Results DQR where DQR.Client_ID = J001.Client_ID
			For XML path ('')
		)
		,1,5,''
	) 'QuoteContractAmount'
	,STUFF
	(
		(
			Select
			'~br^ '+ DQR.QuoteCode
			From @DQ_Results DQR where DQR.Client_ID = J001.Client_ID
			For XML path ('')
		)
		,1,5,''
	) 'QuoteCode'
	,STUFF
	(
		(
			Select
			'~br^ '+ iif(DQR.PortalServBookingDone is null,'No',DQR.PortalServBookingDone)
			From @DQ_Results DQR where DQR.Client_ID = J001.Client_ID
			For XML path ('')
		)
		,1,5,''
	) 'PortalServBookingDone'
	,STUFF
	(
		(
			Select
			'~br^ '+ iif(DQR.ServAgreeSigned is null,'No',DQR.ServAgreeSigned)
			From @DQ_Results DQR where DQR.Client_ID = J001.Client_ID
			For XML path ('')
		)
		,1,5,''
	) 'ServAgreeSigned'
	,STUFF
	(
		(
			Select
			'~br^ '+ iif(DQR.SetUpInCC is null,'No',DQR.SetUpInCC)
			From @DQ_Results DQR where DQR.Client_ID = J001.Client_ID
			For XML path ('')
		)
		,1,5,''
	) 'SetUpInCC'
	,STUFF
	(
		(
			Select
			'~br^ '+ Cast(DQR.KMsPerServ as varchar(16))
			From @DQ_Results DQR where DQR.Client_ID = J001.Client_ID
			For XML path ('')
		)
		,1,5,''
	) 'KMsPerServ'
	,J001.DQ_Date
	,J001.Quote_StartDate
	,J001.Quote_EndDate
from @DQ_Results J001
--*/
--------------------------------------------------------------
--------------------------------------------------------------
--select * from @DQ_Results_Formated
--------------------------------------------------------------
--------------------------------------------------------------
--/*

--ServiceDelivery INFO collection
Declare @ServDeliv_collected table
(
	Client_ID int
	,Service varchar(256)
	,ToDate Varchar(64)
	,FundingProg VarChar(128)
)
insert into @ServDeliv_collected
select
	J001.Client_ID
	,J002.Description 'Service'
	,iif(J001.To_Date is null, '-none-',Format(J001.To_Date, 'dd/MM/yyyy'))'To_Date'
	,J003.Description 'FundingProg'
From @ClientTable J101
Left outer join dbo.Service_Delivery J001 on J001.Client_ID = J101.Client_ID
Left outer join dbo.Service_Type J002 on J002.Service_Type_Code = J001.Service_Type_Code and J002.Effective_To_Date is null
Left outer join dbo.Funding_Program J003 on J003.Funding_Prog_Code = J001.Funding_Prog_Code

--*/
--------------------------------------------------------------
--------------------------------------------------------------
--select * from @ServDeliv_collected
--------------------------------------------------------------
--------------------------------------------------------------
--/*
Declare @ServDeliv_Formated table
(
	Client_ID int
	,Service varchar(max)
	,ToDate Varchar(255)
	,FundingProg VarChar(255)
)
insert into @ServDeliv_Formated
select distinct
J001.Client_ID
	,STUFF
	(
		(
			select-- distinct
				'~br^ '
				+ SD_C.Service
			from @ServDeliv_collected SD_C  
			where SD_C.Client_ID = J001.Client_ID-- and SD_C.RN = J001.RN
			for XML path ('')  
		),1,5,''
	)'Service'
	,STUFF
	(
		(
			select --distinct
				'~br^ '
				+ SD_C.ToDate
			from @ServDeliv_collected SD_C  
			where SD_C.Client_ID = J001.Client_ID-- and SD_C.RN = J001.RN
			for XML path ('')  
		),1,5,''
	)'ToDate'
	,STUFF
	(
		(
			select --distinct
				'~br^ '
				+ SD_C.FundingProg
			from @ServDeliv_collected SD_C  
			where SD_C.Client_ID = J001.Client_ID-- and SD_C.RN = J001.RN
			for XML path ('')  
		),1,5,''
	)'FundingProg'
from @ServDeliv_collected J001
--*/
--------------------------------------------------------------
--------------------------------------------------------------
--select * from @ServDeliv_Formated
--------------------------------------------------------------
--------------------------------------------------------------
--/*
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
,iif(J002.Billing_End_Date is null,'-none-',Format(J002.Billing_End_Date, 'dd/MM/yyyy'))'Billing_End_Date'

From @ClientTable J001
LEFT outer join dbo.FB_Client_Contract_Billing J002 on J002.Client_ID = J001.Client_ID
LEFT OUTER JOIN dbo.FB_Contract_Billing_Group J003 on J003.Contract_Billing_Group_ID = J002.Contract_Billing_Group_ID
--*/
--------------------------------------------------------------
--------------------------------------------------------------
--select * from @BillingGroup
--------------------------------------------------------------
--------------------------------------------------------------
--/*
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
				'~br^ '
				+ BG.BillingGroup
			from @BillingGroup BG  
			where BG.Client_ID = J001.Client_ID-- and SD_C.RN = J001.RN
			for XML path ('')  
		),1,5,''
	)'BillingGroup'
	,STUFF
	(
		(
			select --distinct
				'~br^ '
				+ BG.Billing_End_Date
			from @BillingGroup BG  
			where BG.Client_ID = J001.Client_ID-- and SD_C.RN = J001.RN
			for XML path ('')
		),1,5,''
	)'Billing_End_Date'
from @BillingGroup J001
--*/
--------------------------------------------------------------
--------------------------------------------------------------
--select * from @BillingGroup_Formated
--------------------------------------------------------------
--------------------------------------------------------------
--/*
--Client Refferal
Declare @ClientReferral Table
(
	Client_ID int
	,Referral_Date VarChar(255)
	,Referral_Source VarChar(255)
	,Referral_Comments VarChar(Max)
	,Referral_ServRequested VarChar(255)
	,FirstBookedVisit Date
)

insert into @ClientReferral
select Distinct
J001.Client_ID 
,Cast(STUFF
	( 
		(
		select-- distinct
			'~br^ '+ Format(Rf.Referral_Date, 'dd/MM/yyyy')
			from dbo.Referral Rf
			where Rf.Client_ID = J001.Client_ID
		for XML path ('') 
		) ,1,5,''
	) as VarChar(255))'Referral_Date'
,Cast(STUFF
	( 
		(
			select-- distinct
				'~br^ '+ Format(Rf.Referral_Date, 'dd/MM/yyyy - ')+iif (Org.Organisation_Name Like 'NDIA %','~B^ NDIA~/B^ ','~B^ Other~/B^ ')
			from dbo.Referral Rf
			Left outer join dbo.Referral_Source_Category RS on RS.Ref_Source_Category_Code = Rf.Ref_Source_Category_Code
			Left outer join dbo.Organisation org on org.Organisation_ID = Rf.Organisation_ID
			where Rf.Client_ID = J001.Client_ID
			for XML path ('') 
		) ,1,5,''
	)as varchar(255))'Referral_Source'
,Cast(STUFF
	( 
		(
			select
				'~br^ '+iif (Org.Organisation_Name Like 'NDIA %','~B^ NDIA~/B^  - ','~B^ Other~/B^  - ')+ iif(Rf.Referral_Comments is null,'No Comments',Rf.Referral_Comments)
			from dbo.Referral Rf
			Left outer join dbo.Referral_Source_Category RS on RS.Ref_Source_Category_Code = Rf.Ref_Source_Category_Code
			Left outer join dbo.Organisation org on org.Organisation_ID = Rf.Organisation_ID
			where Rf.Client_ID = J001.Client_ID
			for XML path ('') 
		) ,1,5,''
	)as VarChar(Max))'Referral_Comments'
,Cast(Stuff
	( 
		(
			select
				'~br^ '+ iif(ST.Description is null,'None',ST.Description)
			from dbo.Referral Rf
			Left outer join dbo.Service_Requested SR on SR.Client_ID = Rf.Client_ID and SR.Referral_No = Rf.Referral_No
			Left outer join dbo.Service_Type ST on ST.Service_Type_Code = SR.Service_Type_Code
			where Rf.Client_ID = J001.Client_ID
			for XML path ('') 
		) ,1,5,''
	) as VarChar(255))'Referral_ServRequested'
,J002.Activity_Date 'FirstBookedVisit'
from @ClientTable J001
Left Outer Join
(
	Select
	wia.Client_ID
	,cast(wia.Activity_Date as date)'Activity_Date'
	,ROW_NUMBER()over(Partition by wia.Client_ID Order by wia.Activity_Date)'RN'
	from dbo.WI_Activity wia
	inner Join @ClientTable CT on CT.Client_ID = wia.Client_ID and wia.Event_Type = 15
)J002 on J002.Client_ID = J001.Client_ID and J002.RN = 1

--*/
--------------------------------------------------------------
--------------------------------------------------------------
--select * from @ClientReferral
--------------------------------------------------------------
--------------------------------------------------------------


--Client Funding model
Declare @Client_FundingModel table
(
	Client_ID int
	,FunderPrograms VarChar(128)
)
insert into @Client_FundingModel
select distinct
	J001.Client_ID
	,STUFF
	(
		(
			Select distinct
			'~br^ '+ 
			Case 
			when FP.Description like '%NDIS%' then 'NDIS '
			when FP.Description like '%DCSI%' then 'DCSI '
			else 'Fee For Service '
			end
				
			From dbo.Service_Delivery SD
			Left outer Join dbo.Funding_Program FP on FP.Funding_Prog_Code = SD.Funding_Prog_Code
			where SD.Client_ID = J001.Client_ID and (SD.To_Date > GETDATE() or SD.To_Date is null)
			for XML path ('') 
		)
		,1,5,''
	)'FunderPrograms'
	--,JX002.From_Date
From @ClientTable J001
--------------------------------------------------------------
--------------------------------------------------------------
--select * from @Client_FundingModel
--------------------------------------------------------------
--------------------------------------------------------------

Declare @Client_SelfManaged_1 Table
(
	Client_ID int
	,Contract_Billing_Group VarChar(128)
	,SelfManaged VarChar (8)
)

insert into @Client_SelfManaged_1

Select distinct
	J101.Client_ID
	,iif(J002.Description is null, 'No Billing Contract',J002.Description)'Contract_Billing_Group'
	,Case
		When J004.Organisation_ID is not null then 'No'
		When J004.Organisation_ID Is null and J002.Description Is not null and J002.Description not Like '%DCSI%' then 'Yes'
		when J002.Description Like '%DCSI%' then 'No'
		When J002.Description is null then 'Not Defined'
		end 'SelfManaged'
From @ClientTable J101
Left outer Join dbo.FB_Client_Contract_Billing J001 on J001.Client_ID = J101.Client_ID
LEFT OUTER JOIN dbo.FB_Contract_Billing_Group J002 on J002.Contract_Billing_Group_ID = J001.Contract_Billing_Group_ID
LEFT OUTER JOIN dbo.FB_Client_Contract_Billed_To J003 on J003.Client_CB_ID = J001.Client_CB_ID
Left outer join dbo.FB_Client_CB_Split J004 on J004.Client_Contract_Billed_To_ID = J003.Client_Contract_Billed_To_ID

--------------------------------------------------------------
--------------------------------------------------------------
--select * from @Client_SelfManaged_1
--------------------------------------------------------------
--------------------------------------------------------------
--/*
Declare @Client_SelfManaged_2 Table
(
	Client_ID int
	,Contract_Billing_Group VarChar(256)
	,SelfManaged VarChar (32)
)
insert into @Client_SelfManaged_2
select Distinct
J001.Client_ID
,STUFF
(
	(
		Select
		'~br^ ' + CSM.Contract_Billing_Group
		From @Client_SelfManaged_1 CSM where CSM.Client_ID = J001.Client_ID
		for XML path ('') 
	)
	,1,5,''
)'Contract_Billing_Group'
,STUFF
(
	(
		Select
		'~br^ ' + CSM.SelfManaged
		From @Client_SelfManaged_1 CSM where CSM.Client_ID = J001.Client_ID
		for XML path ('') 
	)
	,1,5,''
)'SelfManaged'
From @Client_SelfManaged_1 J001
--*/
--------------------------------------------------------------
--------------------------------------------------------------
--select * from @Client_SelfManaged_2
--------------------------------------------------------------
--------------------------------------------------------------
--Rolling total against quote
Declare @ActualVsQuote_01 Table
(
	Client_ID int
	,DQ_Group int
	,QuoteCode VarChar(255)
	,BillingItem VarChar (255)
	,QuoteContractAmount dec(10,2)
	,RollingTotal dec(10,2)
	,RemainingOnQuote dec(10,2)
)
insert into @ActualVsQuote_01
Select
T1.Client_ID
,T1.DQ_Group
,T1.QuoteCode
,T1.BillingItem
,T1.QuoteContractAmount
,T1.RollingTotal
,T1.QuoteContractAmount - T1.RollingTotal 'RemainingOnQuote'
From
(
	select distinct
	J001.Client_ID
	,J001.DQ_Group
	,J001.QuoteCode
	,Replace(J003.Description,' '+J001.QuoteCode,'')'BillingItem'
	,J001.QuoteContractAmount
	,SUM(iif(J002.Amount is null,0.0,J002.Amount))over(Partition by J001.Client_ID,J001.QuoteCode)'RollingTotal'
	From @DQ_Results J001
	left outer join dbo.Actual_Service_Charge_Item J002 on 
		J002.Client_ID = J001.Client_ID 
		and J002.Visit_Date between J001.Quote_StartDate and J001.Quote_EndDate
		and J002.Line_Description like '%'+J001.QuoteCode+'%'
	left outer join dbo.FB_Contract_Billing_Item J003 on J003.Description like '%'+J001.QuoteCode+'%' and J003.Effective_To_Date is null
)T1
order by
1,2
--------------------------------------------------------------
--------------------------------------------------------------
--select * from @ActualVsQuote_01
--------------------------------------------------------------
--------------------------------------------------------------

Declare @ActualVsQuote_02 Table
(
	Client_ID int
	,QuoteCode VarChar(255)
	,BillingItem VarChar(MAX)
	,QuoteContractAmount VarChar(255)
	,RollingTotal VarChar(255)
	,RemainingOnQuote VarChar(255)
)
insert into @ActualVsQuote_02
select Distinct
J001.Client_ID
,STUFF
(
	(
		Select
		'~br^ '+AvQ.QuoteCode
		From @ActualVsQuote_01 AvQ where AvQ.Client_ID = J001.Client_ID
		For XML path ('')
	)
	,1,5,''
)'QuoteCode'
,STUFF
(
	(
		Select
		'~br^ '+AvQ.BillingItem
		From @ActualVsQuote_01 AvQ where AvQ.Client_ID = J001.Client_ID
		For XML path ('')
	)
	,1,5,''
)'BillingItem'
,STUFF
(
	(
		Select
		'~br^ '+Cast(AvQ.QuoteContractAmount as varchar(16))
		From @ActualVsQuote_01 AvQ where AvQ.Client_ID = J001.Client_ID
		For XML path ('')
	)
	,1,5,''
)'QuoteContractAmount'
,STUFF
(
	(
		Select
		'~br^ '+Cast(AvQ.RollingTotal as varchar(16))
		From @ActualVsQuote_01 AvQ where AvQ.Client_ID = J001.Client_ID
		For XML path ('')
	)
	,1,5,''
)'RollingTotal'
,STUFF
(
	(
		Select
		'~br^ '+Cast(AvQ.RemainingOnQuote as varchar(16))
		From @ActualVsQuote_01 AvQ where AvQ.Client_ID = J001.Client_ID
		For XML path ('')
	)
	,1,5,''
)'RemainingOnQuote'
From @ActualVsQuote_01 J001
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
--<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><
--BUILD FINAL LINES FROM HEAR DOWN
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
Select
	J001.Client_ID
	,J001.Preferred_Name 'Client_Preferred_Name'
	,J001.Last_Name 'Client_Last_Name'
	,J001.Birth_Date 'Client_Birth_Date'
	,J001.Deceased_Date 'Client_Deceased_Date'
	,J001.Building_name 'ClntAdr_Building_name'
	,J001.Location 'ClntAdr_Location'
	,J001.dwelling_number 'ClntAdr_dwelling_number'
	,J001.Street 'ClntAdr_Street'
	,J001.suburb 'ClntAdr_suburb'
	,J001.Post_Code 'ClntAdr_Post_Code'
	,J001.HasGOC
	,Replace(Replace(J001.Diagnosis,'~',' <'),'^ ','>')'Diagnosis'
	,Replace(Replace(J001.ServiceDelivery_StartDate,'~',' <'),'^ ','>') 'ServiceDelivery_StartDate'
	,Replace(Replace(J001.ServiceDelivery_EndDate,'~',' <'),'^ ','>') 'ServiceDelivery_EndDate'
	,Replace(Replace(J001.ServiceDelivery_DischargeDate,'~',' <'),'^ ','>') 'ServiceDelivery_DischargeDate'
	,J001.NDIS_Number
	,Replace(Replace(J002.ContactName,'~',' <'),'^ ','>')'ContactName'
	,Replace(Replace(J002.Contact_Phone,'~',' <'),'^ ','>')'Contact_Phone'
	,Replace(Replace(J002.Contact_Email,'~',' <'),'^ ','>')'Contact_Email'
	,Replace(Replace(J003.BillingGroup,'~',' <'),'^ ','>')'BillingGroup'
	,Replace(Replace(J003.Billing_End_Date,'~',' <'),'^ ','>')'Billing_End_Date'
	,Replace(Replace(J004.Referral_Date,'~',' <'),'^ ','>')'Referral_Date'
	,Replace(Replace(J004.Referral_Source,'~',' <'),'^ ','>')'Referral_Source'
	,Replace(Replace(J004.Referral_Comments,'~',' <'),'^ ','>')'Referral_Comments'
	,Replace(Replace(J004.Referral_ServRequested,'~',' <'),'^ ','>')'Referral_ServRequested'
	,J004.FirstBookedVisit 'Referral_FirstBookedVisit'
	,Replace(Replace(J005.Service,'~',' <'),'^ ','>') 'ServDeliv_Service'
	,Replace(Replace(J005.ToDate,'~',' <'),'^ ','>') 'ServDeliv_ToDate'
	,Replace(Replace(J005.FundingProg,'~',' <'),'^ ','>') 'ServDeliv_FundProg'
	,Replace(Replace(J007.FunderPrograms,'~',' <'),'^ ','>') 'FundProg'
	,Replace(Replace(J006.Contract_Billing_Group,'~',' <'),'^ ','>')'Contract_Billing_Group'
	,Replace(Replace(J006.SelfManaged,'~',' <'),'^ ','>')'Contract_Billing_SelfManaged'
	,Replace(Replace(J008.Sessions,'~',' <'),'^ ','>')'Sessions'
	,Replace(Replace(J008.HoursPerSession,'~',' <'),'^ ','>')'HoursPerSession'
	,Replace(Replace(J008.QuoteContractAmount,'~',' <'),'^ ','>')'QuoteContractAmount'
	,Replace(Replace(J008.QuoteCode,'~',' <'),'^ ','>')'QuoteCode'
	,Replace(Replace(J008.PortalServBookingDone,'~',' <'),'^ ','>')'PortalServBookingDone'
	,Replace(Replace(J008.ServAgreeSigned,'~',' <'),'^ ','>')'ServAgreeSigned'
	,Replace(Replace(J008.SetUpInCC,'~',' <'),'^ ','>')'SetUpInCC'
	,Replace(Replace(J008.KMsPerServ,'~',' <'),'^ ','>')'KMsPerServ'
	,J008.DQ_Date
	,J008.Quote_StartDate
	,J008.Quote_EndDate
	,Replace(Replace(J009.BillingItem,'~',' <'),'^ ','>')'BillingItem'
	,Replace(Replace(J009.RollingTotal,'~',' <'),'^ ','>')'RollingTotal'
	,Replace(Replace(J009.RemainingOnQuote,'~',' <'),'^ ','>')'RemainingOnQuote'
From @ClientTable J001
Left outer Join @ClientContact_Formated J002 on J002.Client_ID = J001.Client_ID
Left outer Join @BillingGroup_Formated J003 on J003.Client_ID  = J001.Client_ID
Left outer join @ClientReferral J004 on J004.Client_ID = J001.Client_ID
Left outer join @ServDeliv_Formated J005 on J005.Client_ID = J001.Client_ID
Left outer join @Client_SelfManaged_2 J006 on J006.Client_ID = J001.Client_ID
Left outer join @Client_FundingModel J007 on J007.Client_ID = J001.Client_ID
Left outer join @DQ_Results_Formated J008 on J008.Client_ID = J001.Client_ID
Left outer join @ActualVsQuote_02 J009 on J009.Client_ID = J001.Client_ID
