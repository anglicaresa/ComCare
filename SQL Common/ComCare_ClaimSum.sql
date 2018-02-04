--select * from dbo.FC_Client_Supplement where override_Rate is not null
--select distinct Activity_type from FC_Transaction
--select Description from dbo.FC_Transaction_Type
--select * from dbo.FC_Supplement_Type J009 where (J009.FC_Supplement_Type_ID = 5 or J009.FC_Supplement_Type_ID = 6 or J009.FC_Supplement_Type_ID = 7 or J009.FC_Supplement_Type_ID = 9 or J009.FC_Supplement_Type_ID = 30 or J009.FC_Supplement_Type_ID = 1)
--use ComCareProd
--select * from dbo.FC_Client_Contract where client_ID = 10016245 
/*
declare @TransactionType table(Type VarChar(128))

insert into @TransactionType
	select 
		FC_TT1.Description
	from dbo.FC_Transaction_Type FC_TT1 
	where 
	1=1
	and FC_TT1.Description = 'Administrative Overheads'


	Select * from dbo.FB_Client_Contract_Billing where client_ID = 10016245
--*/


--declare @Client_ID int = 10019215
--declare @Client_ID int = 10013840
--declare @Client_ID int = 10021555
--declare @Client_ID int = 10020984
declare @Client_ID int = 10010223

--declare @FiltIncomeTested int = 1
declare @ClaimYear int = 2017
declare @ClaimPeriod_Start int = 12
declare @ClaimPeriod_End int = 12

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
Declare @EndDate Date = iif( @ClaimPeriod_End = 12, DATEFROMPARTS(@ClaimYear,@ClaimPeriod_End,31), DateADD(Day,-1,DATEFROMPARTS(@ClaimYear,@ClaimPeriod_End+1,1)))

Declare @SupIDs table ( SupID int)
insert into @SupIDs values 
	(5) --Base Subsidy
	,(6) --Income Tested
	,(7) --Financial Hardship (Billing Linked)
	,(9) --Dementia and Cognition and Veterans
	,(30) --Financial Hardship
	,(1) --Oxygen
	,(36) --Means Tested
	,(31) --Client Contribution 50% Reduction
	,(32)--Client Contribution 100% Reduction
	,(33)--Client Contribution 25% Reduction
	,(34)--Client Contribution 75% Reduction
	,(35)--Client contribution 0% Reduction
--select * from @SupIDs

Declare @ClaimSum_01 Table
(
	FunderProgram VarChar(128)
	,Client_ID int
	,ClientName VarChar(128)
	,Claim_Year int
	,Period varchar(8)
	,Client_Contract_ID int
	,Funder_Contract_ID int
	,Funding_Care_Model_ID int
	,Actual_Income Dec(10,2)
	,Client_Income Dec(10,2)
	,Adjustment_Claim_Income Dec(10,2)
	,Adjustment_Client_Income Dec(10,2)
	,Claimed_Income Dec(10,2)
	,Eligible_Days int
	,Accumulated_Eligible_Days int
	,Effective_From_Date DateTime
	,Effective_To_Date DateTime
	,Period_INT int
	,Funded_indicator int
	,LevelOfCare int
	,LastDayOfPeriod Date
	,FirstDayOfPeriod Date
)
insert into @ClaimSum_01
select
	J002.Description 'FunderProgram'
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
	,J001.Client_Contract_ID
	,J001.Funder_Contract_ID
	,J002.Funding_Care_Model_ID
	,J005.Actual_Income
	,J005.Client_Income
	,J005.Adjustment_Claim_Income
	,J005.Adjustment_Client_Income
	,J005.Claimed_Income
	,J005.Eligible_Days
	,J005.Accumulated_Eligible_Days
	,J001.Effective_From_Date
	,J001.Effective_To_Date
	,J005.Period 'Period_INT'
	,J001.Funded_Indicator
	,J001.Program_Level_ID 'LevelOfCare'
	,iif(J005.Period = 12 ,DATEFROMPARTS(J005.Claim_Year,J005.Period,31),DateADD(Day,-1,DATEFROMPARTS(J005.Claim_Year,J005.Period+1,1)))'LastDayOfPeriod'
	,DATEFROMPARTS(J005.Claim_Year,J005.Period,1)'FirstDayOfPeriod'
	--,J005.

