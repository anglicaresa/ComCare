--/*
Declare @OmitionList_Codes Table (Code int)
insert into @OmitionList_Codes 
	values (12),(5),(20),(26),(23),(24),(25);

select 
	Jx001.Description
FROM dbo.Characteristic Jx001 
where 
	Jx001.Client_CHaracteristic = 1 
	and Jx001.Characteristic_Code not in (select * from @OmitionList_Codes)
order by 
	Jx001.Characteristic_Code
--*/
Declare @OrgName varchar(128) = N'Home Care East'
Declare @SpecialNeedList varchar(128) = N'Dementia'



SELECT distinct
	J005.Organisation_Name
	,J003.Description
	,count(J003.Description) over(partition by J005.Organisation_name,J003.Description)'Client_Count'
FROM dbo.Person_Characteristic J001

LEFT OUTER JOIN 
(
	Select
		CL.Client_ID
	    ,CONVERT(date,P.Deceased_Date) 'Deceased_Date'
	from Client CL
	Inner Join Person P on Cl.Client_ID = P.Person_ID
	where
	P.Deceased_Date is null
) J002 ON J002.Client_ID = J001.Person_ID

LEFT OUTER JOIN dbo.Characteristic J003 ON J003.Characteristic_Code = J001.Characteristic_Code AND J003.Description IS not NULL
LEFT OUTER JOIN dbo.Service_Delivery J004 ON J004.Client_ID = J002.Client_ID

INNER JOIN 
(
	Select 
		SD.Client_ID
		,O.Organisation_Name
		,SD.Service_Type_Code 
	from Service_Delivery SD
	join Period_of_Residency PR on PR.Person_ID = SD.Client_ID
	join Address A on A.Address_ID = PR.Address_ID
	Join Service_Provision SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
	Join Organisation O on Sp.Centre_ID = O.Organisation_ID
	Where 
		PR.To_Date is null 
		and PR.Display_Indicator  = 1
) J005 ON J005.Client_ID = J004.Client_ID AND J005.Service_Type_Code = J004.Service_Type_Code

WHERE
	1=1
	and J005.Organisation_Name in (@OrgName)
	and J003.Description in (@SpecialNeedList)
ORDER BY
1,2
