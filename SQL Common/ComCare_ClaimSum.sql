
--select distinct Activity_type from FC_Transaction
--select Description from dbo.FC_Transaction_Type
--use ComCareProd
--/*
declare @TransactionType table(Type VarChar(128))

insert into @TransactionType
	select 
		FC_TT1.Description
	from dbo.FC_Transaction_Type FC_TT1 
	where 
	1=1
	and FC_TT1.Description = 'Administrative Overheads'
--*/


declare @Client_ID int = 10001600
declare @FiltIncomeTested int = 1
declare @ClaimYear int = 2017
declare @ClaimPeriod_Start int = 1
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
from [dbo].FC_Funder_Contract J001
where 
	J001.Description like 'CHSP %'
	or J001.Description like '% Care at Home'

--select * from @FunderContract_ID

--------------<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<here down
select --distinct
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
--	,J005.Claimed_Income
	,J005.Client_Income
from [dbo].FC_Funder_Contract J002
left outer join [dbo].FC_Client_Contract J001 on J002.funder_Contract_ID = J001.funder_Contract_ID
left outer join dbo.FC_Claim_History J005 on J005.Client_Contract_ID = J001.Client_Contract_ID

left outer join dbo.Person J006 on J006.Person_ID = J001.Client_ID
where
	1=1
--	and J001.Client_ID = @Client_ID
--	and J005.Transaction_Type in (@TransactionType)
--	and J005.Transaction_Type in (select * from @TransactionType)


--	and J002.Funder_Contract_ID in (@FunderContract_ID)
	and J002.Funder_Contract_ID in (select Funder_Contract_ID from @FunderContract_ID)
	and J005.Claim_Year = @ClaimYear
	and J005.Period between @ClaimPeriod_Start and @ClaimPeriod_end


--	
--/*
order by
1,2,4, J005.Period

--*/