from dbo.FC_Funder_Contract J002
left outer join dbo.FC_Client_Contract J001 on J002.funder_Contract_ID = J001.funder_Contract_ID
left outer join dbo.FC_Claim_History J005 on J005.Client_Contract_ID = J001.Client_Contract_ID
left outer join dbo.Person J006 on J006.Person_ID = J001.Client_ID

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
	,FunderProgram VarChar(128)
	,Description VarChar(64)
	,FC_Supplement_Type_ID int
	,Supplement_Rate Dec(10,2)
	,From_Date Datetime
	,To_Date DateTime
	,LevelOfCare int
	,Sup_From_Date DateTime
	,Sup_To_Date DateTime
	,Last_Modified_Date DateTime
	,Last_mod_Type VarChar(32)
)
insert into @SubsRate

select distinct
	J001.Client_ID 'Client_ID'
	,J001.FunderProgram
	,J009.Description
	,cast(J009.FC_Supplement_Type_ID as int)'FC_Supplement_Type_ID'
	,cast(iif(J009.Affect_Funder_Claim = '&','+',J009.Affect_Funder_Claim) + cast(iif(J005.Override_Rate is null, J007.Supplement_Rate,J005.Override_Rate)as Varchar(16))as decimal(10,2))'Supplement_Rate'
	,iif(J005.Override_Rate is null, J007.Effective_From_Date,J005.Effective_From_Date)'From_Date'
	,iif(J005.Override_Rate is null, J007.Effective_To_Date,J005.Effective_To_Date)'To_Date'
	,J007.Program_Level_ID 'LevelOfCare'
	,J005.Effective_From_Date 'Sup_From_Date'
	,J005.Effective_To_Date 'Sup_To_Date'
	,iif(J005.Last_Modified_Date is null,J005.Creation_Date,J005.Last_Modified_Date)'Last_Modified_Date'
	,iif(J005.Last_Modified_Date is null,'Creation_Date','Last_Modified_Date')'Last_Modified_Date'

From @ClaimSum_01 J001
Left outer Join dbo.FC_Funding_Care_Model J003 on J003.Funding_Care_Model_ID = J001.Funding_Care_Model_ID
Left outer join dbo.FC_Account J004 on J004.client_Contract_ID = J001.client_Contract_ID and J004.FC_Account_Type_ID = 1
inner join dbo.FC_Client_Supplement J005 on J005.client_Contract_ID = J001.client_Contract_ID 
inner join dbo.FC_Supplement_Rate J007 on J007.FC_Supplement_ID = J005.FC_Supplement_ID and J007.Program_Level_ID = J001.LevelOfCare
left outer join dbo.FC_Supplement J008 on J008.FC_Supplement_ID = J005.FC_Supplement_ID
left outer join dbo.FC_Supplement_Type J009 on J009.FC_Supplement_Type_ID = J008.FC_Supplement_Type_ID and J009.Effective_To_Date is null
/*
select * from dbo.FC_Client_Supplement where override_rate is not null
select * from dbo.FC_Supplement_Type
*/

where
	J003.Description  = 'Home Care Package'
--	and J001.Funder_Contract_ID in (@FunderContract_ID)
	and J001.Funder_Contract_ID in (select Funder_Contract_ID from @FunderContract_ID)
	and (J007.Effective_To_Date > J001.Effective_From_Date or J007.Effective_To_Date is null)
	and (J005.Effective_To_Date > J001.Effective_From_Date or J005.Effective_To_Date is null)
	and (J005.Effective_From_Date < iif (J001.Effective_To_Date is null, DATEFROMPARTS(2200,01,01) ,J001.Effective_To_Date))
	and (cast(J009.FC_Supplement_Type_ID as int) in (select * from @SupIDs))

order by 1,3,4

