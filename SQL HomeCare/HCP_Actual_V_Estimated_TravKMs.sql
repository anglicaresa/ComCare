
Declare @Org_Name VarChar(128) = 'Home Care North'
Declare @Start_Date date = DateAdd(day,-1,GetDate())
Declare @End_Date date = DateAdd(day,-1,GetDate())

Declare @Prov_List Table (Provider_ID int)
insert into @Prov_List
select
J002.Provider_ID
from dbo.Organisation J001
inner join dbo.Provider_Contract J002 on J002.Organisation_ID = J001.Organisation_ID
where
	J001.Organisation_Name = @Org_Name



select 
	J001.Provider_ID
	,J002.Preferred_Name+' '+J002.Last_Name 'Provider_Name'
	,J001.Client_ID
	,J003.Preferred_Name+' '+J003.Last_Name 'Client_Name'
	,iif(J001.Indirect_Activity_Type_Code is null, J001.Task_type_Code,J004.Description)'Task/Activity'
	,Cast(J001.Activity_Date as date)'Activity_Date'
	,Cast(J001.Activity_Start_Time as datetime) 'Activity_Start_Time'
	,J001.Travel_Km
	,J001.Estimated_Travel_Km
	,J001.Travel_Km - (iif (J001.Estimated_Travel_Km is null,0.0,J001.Estimated_Travel_Km)) 'Diff'
from 
(
	select
	awt.*
	From dbo.Activity_Work_Table awt
	where
		awt.Provider_ID in (Select * from @Prov_List)
		and awt.Activity_Date between @Start_Date and @End_Date
)J001 
left outer join dbo.Person J002 on J002.Person_ID = J001.Provider_ID
Left outer join dbo.Person J003 on J003.Person_ID = J001.Client_ID
Left outer join dbo.Indirect_Activity_Type J004 on J004.Indirect_Activity_Type_Code = J001.Indirect_Activity_Type_Code
where 
	1=1
	and J001.Travel_Km is not null
	and (J001.Travel_Km > 0 or J001.Estimated_Travel_Km > 0)
	and J001.Company_Vehicle = 0
--	and J001.Activity_Date = '2017-10-16' 
--	and J001.Provider_ID = 10013234
