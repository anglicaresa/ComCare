--[appsql-3\TRAIN].[ComCareTRAIN]
--[APPSQL-3\COMCAREPROD].[comcareprod]
/*


--*/
Declare @Client_ID_ as INT
set @Client_ID_ = 10069826

DECLARE @StartDate AS DATETIME
DECLARE @EndDate AS DATETIME
SET @StartDate = '20170123 00:00:00.000'
SET @EndDate = '20170206 23:59:59.998'
PRINT @StartDate
PRINT @EndDate
declare @Organisation varchar(64) = 'Disabilities Children'
--declare @Organisation varchar(64) = 'Disabilities Adults'
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--/*
select
	RegistrationNumber = 4050000734 --number refers to AnglicareSA
	,IIF(J007.[Card_No] is null,'', J007.[Card_No]) 'NDISNumber'
	,Format(J001.Visit_Date, 'yyyy-MM-dd') 'SupportsDeliveredFrom'
	,Format
	(
		iif 
		(
			RIGHT(J002.Description,15) = '01_045_0115_1_1'
			,(dateadd(day,1,J001.Visit_Date))
			,J001.Visit_Date
		)
		,'yyyy-MM-dd'
	) 'SupportsDeliveredTo'
	,RIGHT(J002.Description,15) 'SupportNumber'
	,ClaimReference = '' --------------------------------------a tech1 query needs to be sorted out with Jerry.
	,Case
		when J004.Description = 'Visit' then FORMAT(J001.Unit, '##0.#0') 
		when J004.Description = 'Unit' then FORMAT(J001.Unit, '##0.#0') 
		else ''
		end 'Quantity'
	,Case 
		When J004.Description = 'Hour' then Convert(varchar(5),Convert(time(0), CONVERT(datetime,DATEADD(MINUTE, 60.00*J001.Unit, 0))))
		ELSE ''
		end 'Hours'
	,Format(J001.Rate, '#######0.#0') 'UnitPrice'
	,GSTCode = 'P2'
	,AuthorisedBy = ''
	,ParticipantApproved = ''
	,InKindFundingProgram = ''
	,J004.Description 'unit_type'
	,J001.[Client_ID]
	,J008.[Description] 'CardType'
	,1 'adjInd'

FROM [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Actual_Service_Charge_Item] J001
Inner Join [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Contract_Billing_Item] J002 on J001.Contract_Billing_Item_ID = J002.Contract_Billing_Item_ID
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Contract_Billing_Rate] J003 on J001.Contract_Billing_Rate_ID = J003.Contract_Billing_Rate_ID
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Unit_of_Measure] J004 ON J003.[UOM_Code] = J004.[UOM_Code]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Service_Delivery] J005 ON J001.[Client_ID] = J005.[Client_ID]

INNER JOIN 
(
	Select 
		SD.[Client_ID]
		,O.[Organisation_Name]
		,SD.[Service_Type_Code]
		,SD.[From_Date]
		,SD.[To_Date]
		,ROW_NUMBER ()
			over 
			(
				Partition by SD.[Client_ID] Order by
					CASE
					WHEN O.[Organisation_Name] = @Organisation THEN '1'
					ELSE O.[Organisation_Name] END ASC
			) AS 'RN'
	from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Service_Delivery] SD
		JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Period_of_Residency] PR on PR.Person_ID = SD.Client_ID
		JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Address] A on A.Address_ID = PR.Address_ID
		JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Service_Provision] SP on A.Suburb_ID = SP.Suburb_ID AND SP.Service_Type_Code = SD.Service_Type_Code
		JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Organisation] O on Sp.Centre_ID = O.Organisation_ID
	Where PR.To_Date IS NULL AND PR.Display_Indicator  = 1
) J006 ON J006.[Client_ID] = J001.[Client_ID] AND J006.[Service_Type_Code] = J005.[Service_Type_Code]

LEFT OUTER JOIN 
(
	select
		CCB.[Client_ID] as 'Client_ID'
		,Org.[Organisation_Name] as 'Organisation_Name'
		,CBG.[Description] as 'ContractBillingGroup'
		,CCB.Client_CB_ID as 'Client_CB_ID'
		,ROW_NUMBER ()
			over 
			(
				Partition by CCB.[Client_ID] Order by
					CASE
					WHEN Org.[Organisation_Name] = 'NDIA National Disability Insurance Agency' THEN '1'
					ELSE Org.[Organisation_Name] END ASC
			) AS 'RN'
	from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Client_Contract_Billing] CCB
		LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Contract_Billing_Group] CBG on CBG.[Contract_Billing_Group_ID] = CCB.[Contract_Billing_Group_ID]
		LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Client_Contract_Billed_To] CCBT on CCBT.[Client_CB_ID] = CCB.[Client_CB_ID]
		LEFT OUTER JOIN  [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Client_CB_Split] CCBS on CCBS.[Client_Contract_Billed_To_ID] = CCBT.[Client_Contract_Billed_To_ID]
		LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Organisation] Org on CCBS.[Organisation_ID] = Org.[Organisation_ID]
	where
		Org.[Organisation_Name] = 'NDIA National Disability Insurance Agency'
)J009 on J009.[Client_ID] = J001.[Client_ID]

LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Card_Holder] J007 ON J007.[Person_ID] = J001.[Client_ID]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Card_Type] J008 ON J008.[Card_Type_ID] = J007.[Card_Type_ID]

Where 
	1=1
	and J006.[Organisation_Name] = @Organisation
	and J006.RN < 2
	and J009.RN < 2
	and J001.Visit_Date between @StartDate and @EndDate
	and J001.Line_Description Not like 'HCP Daily Charges%'
	and J009.ContractBillingGroup <> 'DCSI'
	and 
	(
		J008.[Description] = 'NDIS Number'
		OR J008.[Description] is NULL
	)
	and J009.Organisation_Name = 'NDIA National Disability Insurance Agency'


-------------------------------------------------------------------------------------------
--*/---------------------------------------------------------------------------------------

