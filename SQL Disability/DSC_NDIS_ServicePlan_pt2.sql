/*

select * From [dbo].[Service_Type]
select * From [dbo].Task_Type

*/

Select 

iif(J001.Description = 'OATS', J002.[Task_Description], J001.Description) as 'Service_Type'

From [dbo].[Service_Type] J001
Inner Join 
(
	select
		tt.[Description] as 'Task_Description'
		,tt.[Service_Type_Code] as 'Service_Type_Code'
		,tt.[task_type_code] as 'Task_Type_Code'
		,ROW_NUMBER() Over
		(
			Partition BY tt.[Service_Type_Code] Order By tt.[Task_Type_Code] ASC
		) as 'RN'
	from [dbo].Task_Type tt
)J002 on J002.[Service_Type_Code] = J001.[Service_Type_Code]

where 
1=1
and Left(J001.Description, 3)='DC '
and RN = 1
OR J001.Description = 'OATS'