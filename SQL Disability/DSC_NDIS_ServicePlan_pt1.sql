use ComCareProd

/*
select * from dbo.Person
where Person_ID = 10071967

select * from dbo.gender
*/



--/*
Declare @Client_ID_ AS INT
--Set @Client_ID_ = 10074503
Set @Client_ID_ = 10071967
--*/
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------
SELECT 
	J001.Client_ID as 'Client_Id'
	,J001.Title  as 'Client_Title'
	,J001.Last_Name as 'Client_LastName'
	,J001.Preferred_Name as 'Client_PreferredName'
	,J003.Description as 'Client_CardType'
	,J002.Card_No as 'Client_CardNo'
	,J004.Contact_Type as 'Contact_Type'
	,J006.Title as 'Contact_Title'
	,J006.Last_Name as 'Contact_LastName'
	,J006.Preferred_Name as 'Contact_PreferredName'
	,J011.Title as 'Provider_Title'
	,J011.Preferred_Name as 'Provider_PreferredName'
	,J011.Last_Name as 'Provider_lastName'
	,CONVERT(date, J013.GOC_Defined_Date) as 'GOC_DefinedDate'
	,CONVERT(date, J013.Outcome_Date) as 'GOC_OutcomeDate'
	,J004.RN as 'RowNumber'
	,J001.Gender_Code

FROM --CLIENT
(
	Select     
		CL.Client_ID
		,P.Last_Name
		,P.Given_Names
		,P.Preferred_Name
		,CONVERT(date,P.Deceased_Date) as 'Deceased_Date'
		,T.Description as 'Title'
		,p.Gender_Code as 'Gender_Code'
	from dbo.Client CL
		Inner Join dbo.Person P on Cl.Client_ID = P.Person_ID
		Inner Join dbo.Title T on P.Title_Code = T.Title_Code
) J001

LEFT OUTER JOIN dbo.Card_Holder J002 ON J002.Person_ID = J001.Client_ID
LEFT OUTER JOIN dbo.Card_Type J003 ON J003.Card_Type_ID = J002.Card_Type_ID
----

--contact person with parental preference filtering
Left outer join
(
	Select
		PC.Person_ID
		,PC.Contact_ID
		,PCT.Description as 'Contact_Type'
		,ROW_NUMBER() Over
		(
			Partition BY PC.Person_ID Order By
				Case
					WHEN PCT.Description = 'Mother' then '1'
					WHEN PCT.Description = 'Father' then '2'
					WHEN PCT.Description = 'Parent' then '3'
					WHEN PCT.Description = 'Step Mother' then '4'
					WHEN PCT.Description = 'Step Father' then '5'
					WHEN PCT.Description = 'Guardian' then '6'
					WHEN PCT.Description = 'Foster Parent' then '7'
					WHEN PCT.Description = 'Grandparent' then '8'
					WHEN PCT.Description is null then '10'
					Else PCT.Description END ASC
		) AS 'RN'
	From dbo.Personal_Contact PC
		Left outer Join dbo.Personal_Contact_Type PCT ON PCT.Personal_Contact_Type_Code = PC.Personal_Contact_Type_Code 
	Where 
		1=1
		and PCT.Description in (N'Mother',N'Father',N'Parent',N'Step Mother',N'Step Father',N'Guardian',N'Foster Parent','Grandparent')
		OR PCT.Description IS NULL
)J004 on J004.Person_ID = J001.Client_ID

--Contact details
Left outer JOIN 
(
	Select
		P.Person_ID
		,P.Preferred_Name
		,P.Last_Name
		,T.Description as 'Title'
	from dbo.Person P
		Inner Join dbo.Title T on P.Title_Code = T.Title_Code

) J006 ON J006.Person_ID = J004.Contact_ID

LEFT OUTER JOIN dbo.Task_Schedule_Allocation J007 ON J007.Client_ID = J001.Client_ID
LEFT OUTER JOIN dbo.Round_Allocation J008 ON J008.Schedule_Sequence_No = J007.Schedule_Sequence_No
LEFT OUTER JOIN dbo.Service_Provision_Position J009 ON J009.Service_Prov_Position_ID = J008.Service_Prov_Position_ID
Left outer JOIN dbo.Position_Allocation J010 ON J010.Service_Prov_Position_ID = J009.Service_Prov_Position_ID

--Provider Details
left outer JOIN 
(
	Select
		Prov.Provider_ID
		,P.Preferred_Name
		,P.Last_Name
		,T.Description as 'Title'
	from dbo.Provider Prov
		Inner Join dbo.Person P on Prov.Provider_ID = P.Person_ID
		Inner Join dbo.Title T on P.Title_Code = T.Title_Code

) J011 ON J011.Provider_ID = J010.Provider_ID

--GOC stuff
LEFT OUTER JOIN dbo.FC_Client_Contract J012 ON J012.Client_ID = J001.Client_ID
LEFT OUTER JOIN dbo.FC_Client_Goal_of_Care J013 ON J013.Client_Contract_ID = J012.Client_Contract_ID




--Organisation filtering Primary.
LEFT OUTER JOIN dbo.Service_Delivery J017  ON J017.Client_ID = J001.Client_ID

INNER JOIN 
(
	Select 
		SD.Client_ID
		,O.Organisation_Name as 'Organisation_Name'
		,SD.Service_Type_Code 
	from dbo.Service_Delivery SD 
		join dbo.Period_of_Residency PR on PR.Person_ID = SD.Client_ID
		join dbo.Address A on A.Address_ID = PR.Address_ID
		Join dbo.Service_Provision SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
		Join dbo.Organisation O on Sp.Centre_ID = O.Organisation_ID
	Where PR.To_Date is null and PR.Display_Indicator  = 1
) J018 ON J018.Client_ID = J017.Client_ID AND J018.Service_Type_Code = J017.Service_Type_Code


WHERE
	1=1
	AND J001.Client_ID = @Client_ID_
	AND J018.Organisation_Name = N'Disabilities Children'
	AND J003.Description=N'NDIS Number'
	AND J004.RN < 3

GROUP BY
	J001.Client_ID
	,J001.Title
	,J001.Last_Name
	,J001.Preferred_Name
	,J003.Description
	,J002.Card_No
	,J004.Contact_Type
	,J006.Title
	,J006.Last_Name
	,J006.Preferred_Name
	,J011.Title
	,J011.Preferred_Name
	,J011.Last_Name
	,CONVERT(date, J013.GOC_Defined_Date) 
	,CONVERT(date, J013.Outcome_Date)
	,J004.RN
	,J001.Gender_Code

ORDER BY
	J001.Client_ID
	,J004.RN
