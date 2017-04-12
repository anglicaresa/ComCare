--[appsql-3\TRAIN].[ComCareTRAIN]
--[APPSQL-3\COMCAREPROD].[comcareprod]

/*
Select * from [appsql-3\TRAIN].[ComCareTRAIN].[dbo].[WI_Device] -- IMEI and Comments

--where Device = 'Samsung Sa'
order by
2

152 S4's
97 Sa's
3 Ts's

Select * from [appsql-3\TRAIN].[ComCareTRAIN].[dbo].[WI_SIM] -- SIM_Number and IMSI_Number

Select * from [appsql-3\TRAIN].[ComCareTRAIN].[dbo].[WI_SIM_Tel] --SIM_Number PHone_Number Sim_Tel_ID Sim_Tel_ID
Select * from [appsql-3\TRAIN].[ComCareTRAIN].[dbo].[WI_Registration] --Registration_ID Imei_Number SIM_Tel_ID Provider_ID
Select * from [appsql-3\TRAIN].[ComCareTRAIN].[dbo].[WI_Telco_Device] -- WI_Telco_Device_ID Imei_Number
Select * from [appsql-3\TRAIN].[ComCareTRAIN].[dbo].[WI_Phone_Plan] -- Phone_Plan_ID PHone_Number
Select * from [appsql-3\TRAIN].[ComCareTRAIN].[dbo].[WI_Allocation]
Select Provider_ID from [appsql-3\TRAIN].[ComCareTRAIN].[dbo].[WI_Provider]
*/
SELECT
J001.[Imei_Number]
,J003.[IMSI_Number]
,J002.[Sim_Number]
,J002.[Phone_Number]
,J005.[Organisation_name]
,J006.[Comments]

FROM
[APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[WI_Registration] J001
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[WI_SIM_Tel] J002 ON J002.[Sim_Tel_ID] = J001.[Sim_Tel_ID]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[WI_SIM] J003 ON J003.[Sim_Number] = J002.[Sim_Number]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[WI_Device] J004 ON J004.[IMEI_Number] = J001.[Imei_Number]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[Organisation] J005 ON J005.[Organisation_ID] = J001.[Organisation_ID]
LEFT OUTER JOIN [APPSQL-3\COMCAREPROD].[comcareprod].[dbo].[WI_Device] J006 ON J006.[IMEI_Number] = J001.[Imei_Number]
Where
	1=1
	and J001.[Finish] is null
--	and J003.[IMSI_Number] is Null
	and J005.[Organisation_name] is Null
	and J001.[Imei_Number] != 353423062580615
	and J002.[Sim_Number] is not null
--	or J001.[Imei_Number] is Null
--	and J001.[Imei_Number]=355054065671586
GROUP BY
J001.[Imei_Number]
,J003.[IMSI_Number]
,J002.[Sim_Number]
,J002.[Phone_Number]
,J005.[Organisation_name]
,J006.[Comments]

ORDER BY
--J006.[Comments]
J001.[Imei_Number]
,J003.[IMSI_Number] desc

--,J001.[Last_Used]

/*
Select * from [appsql-3\TRAIN].[ComCareTRAIN].[dbo].[WI_Telco_Device]
Order by
[Imei_Number]
Select * from [appsql-3\TRAIN].[ComCareTRAIN].[dbo].[WI_Registration]
Where
1=1
and Imei_Number=355054065671586 
*/

/*
Select provider_ID,imei_Number from [appsql-3\TRAIN].[ComCareTRAIN].[dbo].[WI_Registration] 
group by
provider_ID,imei_Number
order by
provider_ID,imei_Number
*/