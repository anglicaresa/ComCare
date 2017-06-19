use ComCareProd

select * from dbo.Provider_Classification
--/*
where 
	1=1
--	and to_date > cast ('2017-04-17 00:00:00.000' as date)
	and to_date > getdate()
	and Provider_ID = 10049327
	and Service_Prov_Position_ID = 348
--	and To_Date is null
	
order by
	From_Date desc
--*/



select * from dbo.Working_Week
where working_week_No = 31635 or working_week_No = 31613


select * from dbo.WI_Activity
where
	1=1 
	AND SPPID = 348
	and ( 
			Provider_id = 10049406
			or Provider_id = 10049327
			or Provider_id = 10079523
			or Provider_id = 10048905
			or Provider_id = 10049104
			or Provider_id = 10091277
			or Provider_id = 10048855
			or Provider_id = 10062524
		)
	and activity_date between cast ('2017-04-03 00:00:00.000' as date) and cast ('2017-04-17 00:00:00.000' as date)

select * from dbo.[Service_Provision_Position]
where
	1=1
	AND Service_Prov_Position_ID = 348

select * from [dbo].[Service_Provision_Allocation]
where
	1=1
	AND Service_Prov_Position_ID = 348
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
