USE [ASADWH]
GO
/****** Object:  StoredProcedure [dbo].[p_vacent_shift]    Script Date: 11/01/2017 4:25:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[p_vacent_shift] @Start_Time datetime, @end_Time datetime, @RAC_Site int
as
begin
--Parameter For Period Range
declare @start datetime 
set @start = @Start_Time
declare @end   datetime 
set @end = @end_Time

--Parameter for Site
declare @teamNo int
set @teamNo =@RAC_Site

declare @ProviderClass nvarchar(15) 


--Parameter for Start Round Code
declare @start_roundcode varchar(15) 
set @start_roundcode = 'PCW-RES-DC7D2-1'

--Create Table for temp table
declare @TempTable table 
(
date DATETIME,
roundcode varchar(17),
Day_of_week char(20),
Provider_Class_Code char(5),
Team_Name char(20),
Monday_Start datetime,
Monday_Duration decimal(4, 2), 
Tuesday_Start datetime,
Tuesday_Duration decimal(4, 2), 
Wednesday_Start datetime,
Wednesday_Duration decimal(4, 2), 
Thursday_Start datetime,
Thursday_Duration decimal(4, 2), 
Friday_Start datetime,
Friday_Duration decimal(4, 2), 
Saturday_Start datetime,
Saturday_Duration decimal(4, 2), 
Sunday_Start datetime,
Sunday_duration decimal(4, 2),
Start_Time varchar(10),
End_Time varchar(10)

)
--Create Varables for temp table
DECLARE
  @basedate DATETIME,
  @roundcode VARCHAR(17),
  @offset   INT,
  @day_Name char(20),
  @Provider_Class_Code char(5),
  @Team_Name char(20),
  @temp_Monday_Start datetime,
  @temp_Monday_Duration decimal(4, 2), 
  @temp_Tuesday_Start datetime,
  @temp_Tuesday_Duration decimal(4, 2), 
  @temp_Wednesday_Start datetime,
  @temp_Wednesday_Duration decimal(4, 2),
  @temp_Thursday_Start datetime,
  @temp_Thursday_Duration decimal(4, 2),
  @temp_Friday_Start datetime,
  @temp_Friday_Duration decimal(4, 2),
  @temp_Saturday_Start datetime,
  @temp_Saturday_Duration decimal(4, 2),
  @temp_Sunday_Start datetime,
  @temp_Sunday_Duration decimal(4, 2),
  @temp_Start_Time varchar(10),
  @temp_End_Time varchar(10)

--set vareables to default
SELECT
  @basedate = @start,
  @Day_name = DATENAME ( weekday , @basedate )  ,
  @offset = 1,
  @temp_Monday_Start= @start, 
  @temp_Monday_Duration=0,
  @temp_Tuesday_Start=@start,
  @temp_Tuesday_Duration=0,
  @temp_Wednesday_Start=@start,
  @temp_Wednesday_Duration= 0,
  @temp_Thursday_Start= @start,
  @temp_Thursday_Duration=0,
  @temp_Friday_Start=@start,
  @temp_Friday_Duration=0,
  @temp_Saturday_Start=@start,
  @temp_Saturday_Duration=0,
  @temp_Sunday_Start=@start,
  @temp_Sunday_Duration=0,
  @temp_Start_Time='',
  @temp_End_Time=''

-- Create Cursor for round code and data into Temp Table
DECLARE c_Round CURSOR FOR 
SELECT 
t1.Generated_Provider_Code, 
t1.Provider_Class_Code, 
t4.Description,
t3.Monday_Start ,
t3.Monday_Duration,
t3.Tuesday_Start,
t3.Tuesday_Duration,
t3.Wednesday_Start,
t3.Wednesday_Duration,
t3.Thursday_Start,
t3.Thursday_Duration,
t3.Friday_start,
t3.Friday_Duration,
t3.Saturday_Start,
t3.Saturday_duration,
t3.Sunday_Start,
t3.Sunday_Duration,
--Get Start Time
(
	case  
	when  t3.Monday_Duration is not null 
	then max
		( 
			convert(varchar, datepart(hour,t3.Monday_Start)) + ':' +
				case len(convert(varchar,datepart(minute,t3.Monday_Start ))) 
					when 1 
					then convert(varchar,datepart(minute,t3.Monday_Start ))+'0' 
					else convert(varchar,datepart(minute,t3.Monday_Start)) 
				end )
	else (
			case 
			when t3.Tuesday_Duration is not null 
			then  max( convert(varchar, datepart(hour,t3.Tuesday_Start)) + ':' +
				case len(convert(varchar,datepart(minute,t3.Tuesday_Start))) 
					when 1 
					then convert(varchar,datepart(minute,t3.Tuesday_Start))+'0' 
					else convert(varchar,datepart(minute,t3.Tuesday_Start)) 
				end )
					else (
							case 
							when t3.Wednesday_Duration is not null 
							then  max( convert(varchar, datepart(hour,t3.Wednesday_Start)) + ':' +
								case len(convert(varchar,datepart(minute,t3.Wednesday_Start))) 
									when 1 
									then convert(varchar,datepart(minute,t3.Wednesday_Start))+'0' 
									else convert(varchar,datepart(minute,t3.Wednesday_Start)) 
								end )
							else 	
									(case 
										when t3.Thursday_Duration is not null 
										then  max( convert(varchar, datepart(hour,t3.Thursday_Start)) + ':' +
											case len(convert(varchar,datepart(minute,t3.Thursday_Start))) 
												when 1 
												then convert(varchar,datepart(minute,t3.Thursday_Start))+'0' 
												else convert(varchar,datepart(minute,t3.Thursday_Start)) 
											end )
										else 
													(case 
														when t3.Friday_Duration is not null 
														then  max( convert(varchar, datepart(hour,t3.Friday_Start)) + ':' +
															case len(convert(varchar,datepart(minute,t3.Friday_Start))) 
																when 1 
																then convert(varchar,datepart(minute,t3.Friday_Start))+'0' 
																else convert(varchar,datepart(minute,t3.Friday_Start)) 
															end )
														else 
																	(case 
																		when t3.Saturday_Duration is not null 
																		then  max( convert(varchar, datepart(hour,t3.Saturday_Start)) + ':' +
																			case len(convert(varchar,datepart(minute,t3.Saturday_Start))) 
																				when 1 
																				then convert(varchar,datepart(minute,t3.Saturday_Start))+'0' 
																				else convert(varchar,datepart(minute,t3.Saturday_Start)) 
																			end )
																		else 
																				(case 
																					when t3.Sunday_Duration is not null 
																					then  max( convert(varchar, datepart(hour,t3.Sunday_Start)) + ':' +
																						case len(convert(varchar,datepart(minute,t3.Sunday_Start))) 
																							when 1 
																							then convert(varchar,datepart(minute,t3.Sunday_Start))+'0' 
																							else convert(varchar,datepart(minute,t3.Sunday_Start)) 
																						end )
																					else ''
																					end) 
																		end) 
														end) 

										end) 
							
							end)
			end)
	end		
) as Start_Time,
--Get End Time
(case  
when  t3.Monday_Duration is not null 
then max( convert(varchar,datepart(hour, dateadd(minute, (t3.Monday_Duration*60), t3.Monday_Start)))+ ':' + 
			case len(convert(varchar,datepart(minute, dateadd(minute, (t3.Monday_Duration*60), t3.Monday_Start)))) 
				when 1 
				then convert(varchar,datepart(minute, dateadd(minute, (t3.Monday_Duration*60), t3.Monday_Start)))+'0'
				else convert(varchar,datepart(minute, dateadd(minute, (t3.Monday_Duration*60), t3.Monday_Start))) 
			end)
else 
			(case  
				when  t3.Tuesday_Duration is not null 
				then max( convert(varchar,datepart(hour, dateadd(minute, (t3.Tuesday_Duration*60), t3.Tuesday_Start)))+ ':' + 
							case len(convert(varchar,datepart(minute, dateadd(minute, (t3.Tuesday_Duration*60), t3.Tuesday_Start)))) 
								when 1 
								then convert(varchar,datepart(minute, dateadd(minute, (t3.Tuesday_Duration*60), t3.Tuesday_Start)))+'0'
								else convert(varchar,datepart(minute, dateadd(minute, (t3.Tuesday_Duration*60), t3.Tuesday_Start))) 
							end)
				else 
						(case  
							when  t3.Wednesday_Duration is not null 
							then max( convert(varchar,datepart(hour, dateadd(minute, (t3.Wednesday_Duration*60), t3.Wednesday_Start)))+ ':' + 
										case len(convert(varchar,datepart(minute, dateadd(minute, (t3.Wednesday_Duration*60), t3.Wednesday_Start)))) 
											when 1 
											then convert(varchar,datepart(minute, dateadd(minute, (t3.Wednesday_Duration*60), t3.Wednesday_Start)))+'0'
											else convert(varchar,datepart(minute, dateadd(minute, (t3.Wednesday_Duration*60), t3.Wednesday_Start))) 
										end)
							else 
									(case  
										when  t3.Thursday_Duration is not null 
										then max( convert(varchar,datepart(hour, dateadd(minute, (t3.Thursday_Duration*60), t3.Thursday_Start)))+ ':' + 
													case len(convert(varchar,datepart(minute, dateadd(minute, (t3.Thursday_Duration*60), t3.Thursday_Start)))) 
														when 1 
														then convert(varchar,datepart(minute, dateadd(minute, (t3.Thursday_Duration*60), t3.Thursday_Start)))+'0'
														else convert(varchar,datepart(minute, dateadd(minute, (t3.Thursday_Duration*60), t3.Thursday_Start))) 
													end)
										else 
												(case  
													when  t3.Friday_Duration is not null 
													then max( convert(varchar,datepart(hour, dateadd(minute, (t3.Friday_Duration*60), t3.Friday_Start)))+ ':' + 
																case len(convert(varchar,datepart(minute, dateadd(minute, (t3.Friday_Duration*60), t3.Friday_Start)))) 
																	when 1 
																	then convert(varchar,datepart(minute, dateadd(minute, (t3.Friday_Duration*60), t3.Friday_Start)))+'0'
																	else convert(varchar,datepart(minute, dateadd(minute, (t3.Friday_Duration*60), t3.Friday_Start))) 
																end)
													else 
															(case  
																when  t3.Saturday_Duration is not null 
																then max( convert(varchar,datepart(hour, dateadd(minute, (t3.Saturday_Duration*60), t3.Saturday_Start)))+ ':' + 
																			case len(convert(varchar,datepart(minute, dateadd(minute, (t3.Saturday_Duration*60), t3.Saturday_Start)))) 
																				when 1 
																				then convert(varchar,datepart(minute, dateadd(minute, (t3.Saturday_Duration*60), t3.Saturday_Start)))+'0'
																				else convert(varchar,datepart(minute, dateadd(minute, (t3.Saturday_Duration*60), t3.Saturday_Start))) 
																			end)
																else 
																		(case  
																			when  t3.Sunday_Duration is not null 
																			then max( convert(varchar,datepart(hour, dateadd(minute, (t3.Sunday_Duration*60), t3.Sunday_Start)))+ ':' + 
																						case len(convert(varchar,datepart(minute, dateadd(minute, (t3.Sunday_Duration*60), t3.Sunday_Start)))) 
																							when 1 
																							then convert(varchar,datepart(minute, dateadd(minute, (t3.Sunday_Duration*60), t3.Sunday_Start)))+'0'
																							else convert(varchar,datepart(minute, dateadd(minute, (t3.Sunday_Duration*60), t3.Sunday_Start))) 
																						end)
																			else ''
																			end)
																end)
													end)
										end)
							end)
				end)
end) as End_Time

 from [appsql-3\comcareprod].[comcareprod].dbo.Service_Provision_Position as t1
inner join
[appsql-3\comcareprod].[comcareprod].dbo.Service_Provision_Allocation as t2
ON t1.Service_Prov_Position_ID=t2.Service_Prov_Position_ID
join [appsql-3\comcareprod].[comcareprod].dbo.Working_Week as t3
ON t2.Working_Week_No=t3.Working_Week_No
join [appsql-3\comcareprod].[comcareprod].dbo.Service_Delivery_Work_Team as t4
ON t1.Centre_ID=t4.Centre_ID and t1.Team_No= t4.Team_No
where t1.Centre_ID=@teamNo and t1.position_Closed_date is null ---------------------------------------could be a problem.AR
Group by t1.Generated_Provider_Code, t1.Provider_Class_Code, t4.Description, t3.Monday_Start , t3.Monday_Duration, t3.Tuesday_Start, t3.Tuesday_Duration, t3.Wednesday_Start, t3.Wednesday_Duration, t3.Thursday_Start, t3.Thursday_Duration, t3.Friday_start, t3.Friday_Duration, t3.Saturday_Start, t3.Saturday_duration, t3.Sunday_Start, t3.Sunday_Duration


 
 
  open c_Round;
  FETCH NEXT FROM c_Round INTO @roundcode, @Provider_Class_Code, @Team_Name,  @temp_Monday_Start, @temp_Monday_Duration, @temp_Tuesday_Start, @temp_Tuesday_Duration, @temp_Wednesday_Start, @temp_Wednesday_Duration, @temp_Thursday_Start , @temp_Thursday_Duration, @temp_Friday_Start, @temp_Friday_Duration,@temp_Saturday_Start,@temp_Saturday_Duration,@temp_Sunday_Start,@temp_Sunday_Duration,@temp_Start_Time, @temp_End_Time;
WHILE @@FETCH_STATUS=0
BEGIN
	--Insert values into TempTable
	Insert into @TempTable Values (@basedate,@roundcode, @Day_name, @Provider_Class_Code, @Team_Name,  @temp_Monday_Start, @temp_Monday_Duration, @temp_Tuesday_Start, @temp_Tuesday_Duration, @temp_Wednesday_Start, @temp_Wednesday_Duration, @temp_Thursday_Start , @temp_Thursday_Duration, @temp_Friday_Start, @temp_Friday_Duration,@temp_Saturday_Start,@temp_Saturday_Duration,@temp_Sunday_Start,@temp_Sunday_Duration,@temp_Start_Time, @temp_End_Time)
					--create Cursor for Temp Table 
					DECLARE c_Date CURSOR FOR SELECT date from @TempTable;
						  open c_Date;
						  FETCH NEXT FROM c_Date INTO @basedate;
						WHILE (DATEADD(DAY, @offset, @basedate) <=  @end)
						BEGIN
						
							select @basedate =  DATEADD(DAY, @offset, @basedate) where @basedate < @end
							select @Day_name = DATENAME ( weekday , @basedate )  
							INSERT INTO @TempTable Values (@basedate, @roundcode, @Day_name, @Provider_Class_Code, @Team_Name,  @temp_Monday_Start, @temp_Monday_Duration, @temp_Tuesday_Start, @temp_Tuesday_Duration, @temp_Wednesday_Start, @temp_Wednesday_Duration, @temp_Thursday_Start , @temp_Thursday_Duration, @temp_Friday_Start, @temp_Friday_Duration,@temp_Saturday_Start,@temp_Saturday_Duration,@temp_Sunday_Start,@temp_Sunday_Duration,@temp_Start_Time, @temp_End_Time) 

						FETCH NEXT FROM c_Date INTO @basedate;
					End
					CLOSE c_Date;
					DEALLOCATE c_Date;	
					select @basedate = @start
					select @Day_name = DATENAME ( weekday , @start ) 

	FETCH NEXT FROM c_Round INTO @roundcode, @Provider_Class_Code, @Team_Name,  @temp_Monday_Start, @temp_Monday_Duration, @temp_Tuesday_Start, @temp_Tuesday_Duration, @temp_Wednesday_Start, @temp_Wednesday_Duration, @temp_Thursday_Start , @temp_Thursday_Duration, @temp_Friday_Start, @temp_Friday_Duration,@temp_Saturday_Start,@temp_Saturday_Duration,@temp_Sunday_Start,@temp_Sunday_Duration,@temp_Start_Time, @temp_End_Time;
End
CLOSE c_Round ;
DEALLOCATE c_Round;	



--Get Days Of the Week For adding to main table
Declare @MaxRecords Int = 0
Declare @Cnter Int = 1
Declare @GetNextWorkingWeek bit
Declare @WorkingWeekNo numeric(18,0) = NULL
Declare @SPPID Int
Declare @FromDate Datetime
Declare @Period_Type_Code varchar(6)
Declare @Period_Increment smallint
Declare @Period_Selection_Sequence varchar(10)
Declare @Period_Selection_Day_Type varchar(15)
Declare @Day_No_of_Month smallint
Declare @Month_of_Year varchar(15)
Declare @RoundHours TABLE (
    [RowID] Int IDENTITY(1,1) NOT NULL,
	[Service_Prov_Position_ID] numeric(18,0) NULL,
	[From_Date] Datetime NULL,
	[Working_Week_No] numeric(18,0) NULL,
	[Period_Type_Code] varchar(6) NULL,
	[Period_Increment] smallint NULL,
	[Period_Selection_Sequence] varchar(10) NULL,
	[Period_Selection_Day_Type] varchar(15) NULL,
	[Day_No_of_Month] smallint NULL,
	[Month_of_Year] varchar(15) NULL)
Declare @WorkingWeek TABLE (
	[Service_Prov_Position_ID] numeric(18,0) NULL,
	[From_Date] Datetime NULL,
	[Working_Week_No] numeric(18,0) NULL,
	[Period_Type_Code] varchar(6) NULL,
	[Period_Increment] smallint NULL,
	[Period_Selection_Sequence] varchar(10) NULL,
	[Period_Selection_Day_Type] varchar(15) NULL,
	[Day_No_of_Month] smallint NULL,
	[Month_of_Year] varchar(15) NULL,
	[Next_Working_Week_No] numeric(18,0) NULL,
	[Rotation_Cycle] [tinyint] NULL,
	[Monday_Start] [datetime] NULL,
	[Monday_Duration] [decimal](4, 2) NULL,
	[Tuesday_Start] [datetime] NULL,
	[Tuesday_Duration] [decimal](4, 2) NULL,
	[Wednesday_Start] [datetime] NULL,
	[Wednesday_Duration] [decimal](4, 2) NULL,
	[Thursday_Start] [datetime] NULL,
	[Thursday_Duration] [decimal](4, 2) NULL,
	[Friday_Start] [datetime] NULL,
	[Friday_Duration] [decimal](4, 2) NULL,
	[Saturday_Start] [datetime] NULL,
	[Saturday_Duration] [decimal](4, 2) NULL,
	[Sunday_Start] [datetime] NULL,
	[Sunday_Duration] [decimal](4, 2) NULL)
Insert Into @RoundHours([Service_Prov_Position_ID],[From_Date],[Working_Week_No])
Select SPA.Service_Prov_Position_ID, SPA.From_Date, SPA.Working_Week_No
	From [appsql-3\comcareprod].[comcareprod].dbo.Service_Provision_Allocation SPA
	Join [appsql-3\comcareprod].[comcareprod].dbo.Working_Week WW ON SPA.Working_Week_No = WW.Working_Week_No
Where ISNULL(SPA.To_Date,'31 Dec 9999') >= GETDATE()
SET @MaxRecords = (Select Count(*) From @RoundHours)
While @Cnter <  @MaxRecords OR @MaxRecords IS NULL
  BEGIN
	SET @GetNextWorkingWeek = 1
	Select @WorkingWeekNo = Working_Week_No, @SPPID = Service_Prov_Position_ID,
			@FromDate = From_Date, @Period_Type_Code = Period_Type_Code,
			@Period_Increment = Period_Increment, @Period_Selection_Sequence = Period_Selection_Sequence,
			@Period_Selection_Day_Type = Period_Selection_Day_Type, @Day_No_of_Month = Day_No_of_Month,
			@Month_of_Year = Month_of_Year
		From @RoundHours Where RowID = @Cnter
	While @GetNextWorkingWeek = 1
	  BEGIN
		Insert Into @WorkingWeek(Service_Prov_Position_ID,From_Date,Working_Week_No,Next_Working_Week_No,Period_Type_Code,Period_Increment,Period_Selection_Sequence,Period_Selection_Day_Type,
					Day_No_of_Month, Month_of_Year, Rotation_Cycle,Monday_Start,Monday_Duration,Tuesday_Start,Tuesday_Duration,Wednesday_Start,Wednesday_Duration,Thursday_Start,Thursday_Duration,
					Friday_Start,Friday_Duration,Saturday_Start,Saturday_Duration,Sunday_Start,Sunday_Duration)
		Select @SPPID,@FromDate,Working_Week_No,Next_Working_Week_No,@Period_Type_Code,@Period_Increment,@Period_Selection_Sequence,@Period_Selection_Day_Type,
					@Day_No_of_Month, @Month_of_Year,Rotation_Cycle,Monday_Start,Monday_Duration,Tuesday_Start,Tuesday_Duration,Wednesday_Start,Wednesday_Duration,Thursday_Start,Thursday_Duration,
					Friday_Start,Friday_Duration,Saturday_Start,Saturday_Duration,Sunday_Start,Sunday_Duration
			From [appsql-3\comcareprod].[comcareprod].dbo.Working_Week Where Working_Week_No = @WorkingWeekNo
		IF (Select Next_Working_Week_No From [appsql-3\comcareprod].[comcareprod].dbo.Working_Week Where Working_Week_No = @WorkingWeekNo) IS NULL
		  SET @GetNextWorkingWeek = 0
		ELSE
		  SET @WorkingWeekNo = (Select Next_Working_Week_No From [appsql-3\comcareprod].[comcareprod].dbo.Working_Week Where Working_Week_No = @WorkingWeekNo)
	  END	
	Set @Cnter = @Cnter + 1
  END

--Create Main Table
Declare @Temp_Overall_Table table 
( date datetime, 
roundcode varchar(20),
Day_of_week char(20), 
Provider_Class_Code char(5),
Team_Name char(20),
Start_Time varchar(10),
End_Time varchar(10),
Activity_Date datetime, 
Organisation_name varchar(20), 
Generated_Provider_Code varchar(20), 
Provider_ID int, 
Absence_Code varchar(10), 
Monday_Duration decimal(4, 2), 
Tuesday_Duration decimal(4, 2), 
Wednesday_Duration decimal(4, 2), 
Thursday_Duration decimal(4, 2), 
Friday_Duration decimal(4, 2), 
Saturday_Duration decimal(4, 2), 
Sunday_duration decimal(4, 2)
)
--declare Main Variables
Declare 
@Main_Date datetime,
@Main_Roundcode varchar(20),
@Main_Day_Name char(20),
@Main_Provider_Class_Code char(5),
@Main_Team_Name char(20),
@Main_Start_Time varchar(10),
@Main_End_Time varchar(10),
@Main_Activity_Date datetime,
@Main_Organisation_Name varchar(20),
@Main_Generated_Provider_Code varchar(20),
@Main_Provider_ID int,
@Main_Absence_Code varchar(10),
@Main_Monday_Duration decimal(4, 2),
@Main_Tuesday_Duration decimal(4, 2),
@Main_Wednesday_Duration decimal(4, 2),
@Main_Thursday_Duration decimal(4, 2),
@Main_Friday_Duration decimal(4, 2),
@Main_Saturday_Duration decimal(4, 2),
@Main_Sunday_Duration decimal(4, 2)

--Cursor for Main Table
DECLARE c_Main_Table CURSOR FOR 
			(select t1.Date, t1.roundcode, t1.Day_of_week,t1.Provider_Class_Code, t1.Team_Name,t1.Start_Time,t1.End_Time, t2.Activity_Date, t2.Organisation_Name, t2.Generated_Provider_Code, t2.Provider_ID, t2.Absence_Code,t2.Monday_Duration, t2.Tuesday_Duration, t2.Wednesday_Duration, t2.Thursday_Duration, t2.Friday_Duration, t2.Saturday_Duration, t2.Sunday_Duration
			from @TempTable as t1
			left join (
			SELECT
			DATEADD(DD,0,DATEDIFF(DD,0,J001.[Activity_Date])) as Activity_Date
			,J002Organisation.Organisation_Name as Organisation_Name
			,J002.[Generated_Provider_Code] as Generated_Provider_Code
			,J004.[Provider_ID] as Provider_ID
			,J001.[Absence_Code] as Absence_Code
			,J005.[Monday_Duration] as Monday_Duration
			,J005.[Tuesday_Duration] as Tuesday_Duration
			,J005.[Wednesday_Duration] as Wednesday_Duration
			,J005.[Thursday_Duration] as Thursday_Duration
			,J005.[Friday_Duration] as Friday_Duration
			,J005.[Saturday_Duration] as Saturday_Duration
			,J005.[Sunday_Duration] as Sunday_Duration
			FROM
			[appsql-3\comcareprod].[comcareprod].dbo.[WI_Activity] J001
			LEFT OUTER JOIN [appsql-3\comcareprod].[comcareprod].dbo.[Service_Provision_Position] J002 ON J002.[Service_Prov_Position_ID] = J001.[SPPID]
			LEFT OUTER JOIN [appsql-3\comcareprod].[comcareprod].dbo.[Organisation] J002Organisation ON J002Organisation.[Organisation_ID] = J002.[Centre_ID]
			INNER JOIN (
			Select
					Prov.Provider_ID,
					prov.ComCare_Provider_No,
					prov.Employee_No,
					prov.Creation_Date,
					prov.Creator_User_Name,
					prov.Last_Modified_Date,
					Prov.Last_Modified_User_Name,
					Prov.Trainer,
					P.Preferred_Name,
					P.Last_Name,
					P.Given_Names,
					P.Salutation,
					P.Birth_Date,
					CONVERT(datetime,P.Deceased_Date) [Deceased_Date],
					P.Estimated_DOB_Flag,
					P.Dummy_PID,
					P.Source_System,
					P.Source_System_Person_ID,
					G.Description as 'Gender',
					T.Description as 'Title',
					C.Description as 'Country',
					L.Description as 'Language',
					ES.Description as 'Employment Status',
					MS.Description as 'Marital Status',
					INS.Description as 'Interpreter Status'
			from [appsql-3\comcareprod].[comcareprod].dbo.Provider Prov WITH(NOLOCK)
			Inner Join [appsql-3\comcareprod].[comcareprod].dbo.Person P WITH(NOLOCK) on Prov.Provider_ID = P.Person_ID
			Inner Join [appsql-3\comcareprod].[comcareprod].dbo.Title T on P.Title_Code = T.Title_Code
			Left Outer Join [appsql-3\comcareprod].[comcareprod].dbo.Gender G on P.Gender_Code = G.Gender_Code
			Left Outer Join [appsql-3\comcareprod].[comcareprod].dbo.Country C on P.Country_Code = C.Country_Code
			Left Outer Join [appsql-3\comcareprod].[comcareprod].dbo.Language L on P.Language_Code = L.Language_Code
			Left Outer Join [appsql-3\comcareprod].[comcareprod].dbo.Employment_Status ES on P.Employment_Status_ID = ES.Employment_Status_ID
			Left Outer Join [appsql-3\comcareprod].[comcareprod].dbo.Marital_Status MS on P.Marital_Status_ID = MS.Marital_Status_ID
			Left Outer Join [appsql-3\comcareprod].[comcareprod].dbo.Interpreter_Status INS on P.Interpreter_Status_ID = INS.Interpreter_Status_ID
			Left Outer Join [appsql-3\comcareprod].[comcareprod].dbo.Ethnicity_Classification EC on P.Ethnicity_Class_Code = EC.Ethnicity_Class_Code
			) J004 ON J004.[Provider_ID] = J001.[Provider_ID]
			INNER JOIN
			(
			Select Service_Prov_Position_ID,From_Date,Working_Week_No,Next_Working_Week_No,Period_Type_Code,Period_Increment,Period_Selection_Sequence,Period_Selection_Day_Type,
					Day_No_of_Month, Month_of_Year, Rotation_Cycle,Monday_Start,Monday_Duration,Tuesday_Start,Tuesday_Duration,Wednesday_Start,Wednesday_Duration,Thursday_Start,Thursday_Duration,Friday_Start,Friday_Duration,Saturday_Start,Saturday_Duration,Sunday_Start,Sunday_Duration
			From @WorkingWeek
			) J005 ON J005.[Service_Prov_Position_ID] = J002.[Service_Prov_Position_ID]
			WHERE
			J001.[Activity_Date] BETWEEN @start AND @end
			and Centre_ID=@teamNo 

			GROUP BY
			DATEADD(DD,0,DATEDIFF(DD,0,J001.[Activity_Date]))
			,J002Organisation.Organisation_Name
			,J002.[Generated_Provider_Code]
			,J004.[Provider_ID]
			,J001.[Absence_Code]
			,J005.[Monday_Duration]
			,J005.[Tuesday_Duration]
			,J005.[Wednesday_Duration]
			,J005.[Thursday_Duration]
			,J005.[Friday_Duration]
			,J005.[Saturday_Duration]
			,J005.[Sunday_Duration]

			) as t2
			on t1.date=t2.Activity_Date and t1.roundcode=t2.[Generated_Provider_Code] 


			)

 open c_Main_Table;
FETCH NEXT FROM c_Main_Table INTO @Main_Date, @Main_Roundcode, @Main_Day_Name, @Main_Provider_Class_Code, @Main_Team_Name, @Main_Start_Time, @Main_End_Time, @Main_Activity_Date, @Main_Organisation_Name, @Main_Generated_Provider_Code,  @Main_Provider_ID, @Main_Absence_Code, @Main_Monday_Duration, @Main_Tuesday_Duration, @Main_Wednesday_Duration, @Main_Thursday_Duration, @Main_Friday_Duration, @Main_Saturday_Duration, @Main_Sunday_Duration;
WHILE @@FETCH_STATUS=0
BEGIN
	Insert into @Temp_Overall_Table Values (@Main_Date, @Main_Roundcode, @Main_Day_Name, @Main_Provider_Class_Code, @Main_Team_Name, @Main_Start_Time, @Main_End_Time, @Main_Activity_Date, @Main_Organisation_Name, @Main_Generated_Provider_Code,  @Main_Provider_ID, @Main_Absence_Code, @Main_Monday_Duration, @Main_Tuesday_Duration, @Main_Wednesday_Duration, @Main_Thursday_Duration, @Main_Friday_Duration, @Main_Saturday_Duration, @Main_Sunday_Duration)
	declare @count_all int, @count_absent int
	set @count_all = (select count(*)  from @Temp_Overall_Table where roundcode =@Main_Roundcode and date = @Main_Date)
	set @count_absent = (select count(*)  from @Temp_Overall_Table where roundcode =@Main_Roundcode and date = @Main_Date and Absence_Code is not null)
	if (@count_all = 2 and @count_absent <>2)
	begin
	delete from  @Temp_Overall_Table where  roundcode =@Main_Roundcode and date = @Main_Date
	end


	FETCH NEXT FROM c_Main_Table INTO @Main_Date, @Main_Roundcode, @Main_Day_Name, @Main_Provider_Class_Code, @Main_Team_Name,@Main_Start_Time, @Main_End_Time, @Main_Activity_Date, @Main_Organisation_Name, @Main_Generated_Provider_Code,  @Main_Provider_ID, @Main_Absence_Code, @Main_Monday_Duration, @Main_Tuesday_Duration, @Main_Wednesday_Duration, @Main_Thursday_Duration, @Main_Friday_Duration, @Main_Saturday_Duration, @Main_Sunday_Duration


End
CLOSE c_Main_Table ;
DEALLOCATE c_Main_Table;	





--declare absence variables
declare 
@roundcode_point varchar(20),
@Monday_Duration decimal(2),
@Tuesday_Duration decimal(2),
@Wednesday_Duration decimal(2),
@Thursday_Duration decimal(2),
@Friday_Duration decimal(2),
@Saturday_Duration decimal(2),
@Sunday_Duration decimal(2)


--declare absence curour
DECLARE c_Round_Count CURSOR FOR SELECT Generated_Provider_Code, Monday_Duration, Tuesday_Duration, Wednesday_Duration, Thursday_Duration, Friday_Duration, Saturday_Duration, Sunday_Duration
			from [appsql-3\comcareprod].[comcareprod].dbo.Service_Provision_Position as t1
			inner join
			[appsql-3\comcareprod].[comcareprod].dbo.Service_Provision_Allocation as t2
			ON t1.Service_Prov_Position_ID=t2.Service_Prov_Position_ID
			join [appsql-3\comcareprod].[comcareprod].dbo.Working_Week as t3
			ON t2.Working_Week_No=t3.Working_Week_No
			where t1.Centre_ID=@teamNo and t1.position_Closed_date is null 
 
 
 
  open c_Round_Count;
  FETCH NEXT FROM c_Round_Count into @roundcode_point, @Monday_Duration, @Tuesday_Duration, @Wednesday_Duration, @Thursday_Duration, @Friday_Duration, @Saturday_Duration, @Sunday_Duration;
WHILE @@FETCH_STATUS=0
BEGIN

		declare @count_date int, @count_Monday int, @count_Tuesday int,@count_Wednesday int,@count_Thursday int,@count_Friday int, @count_Saturday int, @count_Sunday int


		
		set @count_date = (select count(*)  from @Temp_Overall_Table where Activity_Date is null)
		--check Monday 
		
					if(@Monday_Duration is null) 
					Begin
					delete  from @Temp_Overall_Table where roundcode =@roundcode_point and Day_of_week ='Monday'
					end

		
		--check Tuesday
					if(@Tuesday_Duration is null)
					BEGIN
					delete  from @Temp_Overall_Table where roundcode =@roundcode_point and Day_of_week ='Tuesday'
					END
		
		--check Wednesday
					if(@Wednesday_Duration is null)
					BEGIN
					delete  from @Temp_Overall_Table where roundcode =@roundcode_point and Day_of_week ='Wednesday'
					END


		--check Thursday
					if(@Thursday_Duration is null)
					BEGIN
					delete  from @Temp_Overall_Table where roundcode =@roundcode_point and Day_of_week ='Thursday'
					END

		--check Friday
					if(@Friday_Duration is null)
					BEGIN
					delete  from @Temp_Overall_Table where roundcode =@roundcode_point and Day_of_week ='Friday'
					END

		--check Saturday
					if(@Saturday_Duration is null)
					BEGIN
					delete  from @Temp_Overall_Table where roundcode =@roundcode_point and Day_of_week ='Saturday'
					END

		--check Sunday
					if(@Sunday_Duration is null)
					BEGIN
					delete  from @Temp_Overall_Table where roundcode =@roundcode_point and Day_of_week ='Sunday'
					END
		

		FETCH NEXT FROM c_Round_Count into @roundcode_point, @Monday_Duration, @Tuesday_Duration, @Wednesday_Duration, @Thursday_Duration, @Friday_Duration, @Saturday_Duration, @Sunday_Duration;
end
CLOSE c_Round_Count ;
DEALLOCATE c_Round_Count;


--delete empty values
delete from t1
from  @Temp_Overall_Table as t1
inner join (
select roundcode, date,count(*) as scount
from  @Temp_Overall_Table
group by  roundcode,date having count(*) >2  ) as t2
on t1.date=t2.date and t1.roundcode=t2.roundcode


select convert(date, date)as date, roundcode,Day_of_Week,Provider_Class_Code, Team_Name, Start_Time, End_Time, Activity_Date, Organisation_name, Generated_Provider_Code, Provider_ID, Absence_Code, Monday_Duration,Tuesday_Duration, Wednesday_Duration, Thursday_Duration, Friday_Duration, Saturday_Duration, Sunday_duration from @Temp_Overall_Table where (Activity_Date is null or Absence_Code is not null) and Team_Name <> 'Buddy Team' order by Provider_Class_Code, Team_Name, roundcode, date;
end