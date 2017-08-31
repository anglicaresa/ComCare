/*
select * from dbo.Activity_Work_Table where Service_Prov_Position_ID is null
select * from dbo.Service_Provision_Position
select * from dbo.Service_Delivery_Work_Team
inner join dbo.Provider J007 on J007.Provider_ID = J006.Provider_ID
select * from dbo.Provider_Contract where provider_id = 10067822
select Description from dbo.Provider_Contract_Type
select * from dbo.Organisation where Organisation_Type_Code = 1
*/

declare @Start_Date date = cast('2017-07-01' as date)
declare @End_Date date = cast('2017-07-31' as date)
DECLARE @OrgName AS Varchar(64) = 'Disabilities Children'
declare @PayrollContractTypes varchar(32) = 'Payroll'

-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

Select distinct
	J001.Organisation_Name
	,J006.Provider_ID
	,J013.Provider_Name
	,cast(J014.Employee_No as int) 'PayrollNumber'
	,cast(J007.Activity_Date as date)'Activity_Date'
	,cast(J007.Activity_Start_Time as datetime)'Activity_Start_Time'
	,cast(J007.Activity_Duration as Dec(10,2))'Activity_Duration'
	,J007.Activity_Type
	,J007.Task_Type_Code
	,J008.Description 'IndirectActivity'
	,J007.Indirect_Activity_Type_Code
	,J012.Description 'Indirect_Activity_Type'
	,J002.Description 'Team'
	,J003.Generated_Provider_Code
	,iif(J002.Short_Description like '[0-9][0-9][0-9][0-9]',J002.Short_Description,null)'MappedCostCentre'
	,J007.Travel_Duration
	,J007.Travel_Km
	,J007.Authorisation_Person
	,J007.Client_Not_Home
	,J007.Funding_Prog_Code
	,cast(J007.Date_Extract_for_Payroll as datetime)'Date_Extract_for_Payroll'
	,J015.Description 'PayRollContractType'

from dbo.Organisation J001
inner join dbo.Provider_Contract J006 on J006.Organisation_ID = J001.Organisation_ID 

Left outer join
(
	select
		* 
		,iif(AWT.Indirect_Activity_Type_Code is null,'Task','InternalTask')'Activity_type'
	from dbo.Activity_Work_Table AWT
	where
		AWT.Authorisation_Date is not null
		and cast(AWT.Activity_Date as date) between @Start_Date and @End_Date
)J007 on J007.Provider_ID = J006.Provider_ID

left outer join dbo.Service_Provision_Position J003 on J003.Service_Prov_Position_ID = J007.Service_Prov_Position_ID
Left outer join dbo.Service_Delivery_Work_Team J002 on J002.Team_No = J003.Team_No and J002.Centre_ID = J003.Centre_ID
Left outer join dbo.Indirect_Activity_Type J008 on J008.Indirect_Activity_Type_Code = J007.Indirect_Activity_Type_Code

left outer join dbo.Indirect_Activity_Type J012 on J012.Indirect_Activity_Type_Code = J007.Indirect_Activity_Type_Code
inner join 
(
	select
	Concat (P.Preferred_Name,' ',P.Last_Name)'Provider_Name'
	,P.Person_ID
	from dbo.person P
)J013 on J013.Person_ID = J006.Provider_ID

Left outer join dbo.Provider J014 on J014.Provider_ID = J006.Provider_ID
left outer join dbo.Provider_Contract_Type J015 on J015.Provider_Contract_Type_Code = J006.Provider_Contract_Type_Code

where
	1=1
	and J001.Organisation_Name in (@OrgName)
	and cast(J007.Activity_Date as date) between @Start_Date and @End_Date
	and J015.Description in (@PayrollContractTypes)
	and cast(J007.Activity_Date as date) between J006.Effective_Date_From and iif(J006.Effective_Date_To is null, dateadd(Day,1,@End_Date),J006.Effective_Date_To)
Order by
	J001.Organisation_Name
	,J006.Provider_ID
	,cast(J007.Activity_Date as date)
	,cast(J007.Activity_Start_Time as datetime)


