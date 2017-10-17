--appsql-3\TRAIN.ComCareTRAIN
--APPSQL-3\COMCAREPROD.comcareprod
--comcareUAT

Declare @Start_Date date = '2017-06-01'
Declare @End_Date date = cast(getdate() as date)

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
J002.Organisation_Name = @Organisation_Name
--/*
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
select * from
(

	SELECT
	--	J001.Client_ID AS 'Client_ID'
		J002.Service_Type as 'Service_Type'
		,cast(J002.From_Date as date) 'EventDate'
	--	,J002.To_Date
		,'RollingTotalByService' = 
		(
			Select
			Count(SD.Service_Type_Code) --over(partition by SD.Service_Type_Code)
			From dbo.Service_Delivery SD
			inner join @Client_ID_List CL on CL.Client_ID = SD.Client_ID
			where
				SD.Service_Type_Code = J002.Service_Type_Code
				and SD.From_Date <= J002.From_Date
				and (SD.To_Date >= J002.From_Date or SD.To_Date is null)
		)
	--	,'Add'as'EventType'
	--	,J001.Client_ID AS 'Client_ID'

	FROM @Client_ID_List J001
	Inner Join
	(
		Select
			SD.Client_ID
			,SD.From_Date
			,SD.To_Date
			,SD.Service_Type_Code
			,ST.Description 'Service_Type'
			,1 'ServEnum'
		From dbo.Service_Delivery SD
			left outer join dbo.Service_Type ST On ST.Service_Type_Code = SD.Service_Type_Code
		Where 
			1=1
			--AND (SD.To_Date IS NULL or SD.To_Date > getdate())
	)J002 on J002.Client_ID = J001.Client_ID

	WHERE
		1=1
		and J002.Service_Type IN (select * from @ServiceType)
	--	and J002.Service_Type IN (@ServiceType)

	-------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------
	Union
	-------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------

	SELECT distinct
	--	J001.Client_ID AS 'Client_ID'
		J002.Service_Type as 'Service_Type'
		,cast(J002.To_Date as date) 'EventDate'
		,'RollingTotalByService' = 
		(
			Select
			Count(SD.Service_Type_Code)-- over(partition by SD.Service_Type_Code)
			From dbo.Service_Delivery SD
			inner join @Client_ID_List CL on CL.Client_ID = SD.Client_ID
			where
				SD.Service_Type_Code = J002.Service_Type_Code
				and SD.From_Date <= J002.To_Date
				and (SD.To_Date >= J002.To_Date or SD.To_Date is null)
		)
	--	,'Subtract'as'EventType'
	--	,J001.Client_ID AS 'Client_ID'

	FROM @Client_ID_List J001
	Inner Join
	(
		Select
			SD.Client_ID
			,SD.From_Date
			,SD.To_Date
			,SD.Service_Type_Code
			,ST.Description 'Service_Type'
			,1 'ServEnum'
		From dbo.Service_Delivery SD
			left outer join dbo.Service_Type ST On ST.Service_Type_Code = SD.Service_Type_Code
		Where 
			1=1
			--AND (SD.To_Date IS NULL or SD.To_Date > getdate())
	)J002 on J002.Client_ID = J001.Client_ID

	WHERE
		1=1
		and J002.To_Date is not null
		and J002.Service_Type IN (select * from @ServiceType)
	--	and J002.Service_Type IN (@ServiceType)
	-------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------
	Union
	--Define Start positions for graph
	-------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------

	SELECT distinct
	--	J001.Client_ID AS 'Client_ID'
		J002.Service_Type as 'Service_Type'
		,@Start_Date 'EventDate'
		,'RollingTotalByService' = 
		(
			Select
			Count(SD.Service_Type_Code)-- over(partition by SD.Service_Type_Code)
			From dbo.Service_Delivery SD
			inner join @Client_ID_List CL on CL.Client_ID = SD.Client_ID
			where
				SD.Service_Type_Code = J002.Service_Type_Code
				and SD.From_Date <= @Start_Date
				and (SD.To_Date >= @Start_Date or SD.To_Date is null)
		)
	--	,'Subtract'as'EventType'
	--	,J001.Client_ID AS 'Client_ID'

	FROM @Client_ID_List J001
	Inner Join
	(
		Select
			SD.Client_ID
			,SD.From_Date
			,SD.To_Date
			,SD.Service_Type_Code
			,ST.Description 'Service_Type'
			,1 'ServEnum'
		From dbo.Service_Delivery SD
			left outer join dbo.Service_Type ST On ST.Service_Type_Code = SD.Service_Type_Code
		Where 
			1=1
			--AND (SD.To_Date IS NULL or SD.To_Date > getdate())
	)J002 on J002.Client_ID = J001.Client_ID

	WHERE
		1=1
		and J002.Service_Type IN (select * from @ServiceType)
	--	and J002.Service_Type IN (@ServiceType)
	-------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------
	Union
	--Define END positions for graph
	-------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------

	SELECT distinct
	--	J001.Client_ID AS 'Client_ID'
		J002.Service_Type as 'Service_Type'
		,@End_Date 'EventDate'
		,'RollingTotalByService' = 
		(
			Select
			Count(SD.Service_Type_Code)-- over(partition by SD.Service_Type_Code)
			From dbo.Service_Delivery SD
			inner join @Client_ID_List CL on CL.Client_ID = SD.Client_ID
			where
				SD.Service_Type_Code = J002.Service_Type_Code
				and SD.From_Date <= @End_Date
				and (SD.To_Date >= @End_Date or SD.To_Date is null)
		)
	--	,'Subtract'as'EventType'
	--	,J001.Client_ID AS 'Client_ID'

	FROM @Client_ID_List J001
	Inner Join
	(
		Select
			SD.Client_ID
			,SD.From_Date
			,SD.To_Date
			,SD.Service_Type_Code
			,ST.Description 'Service_Type'
			,1 'ServEnum'
		From dbo.Service_Delivery SD
			left outer join dbo.Service_Type ST On ST.Service_Type_Code = SD.Service_Type_Code
		Where 
			1=1
			--AND (SD.To_Date IS NULL or SD.To_Date > getdate())
	)J002 on J002.Client_ID = J001.Client_ID

	WHERE
		1=1
		and J002.Service_Type IN (select * from @ServiceType)
	--	and J002.Service_Type IN (@ServiceType)
)T01
where
	T01.EventDate Between @Start_Date and @End_Date

ORDER BY 1,2

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>