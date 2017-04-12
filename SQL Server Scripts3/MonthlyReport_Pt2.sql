-----------------------------------------
--in train
--[APPSQL-3\COMCAREPROD].[comcareprod]
--[appsql-3\TRAIN].[ComCareTRAIN]
-----------------------------------------
Declare @Client_ID_ as INT
set @Client_ID_ = 10071583

DECLARE @StartDate AS DATETIME
DECLARE @EndDate AS DATETIME
SET @StartDate = dateadd(day,datediff(day,380,GETDATE()),0)
SET @EndDate = dateadd(day,datediff(day,0,GETDATE()),0)
PRINT @StartDate
PRINT @EndDate

/*
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
*/


select
	J001.Client_ID
	,J001.Visit_Date
	,J001.Rate
	,J001.Unit
	,J001.Amount
	,J001.Rate_Type
	,J001.Line_Description
	,J002.Description as Origin_ItemNumber
	,J004.Description as TypeOfUnit
	,J003.[UOM_Code]
	,J002.Contract_Billing_Item_ID
	,J003.Contract_Billing_Rate_ID
	,J002.[Description] as Billing_item
	,J005.Description as Service_Type

 FROM [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Actual_Service_Charge_Item] J001
Inner Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Contract_Billing_Item] J002 on J001.Contract_Billing_Item_ID = J002.Contract_Billing_Item_ID
Left Outer Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Contract_Billing_Rate] J003 on J001.Contract_Billing_Rate_ID = J003.Contract_Billing_Rate_ID
Left Outer Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Unit_of_Measure] J004 ON J003.[UOM_Code] = J004.[UOM_Code]
Left outer join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Service_Type] J005 ON (replace((substring(J001.Line_Description,1,4)),' ','')) = J005.Service_Type_Code
Where 
	1=1
	and J001.Client_ID = @Client_ID_
	and J001.Line_Description Not like 'HCP Daily Charges%'
	and J001.Visit_Date between @StartDate and @EndDate
/*
GROUP BY
	J001.Client_ID
	,J001.Visit_Date
	,J001.Rate
	,J001.Unit
	,J001.Amount
	,J001.Rate_Type
	,J001.Line_Description
	,J002.Description
	,J004.Description
	,J003.UOM_Code
	,J001.Contract_Billing_Item_ID
	,J001.Contract_Billing_Rate_ID
	*/