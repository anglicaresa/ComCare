declare @Org_name Varchar(128) = 'Disabilities Children'
/*
	Select Distinct
		SD.Client_ID
		,O.Organisation_Name as 'Organisation_Name'
	--	,SD.Service_Type_Code  as 'Service_Type_Code'
	from dbo.Service_Delivery SD
		join dbo.Period_of_Residency PR on PR.Person_ID = SD.Client_ID
		join dbo.Address A on A.Address_ID = PR.Address_ID
		Join dbo.Service_Provision SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
		Join dbo.Organisation O on Sp.Centre_ID = O.Organisation_ID
	Where 
		PR.To_Date is null 
		and PR.Display_Indicator = 1
		and O.Organisation_Name in (@Org_Name)
--*/
--/*
Select Distinct
		SD.Client_ID
		,O.Organisation_Name as 'Organisation_Name'
	From dbo.Organisation O
	join dbo.Service_Provision SP on SP.Centre_ID = O.Organisation_ID
	join dbo.Address A on A.Suburb_ID = SP.Suburb_ID
	join dbo.Period_of_Residency PR on PR.Address_ID = A.Address_ID
	join dbo.Service_Delivery SD on SD.Client_ID = PR.Person_ID and SD.Service_Type_Code = SP.Service_Type_Code
Where 
		PR.To_Date is null 
		and PR.Display_Indicator = 1
		and O.Organisation_Name in (@Org_Name)
--*/