declare @stringDate varchar(32) = '2017-04-17'
declare @stringDate2 varchar(32) = '2017-04-17'--'2017-01-20'
declare @Start_Date date = convert(date, @stringDate)
declare @End_Date date = convert(date, @stringDate2)
declare @Centre varchar(32) = 'Dutton Court'
declare @ShowVacantOnly int = 0
declare @NoBuddyShifts int = 1
declare @hideUnAss int = 1
declare @ClassCodeFilter VarChar(8)= 'HW'
declare @TeamFilt VarChar(128) = 'Buddy Team'
declare @SortBy VarChar(32) = 'StartTime'


declare @date_Start date = @Start_Date
declare @date_End date = @End_Date

--Create DateRange and set start of week
SET DATEFIRST 1
declare @temp table 
(
	date_seq date
	,Day_of_week int
)

while @date_Start <= @date_End

begin
	insert into @temp values (@date_Start, DATEPART(dw,@date_Start))
	 set @date_Start = DATEADD(dd, 1, @date_Start)
end
select * from @temp
	Select
		PA.Provider_ID 'Provider_ID'
		,PA.Service_Prov_Position_ID 'Service_Prov_Position_ID'
		,PA.From_Date 'From_Date'
		,PA.To_Date 'To_Date'
		,PA.Working_Week_No_Exception 'Working_Week_No'
		,W_W.StartTime 'StartTime'
		,W_W.duration 'duration'
		,W_W.date_seq 'activity_Date'
	from dbo.Position_Allocation PA
	Left outer join
	(
		select
			tmp.[date_seq] as 'date_seq'
			,WW.[Working_Week_No] as 'Working_Week_No'
			,Case
				when tmp.[Day_of_week] = 1 then WW.[Monday_Duration]
				when tmp.[Day_of_week] = 2 then WW.[Tuesday_Duration]
				when tmp.[Day_of_week] = 3 then WW.[Wednesday_Duration]
				when tmp.[Day_of_week] = 4 then WW.[Thursday_Duration]
				when tmp.[Day_of_week] = 5 then WW.[Friday_Duration]
				when tmp.[Day_of_week] = 6 then WW.[Saturday_Duration]
				when tmp.[Day_of_week] = 7 then WW.[Sunday_Duration]
			end as 'duration'
			,Case
				when tmp.[Day_of_week] = 1 then WW.[Monday_Start]
				when tmp.[Day_of_week] = 2 then WW.[Tuesday_Start]
				when tmp.[Day_of_week] = 3 then WW.[Wednesday_Start]
				when tmp.[Day_of_week] = 4 then WW.[Thursday_Start]
				when tmp.[Day_of_week] = 5 then WW.[Friday_Start]
				when tmp.[Day_of_week] = 6 then WW.[Saturday_Start]
				when tmp.[Day_of_week] = 7 then WW.[Sunday_Start]
			end as 'StartTime'
			,Case
				when tmp.[Day_of_week] = 1 then 'Monday'
				when tmp.[Day_of_week] = 2 then 'Tuesday'
				when tmp.[Day_of_week] = 3 then 'Wednesday'
				when tmp.[Day_of_week] = 4 then 'Thursday'
				when tmp.[Day_of_week] = 5 then 'Friday'
				when tmp.[Day_of_week] = 6 then 'Saturday'
				when tmp.[Day_of_week] = 7 then 'Sunday'
			end as 'DayOfWeek'

		From [dbo].[Working_Week] WW	
		left outer join @temp tmp on 1=1 

	)W_W on W_W.[Working_Week_No] = PA.Working_Week_No_Exception and PA.Working_Week_No_Exception is NOT NULL

where
1=1
and W_W.duration is not null
and PA.Provider_id = 10049327
and W_W.date_seq = cast('2017-04-17 00:00:00.000' as date)
and PA.Service_Prov_Position_ID = 348
and PA.Working_Week_No_Exception = 31635
/*
group by
	PA.Provider_ID
	,PA.Service_Prov_Position_ID
	,PA.From_Date
	,PA.To_Date
	,PA.Working_Week_No_Exception
	,W_W.StartTime
	,W_W.duration
*/
SET DATEFIRST 7
