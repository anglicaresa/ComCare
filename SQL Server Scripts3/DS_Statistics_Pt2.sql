/*

select * From [comcareUAT].[dbo].[Service_Type]
select * From [comcareUAT].[dbo].Task_Type


[APPSQL-3\COMCAREPROD].[comcareprod]
[comcareUAT]
*/

Select 

J001.Description 'Service_Type'

From [comcareUAT].[dbo].[Service_Type] J001

where 
1=1
and Left(J001.Description, 3)='DA '

