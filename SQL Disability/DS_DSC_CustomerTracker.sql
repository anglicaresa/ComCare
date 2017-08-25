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

--*/

--debug
Declare @Client_ID int = 10071173


Declare @OrgName VarChar(64) = 'Disabilities Children'


Declare @ClientTable table 
(
	Client_ID int
	,Preferred_Name Varchar(128)
	,Last_Name Varchar(128)
	,Birth_Date date
	,Deceased_Date Date
	,Building_name Varchar(128)
	,Location Varchar(128)
	,Street Varchar(128)
	,suburb Varchar(128)
	,Post_Code int
	,Diagnosis VarChar(max)
)
insert into @ClientTable
select --distinct
	J003.Client_ID
	,J004.Preferred_Name
	,J004.Last_Name
	,Convert(date,J004.Birth_Date) 'Birth_Date'
	,CONVERT(date,J004.Deceased_Date) 'Deceased_Date'
	,J005.Building_name
	,J005.Location
	,J005.Street
	,J005.suburb
	,J005.Post_Code
	,Stuff
	(
		(
			select distinct
				'% '
				+ DC.Description 
			from dbo.Diagnosis D 
			left outer join dbo.Diagnosis_Category DC ON DC.Diagnosis_Category_Code = D.Diagnosis_Category_Code 
			where D.Client_ID = J003.Client_ID
			for XML path ('')  
		),1,2,''--stuff args to remove first comma
	)'Diagnosis'
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


/*
LEFT OUTER JOIN dbo.Personal_Contact J006 ON J006.Person_ID = J003.Client_ID
LEFT OUTER JOIN dbo.Personal_Contact_Type J007 ON J007.Personal_Contact_Type_Code = J006.Personal_Contact_Type_Code
*/
where
	1=1
--	and J003.Client_ID = @Client_ID
Order by
	3,2,1
--------------------------------------------------------------
--------------------------------------------------------------
select * from @ClientTable
--------------------------------------------------------------
--------------------------------------------------------------


/*


--get DQ_answers for client, make into sub query
--------------------------------------------------------------------------------------
Declare @DQ_Name VarChar(128) = 'DA Service Quote'
select
	J001.Description 'DQ_Name'
	,@Client_ID 'Client_ID'
	,cast(J001.Questionnaire_Date as datetime)'Questionnaire_Date'
	,J002.Description 'Question'
--	,CONCAT(J003.Comments,J003.Date_Value,J003.Text_Value,J003.Numeric_Value,J003.Boolean_Value,J005.Description)'answer'
--	/*
	,J003.Comments 'Answer_Comments'
	,J003.Date_Value 'Answer_Date_Value'
	,J003.Text_Value 'Answer_Text_Value'
	,J003.Numeric_Value 'Answer_Numeric_Value'
	,J003.Boolean_Value 'Answer_Boolean_Value'
	,J005.Description 'Answer_Selection'
--	*/
	,J003.Image_Content 'Answer_Image_Content'
	
From
(
	select
		DQ_Q.Questionnaire_Code
		,DQ_Q.Description
		,DQ_E_Q.Entity_Questionnaire_ID
		,DQ_E_Q.Questionnaire_Date
	from dbo.DQ_Questionnaire DQ_Q
	left outer join dbo.DQ_Entity_Questionnaire DQ_E_Q on DQ_E_Q.Questionnaire_Code = DQ_Q.Questionnaire_Code and DQ_E_Q.Respondent_ID = @Client_ID
	where 
	1=1
	and DQ_Q.Description = @DQ_Name
	and DQ_Q.Effective_To_Date is null
)J001

Left outer join dbo.DQ_Questionnaire_Question J002 on J002.Questionnaire_Code = J001.Questionnaire_Code
Left outer join dbo.DQ_Entity_Questionnaire_Answer J003 on J003.Entity_Questionnaire_ID = J001.Entity_Questionnaire_ID and J003.Question_No = J002.Question_No
Left outer join dbo.DQ_Entity_Questionnaire_Answer_List J004 on J004.Questionnaire_Code = J001.Questionnaire_Code and J004.Entity_Questionnaire_Answer_ID = J003.Entity_Questionnaire_Answer_ID
Left outer join dbo.DQ_Question_Selection_List J005 on J005.Questionnaire_Code = J001.Questionnaire_Code and J004.Question_No = J005.Question_No and J004.Question_Selection_List_No = J005.Question_Selection_List_No
------------------------------------------------------------------------------------------
*/
