--select * from dbo.FC_Client_Supplement where override_Rate is not null
--select distinct Activity_type from FC_Transaction
--select Description from dbo.FC_Transaction_Type
--select * from dbo.FC_Supplement_Type J009 where (J009.FC_Supplement_Type_ID = 5 or J009.FC_Supplement_Type_ID = 6 or J009.FC_Supplement_Type_ID = 7 or J009.FC_Supplement_Type_ID = 9 or J009.FC_Supplement_Type_ID = 30 or J009.FC_Supplement_Type_ID = 1)
--use ComCareProd

/*
declare @TransactionType table(Type VarChar(128))

insert into @TransactionType
	select 
		FC_TT1.Description
	from dbo.FC_Transaction_Type FC_TT1 
	where 
	1=1
	and FC_TT1.Description = 'Administrative Overheads'


	Select * from dbo.FB_Client_Contract_Billing where client_ID = 10019215
--*/


--declare @Client_ID int = 10019215
--declare @Client_ID int = 10013840
declare @Client_ID int = 10021555

declare @FiltIncomeTested int = 1
declare @ClaimYear int = 2017
declare @ClaimPeriod_Start int = 1
declare @ClaimPeriod_End int = 6

Declare @FunderContract_ID Table 
(
	Description Varchar(128)
	,Funder_Contract_ID int
)
insert into @FunderContract_ID
select 
	J001.Description
	,J001.Funder_Contract_ID
from dbo.FC_Funder_Contract J001
where 
	J001.Description like 'CHSP %'
	or J001.Description like '% Care at Home'



--select * from @FunderContract_ID

--------------<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<here down
Declare @StartDate Date = DATEFROMPARTS(@ClaimYear,@ClaimPeriod_Start,1)
Declare @EndDate Date = DateADD(Day,-1,DATEFROMPARTS(@ClaimYear,@ClaimPeriod_End+1,1))

Declare @ClaimSum_01 Table
(
	FunderProgam VarChar(128)
	,Client_ID int
	,ClientName VarChar(128)
	,Claim_Year int
	,Period varchar(8)
	,Actual_Income Dec(10,2)
	,Client_Income Dec(10,2)
	,Adjustment_Claim_Income Dec(10,2)
	,Adjustment_Client_Income Dec(10,2)
	,Claimed_Income Dec(10,2)
	,Eligible_Days int
	,Accumulated_Eligible_Days int
	,Effective_From_Date DateTime
	,Effective_To_Date DateTime
--	,Billing_Start_Date DateTime
--	,Billing_End_Date DateTime
	,Period_INT int
	,Funded_indicator int
	,LevelOfCare int

)
insert into @ClaimSum_01
select
	J002.Description 'FunderProgam'
	,J001.Client_ID
	,Concat(J006.Last_Name,', ',J006.Preferred_Name)'ClientName'
	,J005.Claim_Year
	,Case 
		when J005.Period = 1 then 'Jan'
		when J005.Period = 2 then 'Feb'
		when J005.Period = 3 then 'Mar'
		when J005.Period = 4 then 'Apr'
		when J005.Period = 5 then 'May'
		when J005.Period = 6 then 'Jun'
		when J005.Period = 7 then 'Jul'
		when J005.Period = 8 then 'Aug'
		when J005.Period = 9 then 'Sep'
		when J005.Period = 10 then 'Oct'
		when J005.Period = 11 then 'Nov'
		when J005.Period = 12 then 'Dec'
		end 'Period'
	,J005.Actual_Income
	,J005.Client_Income
	,J005.Adjustment_Claim_Income
	,J005.Adjustment_Client_Income
	,J005.Claimed_Income
	,J005.Eligible_Days
	,J005.Accumulated_Eligible_Days
	,J001.Effective_From_Date
	,J001.Effective_To_Date
--	,J007.Billing_Start_Date
--	,J007.Billing_End_Date
	,J005.Period 'Period_INT'
	,J001.Funded_Indicator
	,J001.Program_Level_ID 'LevelOfCare'

from dbo.FC_Funder_Contract J002
left outer join dbo.FC_Client_Contract J001 on J002.funder_Contract_ID = J001.funder_Contract_ID
left outer join dbo.FC_Claim_History J005 on J005.Client_Contract_ID = J001.Client_Contract_ID
left outer join dbo.Person J006 on J006.Person_ID = J001.Client_ID
--left outer join dbo.FC_Client_Supplement J007 on J001.Client_Contract_ID = J007.Client_Contract_ID and J007. = J001.Funder_Contract_ID
where
	1=1
	and J001.Client_ID = @Client_ID
