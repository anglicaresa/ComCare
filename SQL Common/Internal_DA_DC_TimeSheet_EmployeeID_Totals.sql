declare @Start_Date date = cast('2017-05-15' as date)
declare @End_Date date = cast('2017-05-15' as date)
DECLARE @OrgName AS Varchar(64) = 'Disabilities Children'

Select
	J007.Employee_No
from dbo.Organisation J001
inner join dbo.Provider_Contract J006 on J006.Organisation_ID = J001.Organisation_ID
inner join dbo.Provider J007 on J007.Provider_ID = J006.Provider_ID

where
	J001.Organisation_Name in (@OrgName)
	and J007.Employee_No is not null
	and 
	(
		cast(J006.Effective_Date_To as date) > @Start_Date
		or J006.Effective_Date_To is null
	)

--select * from dbo.Organisation