--select * from @SubsRate
-----------------------------------------------------------------------------------------------------------------------------
--/*
Declare @Hosp Table
(
	Client_ID int
	,Period_INT int
)
insert into @Hosp

select Distinct
	J001.Client_ID
	,J001.Period_INT
From @ClaimSum_01 J001
left outer join
(
	Select
	CS.Client_ID
	,CS.Period_INT
	,ROW_NUMBER()over(Partition by CS.Client_ID,CS.Period_INT order by hos.From_Date)'RN'
	,hos.From_Date
	,hos.To_Date
	from dbo.Hospitalisation hos
	inner join @ClaimSum_01 CS on CS.Client_ID = hos.Client_ID and 
		(	
			CS.FirstDayOfPeriod Between hos.From_Date and iif(hos.To_Date is null, DATEFROMPARTS(2200,01,01),hos.To_Date)
			or CS.LastDayOfPeriod Between hos.From_Date and iif(hos.To_Date is null, DATEFROMPARTS(2200,01,01),hos.To_Date)
			or hos.From_Date Between CS.FirstDayOfPeriod and CS.LastDayOfPeriod
		)
	where
	1=1
)J002 on J002.Client_ID = J001.Client_ID and J002.Period_INT = J001.Period_INT
where
	1=1
	and J002.RN = 1

--select * from @Hosp
-----------------------------------------------------------------------------------------------------------------------------
--/* Need to handle the vairous dates for rate changes. done
Select-- distinct
	T02.*
	,Cast(T02.BaseSubsidy_Rate * T02.RateMult as decimal(12,4)) 'Cal_BaseSubsidy'
	,Cast(T02.IncomeTested_Rate * T02.RateMult as decimal(12,4)) 'Cal_IncomeTested'
	,Cast(T02.MeansTested_Rate * T02.RateMult as decimal(12,4)) 'Cal_MeansTested'
	,Cast(
			(
				T02.CC_0_Rate + T02.CC_100_Rate + T02.CC_25_Rate + T02.CC_50_Rate + T02.CC_75_Rate
			) * T02.RateMult as decimal(12,4)) 'Cal_ClientContribution'
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
			,J002.Last_Modified_Date 'BaseSubsidy_Rate_ModDate'
			,iif(J001.FirstDayOfPeriod > J003.Sup_To_Date ,0.0 ,iif(J003.Supplement_Rate is null,0.0,J003.Supplement_Rate)) 'IncomeTested_Rate'
			,J003.Last_Modified_Date 'IncomeTested_Rate_ModDate'

			,iif(J001.FirstDayOfPeriod > J008.Sup_To_Date ,0.0 ,iif(J008.Supplement_Rate is null,0.0,J008.Supplement_Rate)) 'MeansTested_Rate'
			,J008.Last_Modified_Date 'MeansTested_Rate_ModDate'

			,iif(J001.FirstDayOfPeriod > J009.Sup_To_Date ,0.0 ,iif(J009.Supplement_Rate is null,0.0,J009.Supplement_Rate)) 'CC_50_Rate'
			,J009.Last_Modified_Date 'CC_50_Rate_ModDate'
			,iif(J001.FirstDayOfPeriod > J010.Sup_To_Date ,0.0 ,iif(J010.Supplement_Rate is null,0.0,J010.Supplement_Rate)) 'CC_100_Rate'
			,J010.Last_Modified_Date 'CC_100_Rate_ModDate'
			,iif(J001.FirstDayOfPeriod > J011.Sup_To_Date ,0.0 ,iif(J011.Supplement_Rate is null,0.0,J011.Supplement_Rate)) 'CC_75_Rate'
			,J011.Last_Modified_Date 'CC_75_Rate_ModDate'
			,iif(J001.FirstDayOfPeriod > J012.Sup_To_Date ,0.0 ,iif(J012.Supplement_Rate is null,0.0,J012.Supplement_Rate)) 'CC_25_Rate'
			,J012.Last_Modified_Date 'CC_25_Rate_ModDate'
			,iif(J001.FirstDayOfPeriod > J013.Sup_To_Date ,0.0 ,iif(J013.Supplement_Rate is null,0.0,J013.Supplement_Rate)) 'CC_0_Rate'
			,J013.Last_Modified_Date 'CC_0_Rate_ModDate'
			,iif(J001.FirstDayOfPeriod > J004.Sup_To_Date ,0.0 ,iif(J004.Supplement_Rate is null,0.0,J004.Supplement_Rate)) 'Dementia_Veterans_Rate'
			,J004.Last_Modified_Date 'Dementia_Veterans_Rate_ModDate'
			,iif(J001.FirstDayOfPeriod > J005.Sup_To_Date ,0.0 ,iif(J005.Supplement_Rate is null,0.0,J005.Supplement_Rate)) 'Financial_Hardship_Rate'
			,J005.Last_Modified_Date 'Financial_Hardship_Rate_ModDate'
			,iif(J001.FirstDayOfPeriod > J006.Sup_To_Date ,0.0 ,iif(J006.Supplement_Rate is null,0.0,J006.Supplement_Rate)) 'Oxygen_Rate'
			,J006.Last_Modified_Date 'Oxygen_Rate_ModDate'

			,iif(J001.FirstDayOfPeriod > J002.Sup_To_Date ,0.0 ,iif(J002.Supplement_Rate is null,0.0,J002.Supplement_Rate))
			+iif(J001.FirstDayOfPeriod > J003.Sup_To_Date ,0.0 ,iif(J003.Supplement_Rate is null,0.0,J003.Supplement_Rate))
			+iif(J001.FirstDayOfPeriod > J008.Sup_To_Date ,0.0 ,iif(J008.Supplement_Rate is null,0.0,J008.Supplement_Rate))
			+iif(J001.FirstDayOfPeriod > J009.Sup_To_Date ,0.0 ,iif(J009.Supplement_Rate is null,0.0,J009.Supplement_Rate))
			+iif(J001.FirstDayOfPeriod > J010.Sup_To_Date ,0.0 ,iif(J010.Supplement_Rate is null,0.0,J010.Supplement_Rate))
			+iif(J001.FirstDayOfPeriod > J011.Sup_To_Date ,0.0 ,iif(J011.Supplement_Rate is null,0.0,J011.Supplement_Rate))
			+iif(J001.FirstDayOfPeriod > J012.Sup_To_Date ,0.0 ,iif(J012.Supplement_Rate is null,0.0,J012.Supplement_Rate))
			+iif(J001.FirstDayOfPeriod > J013.Sup_To_Date ,0.0 ,iif(J013.Supplement_Rate is null,0.0,J013.Supplement_Rate))
			+iif(J001.FirstDayOfPeriod > J004.Sup_To_Date ,0.0 ,iif(J004.Supplement_Rate is null,0.0,J004.Supplement_Rate))
			+iif(J001.FirstDayOfPeriod > J005.Sup_To_Date ,0.0 ,iif(J005.Supplement_Rate is null,0.0,J005.Supplement_Rate))
			+iif(J001.FirstDayOfPeriod > J006.Sup_To_Date ,0.0 ,iif(J006.Supplement_Rate is null,0.0,J006.Supplement_Rate))'Sum_Rate'

			,IIF(J007.Client_ID is null,0,1 )'HospInPeriod'
		From 
		(
			select 
				CS.* 
			from @ClaimSum_01 CS
		)J001
		Left outer join
		(
			Select
			*
			From @SubsRate SR
			where SR.FC_Supplement_Type_ID = 5 --Base Subsidy
		)J002 on 
			J001.Client_ID = J002.Client_ID 
			and J001.FunderProgram = J002.FunderProgram
			and J001.LevelOfCare = J002.LevelOfCare
			and J001.LastDayOfPeriod between J002.From_Date and iif(J002.To_Date is null, DATEFROMPARTS(2200,01,01),J002.To_Date)
		Left outer join
		(
			Select
			*
			From @SubsRate SR
			where SR.FC_Supplement_Type_ID = 6 --Income Tested
		)J003 on 
			J001.Client_ID = J003.Client_ID 
			and J001.FunderProgram = J003.FunderProgram
			and J001.LevelOfCare = J003.LevelOfCare
			and J001.LastDayOfPeriod between J003.From_Date and iif(J003.To_Date is null, DATEFROMPARTS(2200,01,01),J003.To_Date)

		Left outer join
		(
			Select
			*
			From @SubsRate SR
			where SR.FC_Supplement_Type_ID = 9 --Dementia and Cognition and Veterans
		)J004 on 
			J001.Client_ID = J004.Client_ID
			and J001.FunderProgram = J004.FunderProgram
			and J001.LevelOfCare = J004.LevelOfCare 
			and J001.LastDayOfPeriod between J004.From_Date and iif(J004.To_Date is null, DATEFROMPARTS(2200,01,01),J004.To_Date)

		Left outer join
		(
			Select
			*
			From @SubsRate SR
			where SR.FC_Supplement_Type_ID = 7 or SR.FC_Supplement_Type_ID = 30 --Financial Hardship
		)J005 on 
			J001.Client_ID = J005.Client_ID 
			and J001.FunderProgram = J005.FunderProgram
			and J001.LevelOfCare = J005.LevelOfCare
			and J001.LastDayOfPeriod between J005.From_Date and iif(J005.To_Date is null, DATEFROMPARTS(2200,01,01),J005.To_Date)

		Left outer join
		(
			Select
			*
			From @SubsRate SR
			where SR.FC_Supplement_Type_ID = 1 --Oxygen
		)J006 on 
			J001.Client_ID = J006.Client_ID 
			and J001.FunderProgram = J006.FunderProgram
			and J001.LevelOfCare = J006.LevelOfCare
			and J001.LastDayOfPeriod between J006.From_Date and iif(J006.To_Date is null, DATEFROMPARTS(2200,01,01),J006.To_Date)

		Left outer join
		(
			Select
			*
			From @SubsRate SR
			where SR.FC_Supplement_Type_ID = 36 --Means Tested
		)J008 on 
			J001.Client_ID = J008.Client_ID 
			and J001.FunderProgram = J008.FunderProgram
			and J001.LevelOfCare = J008.LevelOfCare
			and J001.LastDayOfPeriod between J008.From_Date and iif(J008.To_Date is null, DATEFROMPARTS(2200,01,01),J008.To_Date)

		Left outer join
		(
			Select
			*
			From @SubsRate SR
			where SR.FC_Supplement_Type_ID = 31 --Client Contribution 50% Reduction
		)J009 on 
			J001.Client_ID = J009.Client_ID 
			and J001.FunderProgram = J009.FunderProgram
			and J001.LevelOfCare = J009.LevelOfCare
			and J001.LastDayOfPeriod between J009.From_Date and iif(J009.To_Date is null, DATEFROMPARTS(2200,01,01),J009.To_Date)

		Left outer join
		(
			Select
			*
			From @SubsRate SR
			where SR.FC_Supplement_Type_ID = 32 --Client Contribution 100% Reduction
		)J010 on 
			J001.Client_ID = J010.Client_ID 
			and J001.FunderProgram = J010.FunderProgram
			and J001.LevelOfCare = J010.LevelOfCare
			and J001.LastDayOfPeriod between J010.From_Date and iif(J010.To_Date is null, DATEFROMPARTS(2200,01,01),J010.To_Date)
		
		Left outer join
		(
			Select
			*
			From @SubsRate SR
			where SR.FC_Supplement_Type_ID = 33 --Client Contribution 25% Reduction
		)J011 on 
			J001.Client_ID = J011.Client_ID 
			and J001.FunderProgram = J011.FunderProgram
			and J001.LevelOfCare = J011.LevelOfCare
			and J001.LastDayOfPeriod between J011.From_Date and iif(J011.To_Date is null, DATEFROMPARTS(2200,01,01),J011.To_Date)

		Left outer join
		(
			Select
			*
			From @SubsRate SR
			where SR.FC_Supplement_Type_ID = 34 --Client Contribution 75% Reduction
		)J012 on 
			J001.Client_ID = J012.Client_ID 
			and J001.FunderProgram = J012.FunderProgram
			and J001.LevelOfCare = J012.LevelOfCare
			and J001.LastDayOfPeriod between J012.From_Date and iif(J012.To_Date is null, DATEFROMPARTS(2200,01,01),J012.To_Date)

		Left outer join
		(
			Select
			*
			From @SubsRate SR
			where SR.FC_Supplement_Type_ID = 35 --Client Contribution 0% Reduction
		)J013 on 
			J001.Client_ID = J013.Client_ID 
			and J001.FunderProgram = J013.FunderProgram
			and J001.LevelOfCare = J013.LevelOfCare
			and J001.LastDayOfPeriod between J013.From_Date and iif(J013.To_Date is null, DATEFROMPARTS(2200,01,01),J013.To_Date)

		Left outer Join @Hosp J007 on J007.Client_ID = J001.Client_ID and J007.Period_INT = J001.Period_INT

	)T01
)T02
--*/
--*/