--	and J002.Funder_Contract_ID in (@FunderContract_ID)
	and J002.Funder_Contract_ID in (select Funder_Contract_ID from @FunderContract_ID)
	and J005.Claim_Year = @ClaimYear
	and J005.Period between @ClaimPeriod_Start and @ClaimPeriod_End

order by
1,2,4, J005.Period

--select * from @ClaimSum_01
-----------------------------------------------------------------------------------------------------------------------------
Declare @SubsRate Table
(
	Client_ID int
	,Description VarChar(64)
	,FC_Supplement_Type_ID int
	,Supplement_Rate Dec(10,2)
	,From_Date Datetime
	,To_Date DateTime
	,Sup_From_Date DateTime
	,Sup_To_Date DateTime
)
insert into @SubsRate
select
	J001.Client_ID 'Client_ID'
--	,J001.Program_Level_ID
	,J009.Description
	,J009.FC_Supplement_Type_ID
	,cast(J009.Affect_Funder_Claim + cast(iif(J005.Override_Rate is null, J007.Supplement_Rate,J005.Override_Rate)as Varchar(16))as decimal(10,2))'Supplement_Rate'
	,iif(J005.Override_Rate is null, J007.Effective_From_Date,J005.Effective_From_Date)'From_Date'
	,iif(J005.Override_Rate is null, J007.Effective_To_Date,J005.Effective_To_Date)'To_Date'
	,J005.Effective_From_Date 'Sup_From_Date'
	,J005.Effective_To_Date 'Sup_To_Date'
	
From
(
	select 
	CC.* 
	from dbo.FC_Client_Contract CC
	inner join(Select Distinct Client_ID,Effective_From_Date from @ClaimSum_01) CS on CS.Client_ID = CC.Client_ID
	where CC.Effective_To_Date is null
)J001

Left outer Join dbo.FC_Funder_Contract J002	on J002.funder_Contract_ID = J001.funder_Contract_ID
Left outer Join dbo.FC_Funding_Care_Model J003 on J003.Funding_Care_Model_ID = J002.Funding_Care_Model_ID
Left outer join dbo.FC_Account J004 on J004.client_Contract_ID = J001.client_Contract_ID and J004.FC_Account_Type_ID = 1
inner join dbo.FC_Client_Supplement J005 on J005.client_Contract_ID = J004.client_Contract_ID
inner join dbo.Person J006 on J006.Person_ID = J001.Client_ID
Left outer join dbo.FC_Supplement_Rate J007 on J007.FC_Supplement_ID = J005.FC_Supplement_ID and J007.Program_Level_ID = J001.Program_Level_ID
left outer join dbo.FC_Supplement J008 on J008.FC_Supplement_ID = J005.FC_Supplement_ID
left outer join dbo.FC_Supplement_Type J009 on J009.FC_Supplement_Type_ID = J008.FC_Supplement_Type_ID and J009.Effective_To_Date is null

where
	J003.Description  = 'Home Care Package'
--	and J002.Funder_Contract_ID in (@FunderContract_ID)
	and J001.Funder_Contract_ID in (select Funder_Contract_ID from @FunderContract_ID)
	and (J007.Effective_To_Date > J001.Effective_From_Date or J007.Effective_To_Date is null)
	and J001.Effective_To_Date is null
	and (J005.Effective_To_Date > J001.Effective_From_Date or J005.Effective_To_Date is null)
	and (J009.FC_Supplement_Type_ID = 5 or J009.FC_Supplement_Type_ID = 6 or J009.FC_Supplement_Type_ID = 7 or J009.FC_Supplement_Type_ID = 9 or J009.FC_Supplement_Type_ID = 30 or J009.FC_Supplement_Type_ID = 1)

order by 1,3,4
--select * from @SubsRate
-----------------------------------------------------------------------------------------------------------------------------
Declare @Hosp Table
(
	Client_ID int
	,From_Date Datetime
	,To_Date DateTime
)
insert into @Hosp
select Distinct
	J001.Client_ID
	,cast(J002.From_Date as datetime)'From_Date'
	,cast(J002.To_Date as datetime)'To_Date'
