use ComCareDev

Declare @OrgList table ( org_ID int )
insert into @OrgList values (7),(10),(49),(50),(51),(52),(53),(54) -- organisation ID from (below)
--select * from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].organisation

select 
	Organisation_Name 'OrgNm'
	
	from [dbo].organisation
where 
	Organisation_ID in (select * from @OrgList)
--	and Organisation_Name like 'Disabilities%'
	and Organisation_Name Not like 'Disabilities%'
order by 1
