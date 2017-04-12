--------------------------------------------
--------------------------------------------
--    EXCLUDE LIST FOR CHARACTERISTICS	  --
--------------------------------------------
--------------------------------------------

Declare @t_CharExc table 
(
	Char_Exclude VarChar(64)
)
insert into @t_CharExc values 
	('Self funded retiree')
	,('Visit from a male provider')
	,('Visit from a female provider')
	,('Care Leaver Supported Residential Facility')
	,('Consent for Future Contact')
	,('Does not Consent to Future Contact')
	,('Council Area')
	,('Provider Car Details')


--------------------------------------------
--------------------------------------------
--				 END EXCLUDE			  --
--------------------------------------------
--------------------------------------------

select '(None Recorded)' 'Characteristic'
Union
Select 
	Description --'Characteristic'
from [comcareUAT].[dbo].[Characteristic]

where
1=1
and Description Not in (select * from @t_CharExc)