From @ClaimSum_01 J001
left outer join dbo.Hospitalisation J002 on J002.Client_ID = J001.Client_ID
where
	1=1
	and J002.From_Date between @StartDate and @EndDate
	or J002.To_Date Between @StartDate and @EndDate
	or @StartDate between J002.From_Date and J002.To_Date


-----------------------------------------------------------------------------------------------------------------------------
--/* Need to handle the vairous dates for rate changes. done
Select
	T02.*
	,Cast(T02.BaseSubsidy_Rate * T02.RateMult as decimal(12,4)) 'Cal_BaseSubsidy'
	,Cast(T02.IncomeTested_Rate * T02.RateMult as decimal(12,4)) 'Cal_IncomeTested'
	,Cast(T02.Dementia_Veterans_Rate * T02.RateMult as decimal(12,4)) 'Cal_Dementia_Veterans'
	,Cast(T02.Financial_Hardship_Rate * T02.RateMult as decimal(12,4)) 'Cal_Financial_Hardship'
	,Cast(T02.Oxygen_Rate * T02.RateMult as decimal(12,4)) 'Cal_Oxygen'
From
(
	Select
	T01.*
	,cast(iif 
	(
		T01.Sum_Rate is null or T01.Sum_Rate = 0
		,0.0
		,(T01.Actual_Income/(T01.Sum_Rate + iif(T01.Sum_Rate is null or T01.Sum_Rate = 0,1.0,0.0 )))
	)as decimal(12,4))  'RateMult'
	From
	(
		Select
			J001.*
			,iif(J001.FirstDayOfPeriod > J002.Sup_To_Date ,0.0 ,iif(J002.Supplement_Rate is null,0.0,J002.Supplement_Rate)) 'BaseSubsidy_Rate'
			,iif(J001.FirstDayOfPeriod > J003.Sup_To_Date ,0.0 ,iif(J003.Supplement_Rate is null,0.0,J003.Supplement_Rate)) 'IncomeTested_Rate'
			,iif(J001.FirstDayOfPeriod > J004.Sup_To_Date ,0.0 ,iif(J004.Supplement_Rate is null,0.0,J004.Supplement_Rate)) 'Dementia_Veterans_Rate'
			,iif(J001.FirstDayOfPeriod > J005.Sup_To_Date ,0.0 ,iif(J005.Supplement_Rate is null,0.0,J005.Supplement_Rate)) 'Financial_Hardship_Rate'
			,iif(J001.FirstDayOfPeriod > J006.Sup_To_Date ,0.0 ,iif(J006.Supplement_Rate is null,0.0,J006.Supplement_Rate)) 'Oxygen_Rate'

			,iif(J001.FirstDayOfPeriod > J002.Sup_To_Date ,0.0 ,iif(J002.Supplement_Rate is null,0.0,J002.Supplement_Rate))
			+iif(J001.FirstDayOfPeriod > J003.Sup_To_Date ,0.0 ,iif(J003.Supplement_Rate is null,0.0,J003.Supplement_Rate))
			+iif(J001.FirstDayOfPeriod > J004.Sup_To_Date ,0.0 ,iif(J004.Supplement_Rate is null,0.0,J004.Supplement_Rate))
			+iif(J001.FirstDayOfPeriod > J005.Sup_To_Date ,0.0 ,iif(J005.Supplement_Rate is null,0.0,J005.Supplement_Rate))
			+iif(J001.FirstDayOfPeriod > J006.Sup_To_Date ,0.0 ,iif(J006.Supplement_Rate is null,0.0,J006.Supplement_Rate))'Sum_Rate'

			,IIF(J007.Client_ID is null,0,1 )'HospInPeriod'
		From 
		(
			select 
				CS.* 
				,DateADD(Day,-1,DATEFROMPARTS(CS.Claim_Year,CS.Period_INT+1,1))'LastDayOfPeriod'
				,DATEFROMPARTS(CS.Claim_Year,CS.Period_INT,1)'FirstDayOfPeriod'
			from @ClaimSum_01 CS
		)J001
		Left outer join
		(
			Select
			*
			From @SubsRate SR
			where SR.FC_Supplement_Type_ID = 5 --Base Subsidy
		)J002 on 
			J001.Client_ID = J002.Client_ID and J001.LastDayOfPeriod between J002.From_Date and iif(J002.To_Date is null, DATEFROMPARTS(2200,01,01),J002.To_Date)
		Left outer join
		(
			Select
			*
			From @SubsRate SR
			where SR.FC_Supplement_Type_ID = 6 --Income Tested
		)J003 on J001.Client_ID = J003.Client_ID and J001.LastDayOfPeriod between J003.From_Date and iif(J003.To_Date is null, DATEFROMPARTS(2200,01,01),J003.To_Date)

		Left outer join
		(
			Select
			*
			From @SubsRate SR
			where SR.FC_Supplement_Type_ID = 9 --Dementia and Cognition and Veterans
		)J004 on J001.Client_ID = J004.Client_ID and J001.LastDayOfPeriod between J004.From_Date and iif(J004.To_Date is null, DATEFROMPARTS(2200,01,01),J004.To_Date)

		Left outer join
		(
			Select
			*
			From @SubsRate SR
			where SR.FC_Supplement_Type_ID = 7 or SR.FC_Supplement_Type_ID = 30 --Financial Hardship
		)J005 on J001.Client_ID = J005.Client_ID and J001.LastDayOfPeriod between J005.From_Date and iif(J005.To_Date is null, DATEFROMPARTS(2200,01,01),J005.To_Date)

		Left outer join
		(
			Select
			*
			From @SubsRate SR
			where SR.FC_Supplement_Type_ID = 1 --Oxygen
		)J006 on J001.Client_ID = J006.Client_ID and J001.LastDayOfPeriod between J006.From_Date and iif(J006.To_Date is null, DATEFROMPARTS(2200,01,01),J006.To_Date)

		Left outer Join @Hosp J007 on J007.Client_ID = J001.Client_ID and 
				(	
					J001.FirstDayOfPeriod Between J007.From_Date and J007.To_Date
					or J001.LastDayOfPeriod Between J007.From_Date and J007.To_Date
					or J007.From_Date Between J001.FirstDayOfPeriod and J001.LastDayOfPeriod
				)
	)T01
)T02

--*/



