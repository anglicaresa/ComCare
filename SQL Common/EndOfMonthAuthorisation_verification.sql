/*
currently filtered on Agency records

*/
declare @Start_Date date = '2017-07-01'
declare @End_Date date = '2017-07-31'


select
	J001.Organisation_Name
	,J002.Provider_ID
	,J003.Client_ID
	,J003.Activity_Date
	,J003.Activity_type
	,J003.Task_Description
	,J003.Authorisation_Person
	,J003.Authorisation_Date

from (select Organisation_ID,Organisation_Name from dbo.Organisation where Organisation_ID = 2 or Organisation_ID = 4)J001
inner join dbo.Provider_Contract J002 on J002.Organisation_ID = J001.Organisation_ID and J002.Provider_Contract_Type_Code = 3

left outer join
(
	select
		AWT.Service_Prov_Position_ID
		,AWT.Provider_ID
		,AWT.Indirect_Activity_Type_Code
		,AWT.Group_Activity_ID
		,AWT.WI_Record_ID
		,AWT.Task_Type_Code
		,AWT.Activity_Date
		,AWT.Client_ID
		,AWT.Actual_Service_Visit_No
		,AWT.Activity_Start_Time
		,AWT.Activity_Duration
		,AWT.Authorisation_Person
		,AWT.Authorisation_Date
		,TT.Description 'Task_Description'
		,iif(AWT.Indirect_Activity_Type_Code is null,'Task','InternalTask')'Activity_type'
		,iif(TT.Service_Type_Code = 'HCP ',1,0)'HCP_flag'
	from dbo.Activity_Work_Table AWT
	left outer join dbo.Task_Type TT on TT.Task_Type_Code = AWT.Task_Type_Code 
	where
		AWT.Authorisation_Date is not null
		and cast(AWT.Activity_Date as date) between @Start_Date and @End_Date
)J003 on J003.Provider_ID = J002.Provider_ID

order by J003.Authorisation_Date