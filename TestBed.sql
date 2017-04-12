Declare @Client_ID_ as INT = 10077684
DECLARE @StartDate AS DATETIME = '20170203 00:00:00.000'
DECLARE @EndDate AS DATETIME = '20170203 00:00:00.000'
	
	
Select
	IIF(Awt.Activity_Start_Time IS NULL, 'FALSE', 'TRUE') 'In_Activity_work_Table'
	,Wi_A.SPPID 'WiA_SPPID'
	,Awt.Service_Prov_Position_ID 'AcS_SPPID'
	,Wi_A.Activity_Start_Time 'WiA_Activity_Start_Time'
	,Wi_A.Activity_End_Time 'WiA_Activity_End_Time'
	,Wi_A.Client_ID 'Client_ID'
	,Wi_A.Provider_ID 'WiA_Provider_ID'
	,Wi_A.Schedule_Task_Type 'WiA_Schedule_Task_Type'
	,Convert (DateTime, Wi_A.Schedule_Time) 'WiA_Schedule_Time'
	,Awt.Activity_Start_Time 'Awt_Activity_Start_Time'
	,Awt.Actual_Service_Visit_No 'AwT_Actual_Service_Visit_No'
	,Wi_A.Schedule_Duration 'WiA_Scheduled_Duration'
	,Wi_A.Activity_ID 'WiA_Activity_ID'
	,Awt.Activity_Date 'AWT_Activity_Date'
	,Awt.Task_Type_Code 'Task_Type_Code'
	,Wi_A.[CAP_ID] 'CAP_ID'
	,Awt.Date_Extract_for_Payroll 'AwT_Date_Extract_for_Payroll'
	,Awt.Activity_No 'Awt_Activity_No'
	,Row_Number()Over(Partition by Wi_A.Activity_ID Order BY Awt.Task_Type_Code) 'RN'
from [APPSQL-3\COMCAREPROD].[comcareprod].dbo.WI_Activity Wi_A
Left Outer Join [APPSQL-3\COMCAREPROD].[comcareprod].dbo.Activity_work_Table Awt 
ON 
	1=1
	and Wi_A.Client_ID = Awt.Client_ID 
	and Wi_A.SPPID = Awt.Service_Prov_Position_ID
	and Wi_A.Activity_Date = Awt.Activity_Date
	and Wi_A.Provider_ID = Awt.Provider_ID
where
	1=1
	and Wi_A.Cancellation_Date is NULL
	and Wi_A.Client_ID IS NOT NULL
	and Convert (DateTime, Wi_A.Schedule_Time) between @StartDate and (DATEADD(s, 84599, @EndDate))
	and Wi_A.Client_ID = @Client_ID_