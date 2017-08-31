/*
Activity_No
Client_ID
Activity_Date
Provider_ID
Service_Prov_Position_ID
Person_ID
Organisation_ID
Task_Type_Code
Indirect_Activity_Type_Code
Schedule_Time
Schedule_Duration
Activity_Duration
Travel_Km
Travel_Duration
Allocated_Task_ID
Compensible_Type_ID
Funding_Prog_Code
Activity_Start_Time
Activity_End_Time
Odometer_Reading
Units_of_Service
On_Flag
Off_Flag
Format_OK
ComCare_Validation_OK
Payroll_Validation_OK
Verification_Required
Authorisation_Date
Authorisation_Person
Actual_Service_Visit_No
Indirect_Activity_No
Classn_Shift_Centre
Date_Extract_for_Payroll
Date_Upload_to_ComCare
Creation_Date
Creator_User_Name
Last_Modified_Date
Last_Modified_User_Name
Company_Vehicle
Extracted_Funding_Prog_Code
Shift_Start_Time
Shift_End_Time
PreAuthorise_Id
Client_Casemix_Assignment_ID
On_Call_Activity_Code
WI_Record_ID
Address_ID
Schedule_Units_of_Service
Interrupt_Duration
Interrupted_Activity
Registration_Number
WI_Activity_ID
Cancelled_Visit
Group_Activity_ID
Student_Allocation_ID
Class_ID
Internal_Task_Provider_ID
Internal_Task_Working_Week_No
Internal_Task_From_Date
CAP_ID
User_Classification_ID
Estimated_Travel_Km
Estimated_Travel_Time
Client_Not_Home
Destination_Address_ID
Est_Intravisit_Travel_Km
Actual_Intravisit_Travel_Km
Scheduled_Visit_End_Time
External_Provider
Est_Visit_Charge
*/
--use ComCareProd
--select * from ComCareProd.INFORMATION_SCHEMA.COLUMNS where TABLE_NAME =  N'Activity_Work_Table'


--Prod
--select * from dbo.activity_Work_Table where cast(Activity_Date as date) = '2017-08-23' and len(Classn_Shift_Centre)>17
/*



SET @offset = DateDiff(minute, GetUTCDate(), GetDate())
select @offset/60.0 'offset', GetUTCDate()'UTC', GetDate()'Local'

*/
--select top 10 * from dbo.WI_Event_Log



-- Set year in a variable
/*


;WITH Months 
AS (
   -- Create a month numbers CTE
   SELECT 4 AS MonthNumber
   UNION ALL SELECT 10
)

,Dates AS 
(
   -- Find first day of month
	SELECT 
		monthNumber
		,firstDayOfMonth = DATEADD
		(
			month
			,cast(monthNumber as int) - 1
			,Cast
			(
				Concat(CAST(@Year as VarChar(4)),'-01-01') as datetime
			)
		)
	FROM Months
)
,MonthRange AS 
(
	SELECT 
	*
	FROM Dates as D
)

SELECT 
	*
	,firstSunday = 
	(
		SELECT TOP 1
			DATEADD(day, monthNumber -1, firstDayOfMonth)
		FROM Months
		WHERE 
--		1=1
			DATEPART(weekday, DATEADD(day, monthNumber -1, firstDayOfMonth)) = 1
		--	DATEPART(weekday, DATEADD(day, monthNumber -1, firstDayOfMonth)) = 1
	--	ORDER BY 
		--	monthNumber
	)
FROM MonthRange



select
	 DATEADD
	(
		DD
		,7 - Datepart(DW,Concat(CAST(@Year as VarChar(4)),'-04-01'))
		, Concat(CAST(@Year as VarChar(4)),'-04-01')
	)
*/



Declare @offset int
 SET @offset = DateDiff(minute, GetUTCDate(), GetDate())
select @offset/60.0 'offset', GetUTCDate()'UTC', GetDate()'Local'