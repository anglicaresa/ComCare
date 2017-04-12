
Use ComCareDev

declare @Centre varchar(32) = 'Disabilities Children'
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

select 
	J002.Description 'Team'

from [dbo].[Organisation] J001

inner join [dbo].[Service_Delivery_Work_Team] J002 on J002.[Centre_ID] = J001.[Organisation_ID]
left outer join [dbo].[Service_Provision_Position] J003 on J003.[Centre_ID] = J002.[Centre_ID] and J003.Team_No = J002.Team_No
--inner join [dbo].[Provider_Classification] J004 on J004.Provider_Class_Code = J003.Provider_Class_Code

where
	1=1
	and J001.Organisation_Name = @Centre
	and J002.Effective_Date_To is null
--	and J003.Provider_Class_Code in (@ClassCodeFilter)

group by J002.Description
order by 1



/*
	select * from [dbo].[Service_Delivery_Work_Team]
	select * from [dbo].[Service_Provision_Position]

	--------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------
	Allocation report skew----------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------
	select 
	J003.Provider_Class_Code
	,J004.Description

from [dbo].[Organisation] J001

inner join [dbo].[Service_Delivery_Work_Team] J002 on J002.[Centre_ID] = J001.[Organisation_ID]
left outer join [dbo].[Service_Provision_Position] J003 on J003.[Centre_ID] = J002.[Centre_ID] and J003.Team_No = J002.Team_No
inner join [dbo].[Provider_Classification] J004 on J004.Provider_Class_Code = J003.Provider_Class_Code

where
	1=1
	and J001.Organisation_Name = @Centre

Group by
	J003.Provider_Class_Code
	,J004.Description

Order by
	J004.Description
*/