UNION all

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--/*
select
	RegistrationNumber = 4050000734 --number refers to AnglicareSA
	,IIF(J007.[Card_No] is null,'', J007.[Card_No]) 'NDISNumber'
	,Format(J010.Effective_From_Date, 'yyyy-MM-dd') 'SupportsDeliveredFrom'
	,Format(J010.Effective_To_Date, 'yyyy-MM-dd') 'SupportsDeliveredTo'
	,J010.Comments 'SupportNumber'
	,ClaimReference = '' --------------------------------------a tech1 query needs to be sorted out with Jerry.
	,'1.00' 'Quantity'
	,'' 'Hours'
	,Format(J010.Adjustment_Amount, '#######0.#0') 'UnitPrice'
	,GSTCode = 'P2'
	,AuthorisedBy = ''
	,ParticipantApproved = ''
	,InKindFundingProgram = ''
	,unit_type = 'Unit'
	,J001.[Client_ID]
	,J008.[Description] 'CardType'
	,2 'adjInd'

from
(
	select
		CCB.[Client_ID] as 'Client_ID'
		,CCB.Client_CB_ID as 'Client_CB_ID'
	from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Client_Contract_Billing] CCB
		LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Contract_Billing_Group] CBG on CBG.[Contract_Billing_Group_ID] = CCB.[Contract_Billing_Group_ID]
		LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Client_Contract_Billed_To] CCBT on CCBT.[Client_CB_ID] = CCB.[Client_CB_ID]
		LEFT OUTER JOIN  [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Client_CB_Split] CCBS on CCBS.[Client_Contract_Billed_To_ID] = CCBT.[Client_Contract_Billed_To_ID]
		LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Organisation] Org on CCBS.[Organisation_ID] = Org.[Organisation_ID]
	where
		Org.[Organisation_Name] = 'NDIA National Disability Insurance Agency'
	group by
		CCB.[Client_ID]
		,CCB.Client_CB_ID
)J001

LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Service_Delivery] J005 ON J001.[Client_ID] = J005.[Client_ID]

INNER JOIN 
(
	Select 
		SD.[Client_ID]
		,O.[Organisation_Name]
		,SD.[Service_Type_Code]
		,SD.[From_Date]
		,SD.[To_Date]
		,ROW_NUMBER ()
			over 
			(
				Partition by SD.[Client_ID] Order by
					CASE
					WHEN O.[Organisation_Name] = @Organisation THEN '1'
					ELSE O.[Organisation_Name] END ASC
			) AS 'RN'
	from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Service_Delivery] SD
		JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Period_of_Residency] PR on PR.Person_ID = SD.Client_ID
		JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Address] A on A.Address_ID = PR.Address_ID
		JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Service_Provision] SP on A.Suburb_ID = SP.Suburb_ID AND SP.Service_Type_Code = SD.Service_Type_Code
		JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Organisation] O on Sp.Centre_ID = O.Organisation_ID
	Where PR.To_Date IS NULL AND PR.Display_Indicator  = 1
) J006 ON J006.[Client_ID] = J001.[Client_ID] AND J006.[Service_Type_Code] = J005.[Service_Type_Code]

LEFT OUTER JOIN 
(
	select
		CCB.[Client_ID] as 'Client_ID'
		,Org.[Organisation_Name] as 'Organisation_Name'
		,CBG.[Description] as 'ContractBillingGroup'
		,CCB.Client_CB_ID as 'Client_CB_ID'
		,ROW_NUMBER ()
			over 
			(
				Partition by CCB.[Client_ID] Order by
					CASE
					WHEN Org.[Organisation_Name] = 'NDIA National Disability Insurance Agency' THEN '1'
					ELSE Org.[Organisation_Name] END ASC
			) AS 'RN'
	from [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Client_Contract_Billing] CCB
		LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Contract_Billing_Group] CBG on CBG.[Contract_Billing_Group_ID] = CCB.[Contract_Billing_Group_ID]
		LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Client_Contract_Billed_To] CCBT on CCBT.[Client_CB_ID] = CCB.[Client_CB_ID]
		LEFT OUTER JOIN  [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[FB_Client_CB_Split] CCBS on CCBS.[Client_Contract_Billed_To_ID] = CCBT.[Client_Contract_Billed_To_ID]
		LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Organisation] Org on CCBS.[Organisation_ID] = Org.[Organisation_ID]
	where
		Org.[Organisation_Name] = 'NDIA National Disability Insurance Agency'

)J009 on J009.[Client_ID] = J001.[Client_ID]

LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Card_Holder] J007 ON J007.[Person_ID] = J001.[Client_ID]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Card_Type] J008 ON J008.[Card_Type_ID] = J007.[Card_Type_ID]


LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].FB_Client_CB_Bill_Adjustment J010 ON J010.[Client_CB_ID] = J009.[Client_CB_ID] and J010.Effective_From_Date >= @StartDate
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].FB_Adjustment_Type J011 ON J011.Adjustment_Type_Code = J010.Adjustment_Type_Code

Where 
	1=1
	and J006.[Organisation_Name] = @Organisation
	and J006.RN < 2
	and J009.RN < 2
	and J010.Effective_to_Date between @StartDate and @EndDate
	and J009.ContractBillingGroup <> 'DCSI'
	and 
	(
		J008.[Description] = 'NDIS Number'
		OR J008.[Description] is NULL
	)
	and J009.Organisation_Name = 'NDIA National Disability Insurance Agency'
--*/
Order by
2,3,17
