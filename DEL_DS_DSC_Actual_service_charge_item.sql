--[appsql-3\TRAIN].[ComCareTRAIN]
--[APPSQL-3\COMCAREPROD].[comcareprod]
/*
----------------------------------------------------------
select * from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].Actual_Service
where client_id = 10070303

select * from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Actual_Service_Charge_Item]
where client_id = 10070303

select * from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Client_Contract_Billing]
select * from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Contract_Billing_Group]


Contract_Billing_Group_ID
--*/


Declare @Client_ID_ as INT
set @Client_ID_ = 10072693

DECLARE @StartDate AS DATETIME
DECLARE @EndDate AS DATETIME
SET @StartDate = '20161205 00:00:00.000'
SET @EndDate = '20161218 23:59:59.998'
PRINT @StartDate
PRINT @EndDate

-----------------------------------------



--/*
select 
--	J001.Actual_Service_Charge_Item_ID	
	J001.Client_ID
	--J001.Client_ID
	--,count (J001.Client_ID) as 'serviceCount'
	--/*	
	,J001.Visit_Date
	,J001.Visit_No
	,J001.Provider_ID
	,J001.Service_Prov_Position_ID
--	,J001.Client_CB_Item_ID
--	,J001.Contract_Billing_Item_ID
--	,J001.Contract_Billing_Rate_ID
--	,J001.Contract_Billing_Exception_Rate_ID
--	,J001.Org_Charge_Item_Rate_ID	FC_Account_ID
--	,J001.Split_Line_No
--	,J001.Rate
--	,J001.Unit
	,J001.Amount
--	,J001.Rate_Type	
	,J001.Line_Description	
--	,J001.Start_Time	
--	,J001.Billed_Date	
--	,J001.Creation_Date	
--	,J001.Creator_User_Name	
--	,J001.Last_Modified_Date	
--	,J001.Last_Modified_User_Name	
--	,J001.FC_Product_ID	
--	,J001.Archived
	,IIF(J009.Organisation_Name = 'NDIA National Disability Insurance Agency', 'NDIS funded','Self Managed') as 'Funding_type'
--	,J006.RN
--	,J009.RN
	--*/
from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Actual_Service_Charge_Item] J001
--*/
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------

Inner JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Service_Delivery] J005 ON J001.[Client_ID] = J005.[Client_ID]
INNER JOIN 
(
	Select 
		SD.[Client_ID]
		,O.[Organisation_Name]
		,SD.[Service_Type_Code]
--		,SD.[From_Date]
--		,SD.[To_Date]
		,ROW_NUMBER ()
			over 
			(
				Partition by SD.[Client_ID] Order by
					CASE
					WHEN O.[Organisation_Name] = 'Disabilities Children' THEN '1'
					ELSE O.[Organisation_Name] END ASC
			) AS 'RN'
	from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Service_Delivery] SD
		join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Period_of_Residency] PR on PR.Person_ID = SD.Client_ID
		join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Address] A on A.Address_ID = PR.Address_ID
		Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Service_Provision] SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
		Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Organisation] O on Sp.Centre_ID = O.Organisation_ID
	Where PR.To_Date is null and PR.Display_Indicator  = 1
) J006 ON J006.[Client_ID] = J001.[Client_ID] AND J006.[Service_Type_Code] = J005.[Service_Type_Code]


-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
--/*

left outer Join
(
	select
		--top 1
		CCB.[Client_ID] as 'Client_ID'
		,Org.[Organisation_Name] as 'Organisation_Name'
		,CBG.[Description] as 'ContractBillingGroup'
		,ROW_NUMBER ()
			over 
			(
				Partition by CCB.[Client_ID] Order by
					CASE
					WHEN Org.[Organisation_Name] = 'NDIA National Disability Insurance Agency' THEN '1'
					ELSE Org.[Organisation_Name] END ASC
			) AS 'RN'
	from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Client_Contract_Billing] CCB
		left outer join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Contract_Billing_Group] CBG on CBG.[Contract_Billing_Group_ID] = CCB.[Contract_Billing_Group_ID]
		left outer Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Client_Contract_Billed_To] CCBT on CCBT.[Client_CB_ID] = CCB.[Client_CB_ID]
		left outer Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Client_CB_Split] CCBS on CCBS.[Client_Contract_Billed_To_ID] = CCBT.[Client_Contract_Billed_To_ID]
		left outer Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Organisation] Org on CCBS.[Organisation_ID] = Org.[Organisation_ID]

)J009 on J009.[Client_ID] = J001.[Client_ID]
--*/
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
/*
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Card_Holder] J007 ON J007.[Person_ID] = J001.[Client_ID]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Card_Type] J008 ON J008.[Card_Type_ID] = J007.[Card_Type_ID]
*/
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
Where 
	1=1
	and J001.Client_ID = @Client_ID_
	and J006.[Organisation_Name] = 'Disabilities Children'
	and J006.RN < 2
	and J009.RN < 2
	and J001.Visit_Date between @StartDate and @EndDate
	and J009.ContractBillingGroup <> 'DCSI'
--	and J008.[Description] = 'NDIS Number'
--	and J009.Organisation_Name = 'NDIA National Disability Insurance Agency'

/*
Group by
J001.Client_ID
--*/

order by
1

