--appsql-3\TRAIN.ComCareTRAIN
--APPSQL-3\COMCAREPROD.comcareprod
--comcareUAT

Declare @Start_Date date = '2005-01-01'
Declare @End_Date date = cast(getdate() as date)

Declare @Client_ID_Froced int = 10073247

Declare @ServiceType table (Serv VarChar(255))
insert into @ServiceType
	Select Description From dbo.Service_Type st where Description like 'DC %'
--select * from @ServiceType

Declare @Organisation_Name varchar(40) = 'Disabilities Children'

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
declare @Client_ID_List table (Client_ID int)
insert into @Client_ID_List
select
	J001.Client_ID
From dbo.Client J001
INNER JOIN
(
	Select distinct
		SD.Client_ID
		,O.Organisation_Name
	from dbo.Service_Delivery SD
		join dbo.Period_of_Residency PR on PR.Person_ID = SD.Client_ID
		join dbo.Address A on A.Address_ID = PR.Address_ID
		Join dbo.Service_Provision SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
		Join dbo.Organisation O on Sp.Centre_ID = O.Organisation_ID
	Where 
		PR.To_Date is null 
		and PR.Display_Indicator  = 1
) J002 ON J002.Client_ID = J001.Client_ID
where
	1=1
	and J002.Organisation_Name = @Organisation_Name
--	and J001.Client_ID = @Client_ID_Froced
--/*
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
declare @RawData Table
(
	Client_ID int
	,Service_Type VarChar(128)
	,From_Date date
	,Creation_Date Date
	,RN int
)
insert into @RawData
SELECT
	J001.Client_ID AS 'Client_ID'
	,J002.Service_Type as 'Service_Type'
	,cast(J002.From_Date as date) 'From_Date'
	,cast(J002.Creation_Date as date) 'Creation_Date'
	,ROW_NUMBER()over(partition by J001.Client_ID order by J002.From_Date,J002.Service_Type)'RN'
FROM @Client_ID_List J001
Inner Join
(
	Select
		SD.Client_ID
		,SD.From_Date
		,SD.To_Date
		,SD.Service_Type_Code
		,SD.Creation_Date
		,ST.Description 'Service_Type'
		,1 'ServEnum'
		,ROW_NUMBER()over(Partition by SD.Client_ID,SD.Service_Type_Code order by SD.From_Date)'RN_1'
	From dbo.Service_Delivery SD
		left outer join dbo.Service_Type ST On ST.Service_Type_Code = SD.Service_Type_Code
	Where 
		1=1
		--AND (SD.To_Date IS NULL or SD.To_Date > getdate())
)J002 on J002.Client_ID = J001.Client_ID and (J002.RN_1 = 1 or J002.RN_1 is null)

WHERE
	1=1
	and J002.Service_Type IN (select * from @ServiceType)
--	and J002.Service_Type IN (@ServiceType)
	and J002.From_Date Between @Start_Date and @End_Date
ORDER BY 1,3,2

--select * from @RawData order by Creation_Date


Select 
T01.Client_ID
,T01.Client_Name

,T01.Service_1_FromDate
,T01.Service_1

,DATEDiff(Day,T01.Service_1_FromDate,T01.Service_2_FromDate)'Interval_1'
,T01.Service_2_FromDate
,T01.Service_2

,DATEDiff(Day,T01.Service_2_FromDate,T01.Service_3_FromDate)'Interval_2'
,T01.Service_3_FromDate
,T01.Service_3

,DATEDiff(Day,T01.Service_3_FromDate,T01.Service_4_FromDate)'Interval_3'
,T01.Service_4_FromDate
,T01.Service_4

,DATEDiff(Day,T01.Service_4_FromDate,T01.Service_5_FromDate)'Interval_4'
,T01.Service_5_FromDate
,T01.Service_5

,DATEDiff(Day,T01.Service_5_FromDate,T01.Service_6_FromDate)'Interval_5'
,T01.Service_6_FromDate
,T01.Service_6

,DATEDiff(Day,T01.Service_7_FromDate,T01.Service_6_FromDate)'Interval_6'
,T01.Service_7_FromDate
,T01.Service_7
from
(
	Select Distinct
		J001.Client_ID
		,J002.Preferred_Name+' '+J002.Last_Name 'Client_Name'
		,'Service_1'=
		(
			Select X001.Service_Type From @RawData X001 where X001.Client_ID = J001.Client_ID and X001.RN = 1
		)
		,'Service_1_FromDate'=
		(
			Select X001.From_Date From @RawData X001 where X001.Client_ID = J001.Client_ID and X001.RN = 1
		)
/*		,'Service_1_ToDate'=
		(
			Select X001.To_Date From @RawData X001 where X001.Client_ID = J001.Client_ID and X001.RN = 1
		)
*/		------------------------------------------
		,'Service_2'=
		(
			Select X001.Service_Type From @RawData X001 where X001.Client_ID = J001.Client_ID and X001.RN = 2
		)
		,'Service_2_FromDate'=
		(
			Select X001.From_Date From @RawData X001 where X001.Client_ID = J001.Client_ID and X001.RN = 2
		)
		------------------------------------------
		,'Service_3'=
		(
			Select X001.Service_Type From @RawData X001 where X001.Client_ID = J001.Client_ID and X001.RN = 3
		)
		,'Service_3_FromDate'=
		(
			Select X001.From_Date From @RawData X001 where X001.Client_ID = J001.Client_ID and X001.RN = 3
		)
		------------------------------------------
		,'Service_4'=
		(
			Select X001.Service_Type From @RawData X001 where X001.Client_ID = J001.Client_ID and X001.RN = 4
		)
		,'Service_4_FromDate'=
		(
			Select X001.From_Date From @RawData X001 where X001.Client_ID = J001.Client_ID and X001.RN = 4
		)
		------------------------------------------
		,'Service_5'=
		(
			Select X001.Service_Type From @RawData X001 where X001.Client_ID = J001.Client_ID and X001.RN = 5
		)
		,'Service_5_FromDate'=
		(
			Select X001.From_Date From @RawData X001 where X001.Client_ID = J001.Client_ID and X001.RN = 5
		)
		------------------------------------------
		,'Service_6'=
		(
			Select X001.Service_Type From @RawData X001 where X001.Client_ID = J001.Client_ID and X001.RN = 6
		)
		,'Service_6_FromDate'=
		(
			Select X001.From_Date From @RawData X001 where X001.Client_ID = J001.Client_ID and X001.RN = 6
		)
		------------------------------------------
		,'Service_7'=
		(
			Select X001.Service_Type From @RawData X001 where X001.Client_ID = J001.Client_ID and X001.RN = 7
		)
		,'Service_7_FromDate'=
		(
			Select X001.From_Date From @RawData X001 where X001.Client_ID = J001.Client_ID and X001.RN = 7
		)

	From @RawData J001
	Left outer join dbo.Person J002 on J002.Person_ID = J001.Client_ID
)T01

where
	1=1
--	and T01.Service_1 is not null
	order by T01.Service_1_FromDate

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>