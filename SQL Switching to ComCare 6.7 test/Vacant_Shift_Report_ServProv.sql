
use ComCareDev

declare @Centre varchar(32) = 'Ian George Court'
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

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