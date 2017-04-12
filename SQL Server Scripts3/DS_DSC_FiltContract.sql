declare @Organisation VarChar(64) = 'Disabilities Children'

select 
	Description 
from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FC_Funder_Contract]

where 
	1=1
	AND (
			(Description like 'DC %' and @Organisation = 'Disabilities Children')
			OR (Description like 'DA %' and @Organisation = 'Disabilities Adult')
		)