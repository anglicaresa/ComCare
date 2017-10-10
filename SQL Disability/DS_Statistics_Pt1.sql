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


-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<From Here down

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
	J001.Client_ID AS 'Client_ID'
	,LAG(J001.Client_ID) Over 
		(Order by J001.Client_ID) as 'Pre_ID'
	,J001.Title AS 'Client_Title'
	,J001.Last_Name AS 'Client_LastName'
	,J001.Preferred_Name AS 'Client_PreferredName'
	,CONVERT(date,J001.Birth_Date) AS 'Birth_Date'
	,J001.Gender as 'Gender'
	,J013.Service_Type as 'Service_Type'
	,J012.Description as 'Diagnosis'
	,count(J012.Description) over(partition by J001.Client_ID,J013.Service_Type,J018.Characteristic) 'DiagnosisCount'
	,convert(Varchar(16) ,iif(J017.Phone is null, J008.Phone,J017.Phone)) 'Contact_Phone_Number'
	,J002.Building_name AS 'BuildingName'
	,J002.Location AS 'Location'
	,J002.dwelling_number AS 'DwellingNumber'
	,J002.Street AS 'Street'
	,J002.suburb AS 'Suburb'
	,J002.Post_Code AS 'PostCode'
	,J015.MF_Provider as 'M/F_Provider'
	,convert(Varchar(16) ,J002.Phone) as 'alt_Phone'
	,J001.Ethnicity as 'Ethnicity'
	,J018.Characteristic
	,Convert(int ,(Count(J013.Service_Type) Over (Partition by J001.Client_ID, J012.Description,J018.Characteristic))) as 'ServiceCount'

FROM 
(
	Select     
		CL.Client_ID
		,P.Last_Name
		,P.Given_Names
		,EC.Description as 'Ethnicity' 
		,P.Preferred_Name
		,P.Birth_Date
		,CONVERT(date,P.Deceased_Date) as Deceased_Date
		,G.Description as 'Gender'
		,T.Description as 'Title'
	from @Client_ID_List CL
		Inner Join dbo.Person P on Cl.Client_ID = P.Person_ID
		Inner Join dbo.Title T on P.Title_Code = T.Title_Code
		Left Outer Join dbo.Ethnicity_Classification EC on P.Ethnicity_Class_Code = EC.Ethnicity_Class_Code
		Left Outer Join dbo.Gender G on P.Gender_Code = G.Gender_Code
) J001

LEFT OUTER JOIN dbo.Person_Current_Address_Phone J002 ON J002.Person_id = J001.Client_ID


left outer join
(
	Select
		PC.Person_ID
		,PC.Contact_ID
		,PCT.Description
		,ROW_NUMBER() Over
		(
			Partition BY PC.Person_ID Order By
				Case
					WHEN PCT.Description = 'Mother' then '1'
					WHEN PCT.Description = 'Father' then '2'
					WHEN PCT.Description = 'Parent' then '3'
					WHEN PCT.Description = 'Grandparent' then '4'
					WHEN PCT.Description = 'Step Mother' then '5'
					WHEN PCT.Description = 'Step Father' then '6'
					WHEN PCT.Description = 'Guardian' then '7'
					WHEN PCT.Description = 'Foster Parent' then '8'
					WHEN PCT.Description = 'Other relative' then '9'
					WHEN PCT.Description is null then '10'
					Else PCT.Description END ASC
		) AS 'RN' 	
	From dbo.Personal_Contact PC
	Left outer Join dbo.Personal_Contact_Type PCT ON PCT.Personal_Contact_Type_Code = PC.Personal_Contact_Type_Code 
)J003 on J003.Person_ID = J001.Client_ID

left outer JOIN
(
	Select
		P.Person_ID
		,P.Preferred_Name
		,P.Last_Name
		,T.Description as 'Title'
	from dbo.Person P
		Inner Join dbo.Title T on P.Title_Code = T.Title_Code
) J007 ON J007.Person_ID = J003.Contact_ID

LEFT OUTER JOIN dbo.Person_Current_Address_Phone J008 ON J008.Person_id = J007.Person_ID
LEFT OUTER JOIN dbo.Person_Current_Address_Phone J017 ON J017.Person_id = J001.Client_ID

LEFT OUTER JOIN dbo.Diagnosis J011 ON J011.Client_ID = J001.Client_ID
LEFT OUTER JOIN dbo.Diagnosis_Category J012 ON J012.Diagnosis_Category_Code = J011.Diagnosis_Category_Code

Inner Join
(
	Select
		SD.Client_ID
		,ST.Description 'Service_Type'
	From dbo.Service_Delivery SD
		left outer join dbo.Service_Type ST On ST.Service_Type_Code = SD.Service_Type_Code
	Where 
		1=1
		AND SD.To_Date IS NULL
)J013 on J013.Client_ID = J001.Client_ID

LEFT OUTER JOIN 
(
	select
		PC.Person_ID AS 'Person_ID'
		,C.Description as 'CL_LGBTI'
	From dbo.Person_Characteristic PC
		inner join dbo.Characteristic C ON C.Characteristic_Code = PC.Characteristic_Code
	where
		1=1
		and C.Description = 'Identify as LGBTI'
)J014 on J014.Person_ID = J001.Client_ID

left outer JOIN 
(
	select
		PC.Person_ID AS 'Person_ID'
		,C.Description as 'MF_Provider'
		,ROW_NUMBER() Over
		(
			Partition BY PC.Person_ID Order By
				Case
					WHEN C.Description = 'Visit from a female provider' then '1'
					WHEN C.Description = 'Visit from a male provider' then '2'
					else C.Description END ASC
		) AS 'RN'
	From dbo.Person_Characteristic PC
		left outer join dbo.Characteristic C ON C.Characteristic_Code = PC.Characteristic_Code
	where 
		C.Description = 'Visit from a female provider' 
		or C.Description = 'Visit from a male provider'
	
)J015 on J015.Person_ID = J001.Client_ID

Left outer join
(
	select
		PC.Person_ID AS 'Person_ID'
		,C.Description as 'Characteristic'
	From dbo.Person_Characteristic PC
		inner join dbo.Characteristic C ON C.Characteristic_Code = PC.Characteristic_Code
	where
		1=1

)J018 on J018.Person_ID = J001.Client_ID

WHERE
	1=1
	and ( IIF( J003.RN IS NULL, 1, J003.RN ) = 1 )
	and ( IIF( J015.RN IS NULL, 1, J015.RN ) = 1 )
	and J001.Deceased_Date IS NULL

--	and J013.Service_Type IN (select * from @ServiceType)
	and J013.Service_Type IN (@ServiceType)

ORDER BY
	J001.Client_ID


