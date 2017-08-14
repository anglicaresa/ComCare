--driven by task type and SDC
/*
select * from Task_Type
select * from Service_Delivery
select * from Care_Plan_Delivery
select * from Service_Provision where Centre_ID = 7 and effective_to_Date is null



*/
select * from dbo.WI_Activity_Event_Type
select * from dbo.Indirect_Activity_Type
--select top 3 * from dbo.wi_activity wia --where wia.Schedule_Task_Type is not null
--select top 3 * from dbo.wi_activity wia where wia.Internal_Task_Code <>0
Declare @StartDate Date = '2017-08-07'
Declare @Range int = 1
Declare @EndDate Date = dateAdd(day,@Range-1,@StartDate)

Declare @OrgName VarChar(128) = 'Disabilities Children'

--select * from dbo.Organisation Org where Org.Organisation_Type_Code = 1

select distinct
--J002.Provider_ID
J001.Organisation_Name
,J003.Service_Type_Code
,J004.Task_Type_Code
,J003.Description
,J004.Description
from 
(
	select 
		Org.Organisation_Name
		,Org.Organisation_ID 
		from dbo.Organisation Org
		where 
			1=1
			and Organisation_Name in (@OrgName)
) J001
--inner join dbo.Provider_Contract J002 on J002.Organisation_ID = J001.Organisation_ID
Left outer join 
(
	Select distinct
	sp.Centre_ID
	,sp.Service_Type_Code 
	,st.Description
	from dbo.Service_Provision sp
	inner join dbo.Service_Type ST on ST.Service_Type_Code = SP.Service_Type_Code
	where sp.Effective_To_Date is null
)J003 on J003.Centre_ID = J001.Organisation_ID

left outer join dbo.Task_Type J004 on J004.Service_Type_Code = J003.Service_Type_Code


select top 20 * from WI_Activity wia-- where wia.Override_Address_ID <> 0
select top 1 * from person p 
select top 1 * from address
select top 1 * from dbo.Period_of_Residency
select top 1 * from dbo.Person_Current_Address_Phone