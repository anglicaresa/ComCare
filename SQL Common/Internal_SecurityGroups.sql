/*
select * from dbo.Security_Group
select * from dbo.Security_Group_Permission

select * from dbo.Security_Permission

select * from dbo.Security_User --all the defined users for desktop
select * from dbo.Security_User_Layout

select * from dbo.tmp_Security_User_Form_Layout
select * from dbo.Security_Group

--security_Group_permission_ID
--Security_Permision_Key
--*/
use ComCareDev
select * from
(
select
	J001.Description 'GroupName'
	,J003.Description 'PermisionObject'
	,iif(J002.Add_Permission = 1,'En','--')+iif(J002.Add_Permission = 1,'Ad','--')+iif(J002.Edit_Permission = 1,'Ed','--')+iif(J002.Delete_Permission = 1,'Del','---')'Permissions'
	,J001.Security_Group_ID
	,J003.Security_Permision_Key
From dbo.Security_Group J001
Left outer join dbo.Security_Group_Permission J002 on J002.Security_Group_ID = J001.Security_Group_ID
Left outer join dbo.Security_Permission J003 on J003.Security_Permision_Key = J002.Security_Permision_Key
where
J001.Description = 'System Administrator'
and J003.Description = 'Accommodation'
--and J003.Description like '%an%'

)JX001
--where JX001.Permissions = 'EnAd--Del'
order by
JX001.Security_Group_ID,JX001.Security_Permision_Key
/*
select * from dbo.Security_User
select * from dbo.Is_Member_Of
select * from dbo.Security_Group
*/
--*/

/*
select
	J001.Description 'Group_Name'
	,J003.[User_Name]
	,J004.Preferred_Name +' '+ J004.Last_Name 'Provider_Name'
	,J005.Employee_No
	,J006.Contract
From dbo.Security_Group J001
Left outer join dbo.Is_Member_Of J002 on J002.Security_Group_ID = J001.Security_Group_ID
left outer join dbo.Security_User J003 on J003.[User_ID] = J002.[User_ID]
left outer join dbo.Person J004 on J004.Person_ID = J003.Provider_ID
left outer join dbo.Provider J005 on J005.Provider_ID = J003.Provider_ID
left outer join 
(
	select
	JX001.Provider_ID
	,'HasCurrent' as 'Contract'
	from dbo.Provider_Contract JX001
	where 
		GETDATE() between JX001.Effective_Date_From and iif(JX001.Effective_Date_To is null, dateFromParts(2200,01,01),JX001.Effective_Date_To )
)J006 on J006.Provider_ID = J003.Provider_ID
order by 1,2
*/