

Declare  @OrgName varchar(128) = 'Disabilities Children'

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
Declare @RawTable table 
(
	Organisation_Name varchar(128)
	,FundingProg varchar(128)
	,Last_Name varchar(128)
	,Preferred_Name varchar(128)
	,Client_ID int
	,Row_Count int
	,RowNumber int
)
Insert into @RawTable

SELECT
	J005.Organisation_Name
	,J006.Description 'FundingProg'
	,J001.Last_Name
	,J001.Preferred_Name
	,J001.Client_ID
	,Count(J001.Client_ID)over(Partition by null) 'Row_Count'
	,ROW_NUMBER()over(Partition by null order by J001.Client_ID)'RowNumber'
FROM
(
	Select     
		CL.Client_ID
	    ,P.Last_Name
	    ,P.Given_Names
	    ,P.Preferred_Name
	    ,CONVERT(datetime,P.Deceased_Date) Deceased_Date
	from Client CL
	Inner Join Person P on Cl.Client_ID = P.Person_ID
	where
	P.Deceased_Date is null
) J001

--/*
LEFT OUTER JOIN 
(
	select distinct
		PC.Person_ID
		,PCT.Description
		,ROW_NUMBER()
			Over
			(
				partition by PC.Person_ID
				order by case
					when PCT.Description = 'Service Advisor' then '1'
					else PCT.Description
					end
			)'RN'
	from dbo.Personal_Contact PC
	Inner Join dbo.Personal_Contact_Type PCT ON PCT.Personal_Contact_Type_Code = PC.Personal_Contact_Type_Code

)J004 ON J004.Person_ID = J001.Client_ID
--*/
--/*

INNER JOIN 
(
	Select 
		SD.Client_ID
		,O.Organisation_Name
		,SD.Service_Type_Code
		,SD.Funding_Prog_Code
	from Service_Delivery SD
	inner join Period_of_Residency PR on PR.Person_ID = SD.Client_ID
	inner join Address A on A.Address_ID = PR.Address_ID
	inner Join Service_Provision SP on A.Suburb_ID = SP.Suburb_ID and SP.Service_Type_Code = SD.Service_Type_Code
	inner Join Organisation O on Sp.Centre_ID = O.Organisation_ID
	Where 
		PR.To_Date is null 
		and SD.To_Date is null
		and PR.Display_Indicator  = 1
) J005 ON J005.Client_ID = J001.Client_ID
--*/
LEFT OUTER JOIN dbo.Funding_Program J006 ON J006.Funding_Prog_Code = J005.Funding_Prog_Code


WHERE
	1=1

	AND J004.Description IS NOT NULL
	AND (J004.RN < 2 or J004.RN is null)
	AND J004.Description != 'Service Advisor'
	and J005.Organisation_Name in (@OrgName)
	and J006.To_Date is null

--	and J001.Client_ID = 10071173

ORDER BY
	J005.Organisation_Name
	,J001.Client_ID

--select * from @RawTable

--/*
Declare @i_RowNum int = 1
Declare @i_MaxRow int = (select top 1 RR.Row_Count from @RawTable RR)
Declare @i_CID int = null
declare @J_FundingProg VarChar(255) = null
declare @i_BaseCount int = 1
Declare @i_TriggerFirstTaskEntry int	= 1
Declare @JoinedFundProg table (Client_ID int,Joined_FundingProg VarChar(255))
declare @i_Temp int = 0
declare @VC_PrvFund varchar(128)=''
declare @VC_CurFund varchar(128)=''

--Start Main processing
while @i_RowNum <= @i_MaxRow
begin
	-----------------------------------------------------------------------------------------------------------
	--Define current provider for current entry
	set @i_CID = (select RR.Client_ID from @RawTable RR where RR.RowNumber = @i_RowNum)--baseValue setup
	Set @VC_CurFund = (select RR.FundingProg from @RawTable RR where RR.RowNumber = @i_RowNum)

	if @i_BaseCount = 1
	begin
		set @J_FundingProg = @VC_CurFund --Define Edit action (OS,A,OU,StartEnd,F)
		set @VC_PrvFund = ''
	end

	if @i_BaseCount <> 1
	begin
		set @VC_PrvFund = (select RR.FundingProg from @RawTable RR where RR.RowNumber = @i_RowNum - 1)
	end
		
	if @i_BaseCount <> 1 and @VC_PrvFund <> @VC_CurFund --@i_CID?
	begin
		set @J_FundingProg = @J_FundingProg + ', ' + @VC_CurFund
		--set @VC_PrvFund = @VC_CurFund
	end

	set @i_Temp = @i_BaseCount
	set  @i_BaseCount = @i_Temp + 1

	set @i_Temp = @i_RowNum
	 --Cycle mechanic
--	print @i_RowNum

	-----------------------------------------------------------------------------------------------------------
	--end base setup
	-----------------------------------------------------------------------------------------------------------
	if --Check to see if the provider ID has changed or the task has changed
	(@i_CID <> (select RR.Client_ID from @RawTable RR where RR.RowNumber = @i_RowNum+1)) 
	or  @i_RowNum = @i_MaxRow
	begin
		set @i_TriggerFirstTaskEntry = 0
	end
	

	if @i_TriggerFirstTaskEntry = 0
	begin
		insert into @JoinedFundProg Values (@i_CID,@J_FundingProg)
		set @i_TriggerFirstTaskEntry = 1
		set @i_BaseCount = 1
	end

	set @i_RowNum = @i_Temp + 1
end
--*/
--select * from @JoinedFundProg
--select * from @RawResult

--/*

Declare @ColapledTable table 
(
	Organisation_Name varchar(128)
	,FundingProg varchar(128)
	,Last_Name varchar(128)
	,Preferred_Name varchar(128)
	,Client_ID int
)
Insert into @ColapledTable
select
	J001.Organisation_Name
	,J002.Joined_FundingProg 'FundingProg'
	,J001.Last_Name
	,J001.Preferred_Name
	,J001.Client_ID
From @RawTable J001
Left outer join @JoinedFundProg J002 on J002.Client_ID = J001.Client_ID
where
	1=1

Group by
	J001.Organisation_Name
	,J002.Joined_FundingProg
	,J001.Last_Name
	,J001.Preferred_Name
	,J001.Client_ID

Order by
	J001.Organisation_Name
	,J001.Last_Name
	,J001.Preferred_Name
	,J001.Client_ID

--select * from @ColapledTable
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

SELECT
	J001.Organisation_Name
	,J001.FundingProg
	,J001.Last_Name
	,J001.Preferred_Name
	,J001.Client_ID
	,J007.Phone
	,J007.Building_name
	,J007.Location
	,J007.dwelling_number
	,J007.Street
	,J007.suburb
	,J007.Post_Code

FROM @ColapledTable J001

LEFT OUTER JOIN dbo.Person_Current_Address_Phone J007 ON J007.Person_id = J001.Client_ID

WHERE
	1=1
/*
ORDER BY
	J001.Organisation_Name
	,J001.Client_ID
*/
--select * from @RawTable
