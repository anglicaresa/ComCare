
Declare @Org table 
(
	Org VarChar(64)
)
insert into @Org values 
	('Disabilities Children')
	,('Disabilities Adult')

Select * from @Org
