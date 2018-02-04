--select * from [az-sqlbi01].dwhb.extract.hrtim_tsheet_entry T1Ext where T1Ext.EMPLOYEE_ID = 3837 and TimeSheet_Date = cast('2017-05-15' as datetime)
--select * from [az-sqlbi01].dwhb.extract.hrtim_tsheet_entry T1Ext where T1Ext.EMPLOYEE_ID = 7409 and TimeSheet_Date > cast('2018-01-01' as datetime)
--/*
declare @Start_Date date = cast('2018-01-01' as date)
declare @End_Date date = cast('2018-01-14' as date)
--*/


/*
declare @Start_Date date = cast('2017-06-05' as date)
declare @End_Date date = cast('2017-06-05' as date)
--*/

Select 
	distinct
	T1.EMPLOYEE_ID
	,Sum(T1.UNITS)over(partition by T1.EMPLOYEE_ID) 'Units'

from
(
	select 
		T1Ext.EMPLOYEE_ID
		,cast(T1Ext.TIMESHEET_DATE as Date) TIMESHEET_DATE
		,T1Ext.UNITS
	from [az-sqlbi01].dwhb.extract.hrtim_tsheet_entry T1Ext
	where
		1=1
		and cast(T1Ext.TIMESHEET_DATE as date) between @Start_Date and @End_Date
		and (T1Ext.ENTRY_TYPE = 'TW' or T1Ext.ENTRY_TYPE = 'AC')
		and 1 = iif(T1Ext.CLOCK_IN = 0 and T1Ext.CLOCK_OUT = 0, 0,1)
		and T1Ext.UNIT_TYPE = 'H'
--		and T1Ext.EMPLOYEE_ID in (@Employee_ID)

		and T1Ext.EMPLOYEE_ID = 7409
)T1

order by 1, 2


select distinct ENTRY_TYPE from [az-sqlbi01].dwhb.extract.hrtim_tsheet_entry