/* copied from test bed for backup just in case... just befor holliday 19-09-2017

--select * from dbo.FC_Leave_Supplement_Matrix
--select * from dbo.FC_Client_Supplement
--select * from dbo.Hospitalisation

-----------------------------------------------------------------------------------------------

--declare @Client_ID int = 10019215
declare @Client_ID int = 10013840
declare @FiltIncomeTested int = 1
declare @ClaimYear int = 2016
declare @ClaimPeriod_Start int = 6
declare @ClaimPeriod_End int = 11

Declare @FunderContract_ID Table 
(
	Description Varchar(128)
	,Funder_Contract_ID int
)
insert into @FunderContract_ID
select 
	J001.Description
	,J001.Funder_Contract_ID
from dbo.FC_Funder_Contract J001
where 
	J001.Description like 'CHSP %'
	or J001.Description like '% Care at Home'



--select * from @FunderContract_ID

--------------<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<here down

Declare @ClaimSum_01 Table
(
	FunderProgam VarChar(128)
	,Client_ID int
	,ClientName VarChar(128)
	,Claim_Year int
	,Period varchar(8)
	,Actual_Income Dec(10,2)
	,Client_Income Dec(10,2)
	,Adjustment_Claim_Income Dec(10,2)
	,Adjustment_Client_Income Dec(10,2)
	,Claimed_Income Dec(10,2)
	,Eligible_Days int
	,Accumulated_Eligible_Days int
	,Effective_From_Date DateTime
	,Effective_To_Date DateTime
--	,Billing_Start_Date DateTime
--	,Billing_End_Date DateTime
	,Period_INT int
	,Funded_indicator int

)
insert into @ClaimSum_01
select
	J002.Description 'FunderProgam'
	,J001.Client_ID
	,Concat(J006.Last_Name,', ',J006.Preferred_Name)'ClientName'
	,J005.Claim_Year
	,Case 
		when J005.Period = 1 then 'Jan'
		when J005.Period = 2 then 'Feb'
		when J005.Period = 3 then 'Mar'
		when J005.Period = 4 then 'Apr'
		when J005.Period = 5 then 'May'
		when J005.Period = 6 then 'Jun'
		when J005.Period = 7 then 'Jul'
		when J005.Period = 8 then 'Aug'
		when J005.Period = 9 then 'Sep'
		when J005.Period = 10 then 'Oct'
		when J005.Period = 11 then 'Nov'
		when J005.Period = 12 then 'Dec'
		end 'Period'
	,J005.Actual_Income
	,J005.Client_Income
	,J005.Adjustment_Claim_Income
	,J005.Adjustment_Client_Income
	,J005.Claimed_Income
	,J005.Eligible_Days
	,J005.Accumulated_Eligible_Days
	,J001.Effective_From_Date
	,J001.Effective_To_Date
--	,J007.Billing_Start_Date
--	,J007.Billing_End_Date
	,J005.Period 'Period_INT'
	,J001.Funded_Indicator

from dbo.FC_Funder_Contract J002
left outer join dbo.FC_Client_Contract J001 on J002.funder_Contract_ID = J001.funder_Contract_ID
left outer join dbo.FC_Claim_History J005 on J005.Client_Contract_ID = J001.Client_Contract_ID
left outer join dbo.Person J006 on J006.Person_ID = J001.Client_ID
--left outer join dbo.FC_Client_Supplement J007 on J001.Client_Contract_ID = J007.Client_Contract_ID and J007. = J001.Funder_Contract_ID
where
	1=1
	and J001.Client_ID = @Client_ID
--	and J002.Funder_Contract_ID in (@FunderContract_ID)
	and J002.Funder_Contract_ID in (select Funder_Contract_ID from @FunderContract_ID)
	and J005.Claim_Year = @ClaimYear
	and J005.Period between @ClaimPeriod_Start and @ClaimPeriod_end

order by
1,2,4, J005.Period



select Distinct
	J001.Client_ID 'Client_ID'
	,J010.From_Date
	,J010.To_Date
--	,J011.FC_Supplement_Type_ID
--	,J011.Funding_Care_Model_ID
	,J011.Hosp_Reason_Code
	,J011.Supplement_Exceed_Limit_Percentage
From
(
	select 
	CC.* 
	from dbo.FC_Client_Contract CC
	inner join(Select Distinct Client_ID,Effective_From_Date from @ClaimSum_01) CS on CS.Client_ID = CC.Client_ID
	where CC.Effective_To_Date is null
)J001

Left outer Join dbo.FC_Funder_Contract J002	on J002.funder_Contract_ID = J001.funder_Contract_ID
Left outer Join dbo.FC_Funding_Care_Model J003 on J003.Funding_Care_Model_ID = J002.Funding_Care_Model_ID
Left outer join dbo.FC_Account J004 on J004.client_Contract_ID = J001.client_Contract_ID and J004.FC_Account_Type_ID = 1
inner join dbo.FC_Client_Supplement J005 on J005.client_Contract_ID = J004.client_Contract_ID
Left outer join dbo.FC_Supplement_Rate J007 on J007.FC_Supplement_ID = J005.FC_Supplement_ID and J007.Program_Level_ID = J001.Program_Level_ID
left outer join dbo.FC_Supplement J008 on J008.FC_Supplement_ID = J005.FC_Supplement_ID
Left outer join dbo.Hospitalisation J010 on J010.Client_ID = J001.Client_ID
Left outer join dbo.FC_Leave_Supplement_Matrix J011 on J011.Hosp_Reason_Code = J010.Hosp_Reason_Code and J011.Funding_Care_Model_ID = J002.Funding_Care_Model_ID and J011.FC_Supplement_Type_ID = J008.FC_Supplement_Type_ID
Left outer join dbo.FC_Supplement_Type J012 on J012.FC_Supplement_Type_ID = J008.FC_Supplement_Type_ID
where
	J003.Description  = 'Home Care Package'
--	and J002.Funder_Contract_ID in (@FunderContract_ID)
	and J001.Funder_Contract_ID in (select Funder_Contract_ID from @FunderContract_ID)
	and (J007.Effective_To_Date > J001.Effective_From_Date or J007.Effective_To_Date is null)
	and J001.Effective_To_Date is null
	and (J005.Effective_To_Date > J001.Effective_From_Date or J005.Effective_To_Date is null)
	and J011.Effective_To_Date is null
	and J008.FC_Supplement_Type_ID = 5
	and J011.Effective_From_Date is not null

*/