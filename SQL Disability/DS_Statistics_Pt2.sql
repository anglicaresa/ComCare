--appsql-3\TRAIN.ComCareTRAIN
--APPSQL-3\COMCAREPROD.comcareprod
--comcareUAT

/*
If(OBJECT_ID('tempdb.dbo.#temp') Is Not Null)
Begin
    Drop Table #Temp
End

create table #temp (Serv VarChar(255))
insert into #temp
	Select Description From dbo.Service_Type where Left(Description, 3)='DA '

--select * from #temp
--*/

Declare @ServiceType table (Serv VarChar(255))
insert into @ServiceType
	Select Description From dbo.Service_Type st where Description like 'DC %'
--select * from @ServiceType

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--in UAT 

Declare @Client_ID_ AS INT
--Set @Client_ID_ = 10069826
--Set @Client_ID_ = 10074726

--Declare @ServiceType varchar(60)

--set @ServiceType = 'DC Assistance to Access Community'

Declare @Organisation_Name_ varchar(40)
set @Organisation_Name_ = 'Disabilities Children'
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

Declare @t_CharExc table 
(
	Char_Exclude VarChar(64)
)
insert into @t_CharExc values 
	('Self funded retiree')
	,('Visit from a male provider')
	,('Visit from a female provider')
	,('Care Leaver Supported Residential Facility')
	,('Consent for Future Contact')
	,('Does not Consent to Future Contact')
	,('Council Area')
	,('Provider Car Details')
--select * from @t_CharExc

Declare @CharFilt Table (Charfilt VarChar(128))
insert into @CharFilt
select '(None Recorded)' 'Characteristic'
union
Select 
	Description
from dbo.Characteristic
where
1=1
and Description Not in (select * from @t_CharExc)

--insert into @CharFilt values (NULL)

--select * from @CharFilt
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

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
J002.Organisation_Name = @Organisation_Name_


SELECT distinct
--	J001.Client_ID AS 'Client_ID'
	J013.Service_Type as 'Service_Type'
	,count(J013.Service_Type)over(partition by J013.Service_Type)'Service_Count_By_Type'
FROM @Client_ID_List J001

Inner Join
(
	Select
		SD.Client_ID
		,ST.Description 'Service_Type'
	From dbo.Service_Delivery SD
		left outer join dbo.Service_Type ST On ST.Service_Type_Code = SD.Service_Type_Code
	Where 
		1=1
		AND (SD.To_Date IS NULL or SD.To_Date > getdate())
)J013 on J013.Client_ID = J001.Client_ID

WHERE
	1=1
	and J013.Service_Type IN (select * from @ServiceType)
--	and J013.Service_Type IN (@ServiceType)

ORDER BY
	1
