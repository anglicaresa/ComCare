--Date_Upload_from_AWT
declare @StartDate date = '2017-06-30'
declare @EndDate date = '2017-09-30'
/*
Select Distinct
MIN(T.Creation_Date)over(Partition by cast(T.Creation_Date as date),T.Creator_User_Name )'session_Begin'
,Max(T.Creation_Date)over(Partition by cast(T.Creation_Date as date),T.Creator_User_Name )'session_End'
,T.Creator_User_Name
from FC_Transaction T 
	where
	1=1 
	and cast(T.Activity_Date as date) between @StartDate and @EndDate
	and Transaction_Source like '%billing%'
--*/

/*
Select Distinct
T.Activity_Date
,T.Comments
,cast(T.Creation_Date as date)'Creation_Date'
,count(T.Comments)over(partition by T.Comments, T.Activity_Date, cast(T.Creation_Date as date))
,T.Creator_User_Name
from FC_Transaction T 
	where
	1=1 
	and cast(T.Activity_Date as date) between @StartDate and @EndDate
	--and Transaction_Source like '%billing%'
	and Comments like 'HCP Daily%'

	order by 3
--*/


/*
--Actual_Service Upload Times from Actual_Work_Table
select distinct

	J001.Date_Upload_from_AWT 
--	J001.*
	from dbo.Actual_Service J001
	where
	cast(J001.Date_Upload_from_AWT as date) between @StartDate and @EndDate
	order by Date_Upload_from_AWT
--*/


/*
select Distinct
Processed_Date
,Creator_User_Name 
from dbo.FC_Recalc_CAP where cast(Processed_Date as date) between @StartDate and @EndDate
--*/

/*
select 
description
,Last_Billed_Date
,Last_Billing_Period_End
from dbo.FB_Contract_Billing_Group where Effective_To_Date is null
*/
/*
Select --Distinct
T.Activity_Date
,T.Comments
,cast(T.Creation_Date as date)'Creation_Date'
,count(T.Comments)over(partition by T.Comments, T.Activity_Date)
,T.Creator_User_Name
from FC_Transaction T 
	where
	1=1 
	and cast(T.Activity_Date as date) between @StartDate and @EndDate
	--and Transaction_Source like '%billing%'
	and Comments like 'HCP Daily%'

	and Activity_Date = '2017-07-01 00:00:00.000'
	and comments = 'HCP Daily Charges 01/07/2017 to 31/07/2017'
	and cast(T.Creation_Date as date) = '2017-07-04'
	and creator_User_Name = 'tania.pollard'

	order by 3
--*/

select distinct
--Activity_Date
--Authorisation_Date
cast(Authorisation_Date as date)'Authorisation_Date'
,count(Activity_Date) over(partition by cast(Authorisation_Date as date))
from dbo.Activity_Work_Table AWT

where
	--AWT.Activity_Date between @StartDate and @EndDate
	AWT.Activity_Date = cast('2017-07-31' as date)

order by 1,2