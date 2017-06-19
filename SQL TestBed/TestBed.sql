Declare @Start_Date date = cast('2017-06-19' as date)
Declare @RAC_Site int = 54
Declare @Provider_Classification varchar(16) = 'PCW'


declare @startdate datetime
set @startdate= @Start_Date		
declare @Enddate date = dateadd(day,13,@startdate)
--select @startdate

select	 
J002.[Provider_ID] as Provider_ID
,J002.[Given_Names] as Given_Name
,J002.[Last_Name] as Last_Name
,J004.[Centre_ID] as Centre_ID
,J006.[Description] as Provider_Classification
,J002.Employee_Status_Code,



		--Display Times For each Day
		max( case J001.Activity_Date
				when @startdate 
					then 
						case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  + 
						convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
						case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
							when 1 then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
							else convert(varchar,datepart(minute,J001.schedule_time))
						end
						
			end)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when @startdate 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code 


				else ''
			end
			) 
			
			 as Day_1_Monday,

		max( 
			case J001.Activity_Date
				when dateadd(day,1,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  + 
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,1,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+  CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code

					else ''
			end
			)  as Day_2_Tuesday,

		max( 
			case J001.Activity_Date
				when dateadd(day,2,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  + 
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,2,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description]
					+ '  ' +  J005.Generated_Provider_Code

				else ''
			end
			)  as Day_3_Wednesday,

		max( 
			case J001.Activity_Date
				when dateadd(day,3,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  + 
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,3,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description]
					+ '  ' +  J005.Generated_Provider_Code
				
				else ''
			end
			)  as Day_4_Thursday,

		max( 
			case J001.Activity_Date
				when dateadd(day,4,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  + 
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,4,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description]
					+ '  ' +  J005.Generated_Provider_Code
				else ''
			end
			)  as Day_5_Friday,

		max( 
			case J001.Activity_Date
				when dateadd(day,5,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  + 
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,5,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code
				else ''
			end
			)  as Day_6_Saturday,

		max( 
			case J001.Activity_Date
				when dateadd(day,6,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  + 
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,6,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description]
					+ '  ' +  J005.Generated_Provider_Code  
				else ''
			end
			)  as Day_7_Sunday,

		max( 
			case J001.Activity_Date
				when dateadd(day,7,@startdate) 
					then 
						case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  + 
						convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
						case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
							when 1 
							then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
							else convert(varchar,datepart(minute,J001.schedule_time)) 
						end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,7,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code
				else ''
			end
			)  as Day_8_Monday,

		max( 
			case J001.Activity_Date
				when dateadd(day,8,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  + 
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,8,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code
				else ''
			end
			)  as Day_9_Tuesday,

		max( 
			case J001.Activity_Date
				when dateadd(day,9,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  + 
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,9,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code
				else ''
			end
			)  as Day_10_Wednesday,

		max( 
			case J001.Activity_Date
				when dateadd(day,10,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  + 
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,10,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code 
				else ''
			end
			)  as Day_11_Thursday,

		max( 
			case J001.Activity_Date
				when dateadd(day,11,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,11,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code

				else ''
			end
			)  as Day_12_Friday,

		max( 
			case J001.Activity_Date
				when dateadd(day,12,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,12,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description]
					+ '  ' +  J005.Generated_Provider_Code
				else ''
			end
			)  as Day_13_Saturday,

		max( 
			case J001.Activity_Date
				when dateadd(day,13,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,13,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code
				else ''
			end
			)  as Day_14_Sunday,

		(Convert(decimal(10,2), sum(case  
				when J001.Activity_Date BETWEEN @startdate AND dateadd(day,13,@startdate) 
				then 
					Case 
						when J001.schedule_duration >300
						then Convert(decimal(10,2),J001.schedule_duration-30)
						else Convert(decimal(10,2),J001.schedule_duration)
					end


				else 0
			 end
			)/60) ) as Total 
 


from 
(
	select aa.* from (select * from dbo.WI_Activity wia where convert (date, wia.Activity_Date) between dateadd(day,-1,@startdate) and dateadd(day,1,@Enddate)) as aa
	inner join 
	(
		select 
			a.activity_id
			,a.provider_id
			,a.activity_date
			,a.schedule_time
			,a.schedule_duration 
		from (select * from dbo.WI_Activity wia where convert (date, wia.Activity_Date) between dateadd(day,-1,@startdate) and dateadd(day,1,@Enddate)) as a
		inner join
		(
			select 
				wia.provider_id
				,wia.activity_date
				,count(*) as scount
			from (select * from dbo.WI_Activity wia where convert (date, wia.Activity_Date) between dateadd(day,-1,@startdate) and dateadd(day,1,@Enddate))wia
			where 
				wia.SPPID<>0 
				and wia.sppid is not null
			group by 
				wia.provider_id
				,wia.activity_date having count(*)=1
		) as b on a.provider_id=b.provider_id and a.activity_date=b.activity_date

		JOIN dbo.Provider_Contract as t4 ON a.Provider_ID=t4.Provider_ID 
		JOIN dbo.Organisation as t5 ON t4.Organisation_ID=t5.Organisation_ID and convert(date,a.schedule_time)>=@startdate

		where a.SPPID<>0 and a.sppid is not null
	) as bb on 
		aa.provider_id =bb.provider_id
		and aa.activity_date=bb.activity_date
		and aa.schedule_time=bb.schedule_time
		and aa.activity_start_time is null 
		and aa.activity_end_time is null

) as J001 

INNER JOIN 
(
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
			O.Employee_Status_Code,
			G.Description as 'Gender',
			T.Description as 'Title',
			C.Description as 'Country',
			L.Description as 'Language',
			ES.Description as 'Employment Status',
			MS.Description as 'Marital Status',
			INS.Description as 'Interpreter Status'
	from dbo.Provider Prov WITH(NOLOCK)
	Inner Join dbo.Person P WITH(NOLOCK) on Prov.Provider_ID = P.Person_ID
	Inner Join dbo.Title T on P.Title_Code = T.Title_Code
	left outer join dbo.Provider_Payroll_Options O on Prov.Provider_ID = O.Provider_ID
	Left Outer Join dbo.Gender G on P.Gender_Code = G.Gender_Code
	Left Outer Join dbo.Country C on P.Country_Code = C.Country_Code
	Left Outer Join dbo.Language L on P.Language_Code = L.Language_Code
	Left Outer Join dbo.Employment_Status ES on P.Employment_Status_ID = ES.Employment_Status_ID
	Left Outer Join dbo.Marital_Status MS on P.Marital_Status_ID = MS.Marital_Status_ID
	Left Outer Join dbo.Interpreter_Status INS on P.Interpreter_Status_ID = INS.Interpreter_Status_ID
	Left Outer Join dbo.Ethnicity_Classification EC on P.Ethnicity_Class_Code = EC.Ethnicity_Class_Code
) J002 ON J002.[Provider_ID] = J001.[Provider_ID]

LEFT OUTER JOIN dbo.Provider_Contract J003 ON J003.[Provider_ID] = J002.[Provider_ID]

LEFT OUTER JOIN 
(
	SELECT 
		C.Centre_ID
		,C.Centre_Code
		,O.Organisation_Name [Centre] 
	from dbo.Centre C	
	JOIN dbo.Organisation O ON C.Centre_ID = O.Organisation_ID
) J004 ON J004.[Centre_ID] = J003.[Organisation_ID]

LEFT OUTER JOIN dbo.Service_Provision_Position J005 ON J005.[Service_Prov_Position_ID] = J001.[SPPID]
LEFT OUTER JOIN dbo.Provider_Classification J006 ON J006.[Provider_Class_Code] = J005.[Provider_Class_Code]
LEFT OUTER JOIN dbo.Shift J007 ON J007.[Shift_Code] = J005.[Shift_Code]
INNER JOIN dbo.[Team_Position] J008 ON J008.[Service_Prov_Position_ID] = J005.[Service_Prov_Position_ID]
LEFT OUTER JOIN dbo.[Service_Delivery_Work_Team] J009 ON J009.[Centre_ID] = J008.[Centre_ID] AND J009.[Team_No] = J008.[Team_No]

where 
	J005.Centre_ID = @RAC_Site 
	and J006.Provider_Class_Code in(@Provider_Classification) 
	and J001.SPPID<>0 
	and J001.sppid is not null 
	and J003.Effective_date_to is null

Group by 
	J002.[Provider_ID] 
	,J002.[Given_Names] 
	,J002.[Last_Name] 
	,J004.[Centre_ID] 
	,J001.[Absence_Code] 
	,J006.[Description] 
	,J002.Employee_Status_Code

/* -----------------union part2----------------------------------------------------------------------------*/
union
/* -----------------union part2----------------------------------------------------------------------------*/

select	 
	J002.[Provider_ID] as Provider_ID
	,J002.[Given_Names] as Given_Name
	,J002.[Last_Name] as Last_Name
	,J004.[Centre_ID] as Centre_ID
	,J006.[Description] as Provider_Classification
	,J002.Employee_Status_Code
	,
		--Display Times For each Day
		max( case J001.Activity_Date
				when @startdate 
					then 
						case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
						convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
						case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
							when 1 then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
							else convert(varchar,datepart(minute,J001.schedule_time))
						end
						
			end)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when @startdate 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code
				else ''
			end
			) 
			
			 as Day_1_Monday,

		max( 
			case J001.Activity_Date
				when dateadd(day,1,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,1,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code
				else ''
			end
			)  as Day_2_Tuesday,

		max( 
			case J001.Activity_Date
				when dateadd(day,2,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,2,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code
				else ''
			end
			)  as Day_3_Wednesday,

		max( 
			case J001.Activity_Date
				when dateadd(day,3,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,3,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code
				else ''
			end
			)  as Day_4_Thursday,

		max( 
			case J001.Activity_Date
				when dateadd(day,4,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,4,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code
				else ''
			end
			)  as Day_5_Friday,

		max( 
			case J001.Activity_Date
				when dateadd(day,5,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,5,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code 
				else ''
			end
			)  as Day_6_Saturday,

		max( 
			case J001.Activity_Date
				when dateadd(day,6,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,6,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code
				else ''
			end
			)  as Day_7_Sunday,

		max( 
			case J001.Activity_Date
				when dateadd(day,7,@startdate) 
				then 
						case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
						convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
						case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
							when 1 
							then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
							else convert(varchar,datepart(minute,J001.schedule_time)) 
						end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,7,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code
				else ''
			end
			)  as Day_8_Monday,

		max( 
			case J001.Activity_Date
				when dateadd(day,8,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,8,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code
				else ''
			end
			)  as Day_9_Tuesday,

		max( 
			case J001.Activity_Date
				when dateadd(day,9,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,9,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description]  
					+ '  ' +  J005.Generated_Provider_Code 
				else ''
			end
			)  as Day_10_Wednesday,

		max( 
			case J001.Activity_Date
				when dateadd(day,10,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,10,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code 
				else ''
			end
			)  as Day_11_Thursday,

		max( 
			case J001.Activity_Date
				when dateadd(day,11,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,11,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code
				else ''
			end
			)  as Day_12_Friday,

		max( 
			case J001.Activity_Date
				when dateadd(day,12,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,12,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code 
				else ''
			end
			)  as Day_13_Saturday,

		max( 
			case J001.Activity_Date
				when dateadd(day,13,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,13,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code
				else ''
			end
			)  as Day_14_Sunday,

		(Convert(decimal(10,2), sum(case  
				when J001.Activity_Date BETWEEN @startdate AND dateadd(day,13,@startdate) 
				then 
					Case 
						when J001.schedule_duration >300
						then Convert(decimal(10,2),J001.schedule_duration-30)
						else Convert(decimal(10,2),J001.schedule_duration)
					end
				else 0
			 end
			)/60) ) as Total 
 
from 
(
	select aa.* from (select * from dbo.WI_Activity wia where convert (date, wia.Activity_Date) between dateadd(day,-1,@startdate) and dateadd(day,1,@Enddate)) as aa
	inner join 
	(
		select 
			a.provider_id
			,a.activity_date
			,min(convert(time, a.schedule_time)) as schedule_time  
		from (select * from dbo.WI_Activity wia where convert (date, wia.Activity_Date) between dateadd(day,-1,@startdate) and dateadd(day,1,@Enddate)) as a
		inner join 
		(
			select 
				wia.provider_id
				,wia.activity_date
				,count(*) as scount
			from (select * from dbo.WI_Activity wia where convert (date, wia.Activity_Date) between dateadd(day,-1,@startdate) and dateadd(day,1,@Enddate))wia
			where 
				wia.SPPID<>0 
				and wia.sppid is not null
			group by 
				wia.provider_id
				,wia.activity_date having count(*)>1
		) as b on a.provider_id=b.provider_id and a.activity_date=b.activity_date

		JOIN dbo.Provider_Contract as t4 ON a.Provider_ID=t4.Provider_ID 
		JOIN dbo.Organisation as t5 ON t4.Organisation_ID=t5.Organisation_ID 

		where  
			a.SPPID<>0 
			and a.sppid is not null
			and convert(date,a.schedule_time)>=@startdate
		group by  
			a.provider_id
			,a.activity_date 
	) as bb on 
		aa.provider_id =bb.provider_id
		and aa.activity_date=bb.activity_date
		and convert(time,aa.schedule_time)=bb.schedule_time
		and aa.activity_start_time is null 
		and aa.activity_end_time is null
) as J001 

INNER JOIN 
(
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
			O.Employee_Status_Code,
			G.Description as 'Gender',
			T.Description as 'Title',
			C.Description as 'Country',
			L.Description as 'Language',
			ES.Description as 'Employment Status',
			MS.Description as 'Marital Status',
			INS.Description as 'Interpreter Status'
	from dbo.Provider Prov WITH(NOLOCK)
		Inner Join dbo.Person P WITH(NOLOCK) on Prov.Provider_ID = P.Person_ID
		Inner Join dbo.Title T on P.Title_Code = T.Title_Code
		left outer join dbo.Provider_Payroll_Options O on Prov.Provider_ID = O.Provider_ID
		Left Outer Join dbo.Gender G on P.Gender_Code = G.Gender_Code
		Left Outer Join dbo.Country C on P.Country_Code = C.Country_Code
		Left Outer Join dbo.Language L on P.Language_Code = L.Language_Code
		Left Outer Join dbo.Employment_Status ES on P.Employment_Status_ID = ES.Employment_Status_ID
		Left Outer Join dbo.Marital_Status MS on P.Marital_Status_ID = MS.Marital_Status_ID
		Left Outer Join dbo.Interpreter_Status INS on P.Interpreter_Status_ID = INS.Interpreter_Status_ID
		Left Outer Join dbo.Ethnicity_Classification EC on P.Ethnicity_Class_Code = EC.Ethnicity_Class_Code

) J002 ON J002.[Provider_ID] = J001.[Provider_ID]

LEFT OUTER JOIN dbo.Provider_Contract J003 ON J003.[Provider_ID] = J002.[Provider_ID]

LEFT OUTER JOIN 
(
	SELECT 
		C.Centre_ID
		,C.Centre_Code
		,O.Organisation_Name [Centre] 
	from dbo.Centre C	
	JOIN dbo.Organisation O ON C.Centre_ID = O.Organisation_ID

) J004 ON J004.[Centre_ID] = J003.[Organisation_ID]

LEFT OUTER JOIN dbo.Service_Provision_Position J005 ON J005.[Service_Prov_Position_ID] = J001.[SPPID]
LEFT OUTER JOIN dbo.Provider_Classification J006 ON J006.[Provider_Class_Code] = J005.[Provider_Class_Code]
LEFT OUTER JOIN dbo.Shift J007 ON J007.[Shift_Code] = J005.[Shift_Code]
INNER JOIN dbo.[Team_Position] J008 ON J008.[Service_Prov_Position_ID] = J005.[Service_Prov_Position_ID]
LEFT OUTER JOIN dbo.[Service_Delivery_Work_Team] J009 ON J009.[Centre_ID] = J008.[Centre_ID] AND J009.[Team_No] = J008.[Team_No]
--select * from dbo.Provider_Classification


where  
	J005.Centre_ID = @RAC_Site 
	and J006.Provider_Class_Code in(@Provider_Classification) 
	and J001.SPPID<>0 
	and J001.sppid is not null 
	and  J003.Effective_date_to is null

Group by 
	J002.[Provider_ID] 
	,J002.[Given_Names] 
	,J002.[Last_Name] 
	,J004.[Centre_ID] 
	,J001.[Absence_Code] 
	,J006.[Description] 
	,J002.Employee_Status_Code

/* -----------------union part3----------------------------------------------------------------------------*/
union
/* -----------------union part3----------------------------------------------------------------------------*/

select	 
J002.[Provider_ID] as Provider_ID
,J002.[Given_Names] as Given_Name
,J002.[Last_Name] as Last_Name
,J004.[Centre_ID] as Centre_ID
,J006.[Description] as Provider_Classification
,J002.Employee_Status_Code
,
		--Display Times For each Day
		max( case J001.Activity_Date
				when @startdate 
					then 
						case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
						convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
						case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
							when 1 then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
							else convert(varchar,datepart(minute,J001.schedule_time))
						end
						
			end)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when @startdate 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code 
				else ''
			end
			) 
			
			 as Day_1_Monday,

		max( 
			case J001.Activity_Date
				when dateadd(day,1,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,1,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code
				else ''
			end
			)  as Day_2_Tuesday,

		max( 
			case J001.Activity_Date
				when dateadd(day,2,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,2,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code
				else ''
			end
			)  as Day_3_Wednesday,

		max( 
			case J001.Activity_Date
				when dateadd(day,3,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,3,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code 	 
				else ''
			end
			)  as Day_4_Thursday,

		max( 
			case J001.Activity_Date
				when dateadd(day,4,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,4,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description]
					+ '  ' +  J005.Generated_Provider_Code 
				else ''
			end
			)  as Day_5_Friday,

		max( 
			case J001.Activity_Date
				when dateadd(day,5,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,5,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code
				else ''
			end
			)  as Day_6_Saturday,

		max( 
			case J001.Activity_Date
				when dateadd(day,6,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,6,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code 
				else ''
			end
			)  as Day_7_Sunday,

		max( 
			case J001.Activity_Date
				when dateadd(day,7,@startdate) 
					then 
						case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
						convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
						case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
							when 1 
							then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
							else convert(varchar,datepart(minute,J001.schedule_time)) 
						end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,7,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code
				else ''
			end
			)  as Day_8_Monday,

		max( 
			case J001.Activity_Date
				when dateadd(day,8,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,8,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code
				else ''
			end
			)  as Day_9_Tuesday,

		max( 
			case J001.Activity_Date
				when dateadd(day,9,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,9,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code
				else ''
			end
			)  as Day_10_Wednesday,

		max( 
			case J001.Activity_Date
				when dateadd(day,10,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,10,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code
				else ''
			end
			)  as Day_11_Thursday,

		max( 
			case J001.Activity_Date
				when dateadd(day,11,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,11,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description] 
					+ '  ' +  J005.Generated_Provider_Code
				else ''
			end
			)  as Day_12_Friday,

		max( 
			case J001.Activity_Date
				when dateadd(day,12,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
			case J001.Activity_Date
				when dateadd(day,12,@startdate) 
				then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
					case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
						when 1 
						then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
						else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
					end
					+ CHAR(13)+CHAR(10) + J009.[Description]
					+ '  ' +  J005.Generated_Provider_Code 
				else ''
			end
			)  as Day_13_Saturday,

		max( 
			case J001.Activity_Date
				when dateadd(day,13,@startdate) 
				then 
					case when  J001.Absence_Code is not null then  J001.Absence_Code + CHAR(13)+CHAR(10)   else '' end  +
					convert(varchar, datepart(hour,J001.schedule_time)) + ':' +
					case len(convert(varchar,datepart(minute,J001.schedule_time ))) 
						when 1 
						then convert(varchar,datepart(minute,J001.schedule_time ))+'0' 
						else convert(varchar,datepart(minute,J001.schedule_time)) 
					end 
			end
			)
		+ '   ' +
		max( 
				case J001.Activity_Date
					when dateadd(day,13,@startdate) 
					then convert(varchar,datepart(hour, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+ ':' + 
						case len(convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))) 
							when 1 
							then convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time)))+'0'
							else convert(varchar,datepart(minute, dateadd(minute, J001.Schedule_duration, J001.schedule_time))) 
						end
						+ CHAR(13)+CHAR(10) + J009.[Description] 
						+ '  ' + J005.Generated_Provider_Code
					else ''
				end
			) as Day_14_Sunday,

		(Convert(decimal(10,2), sum(case  
				when J001.Activity_Date BETWEEN @startdate AND dateadd(day,13,@startdate) 
				then 
					Case 
						when J001.schedule_duration >300
						then Convert(decimal(10,2),J001.schedule_duration-30)
						else Convert(decimal(10,2),J001.schedule_duration)
					end
				else 0
			 end
			)/60) ) as Total 
 
from 
(

	select aa.* from (select * from dbo.WI_Activity wia where convert (date, wia.Activity_Date) between dateadd(day,-1,@startdate) and dateadd(day,1,@Enddate)) as aa
	inner join 
	(
		select 
			a.provider_id
			,a.activity_date
			,max(convert(time,a.schedule_time)) as schedule_time  
		from (select * from dbo.WI_Activity wia where convert (date, wia.Activity_Date) between dateadd(day,-1,@startdate) and dateadd(day,1,@Enddate)) as a
		inner join 
		(
			select 
				wia.provider_id
				,wia.activity_date
				,count(*) as scount
			from (select * from dbo.WI_Activity wia where convert (date, wia.Activity_Date) between dateadd(day,-1,@startdate) and dateadd(day,1,@Enddate))wia
			where 
				wia.SPPID <> 0 
				and wia.sppid is not null
			group by 
				wia.provider_id
				,wia.activity_date having count(*)>1
		) as b on a.provider_id = b.provider_id and a.activity_date = b.activity_date

		JOIN dbo.Provider_Contract as t4 ON a.Provider_ID=t4.Provider_ID 
		JOIN dbo.Organisation as t5 ON t4.Organisation_ID=t5.Organisation_ID 

		where 
			a.SPPID<>0 
			and a.sppid is not null
			and convert(date,a.schedule_time)>=@startdate
		group by  
			a.provider_id
			,a.activity_date 
	) as bb on 
		aa.provider_id = bb.provider_id
		and aa.activity_date = bb.activity_date
		and convert(time,aa.schedule_time)=bb.schedule_time
		and aa.activity_start_time is null and aa.activity_end_time is null
) as J001 

INNER JOIN 
(
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
		O.Employee_Status_Code,
		G.Description as 'Gender',
		T.Description as 'Title',
		C.Description as 'Country',
		L.Description as 'Language',
		ES.Description as 'Employment Status',
		MS.Description as 'Marital Status',
		INS.Description as 'Interpreter Status'
	from dbo.Provider Prov WITH(NOLOCK)
	Inner Join dbo.Person P WITH(NOLOCK) on Prov.Provider_ID = P.Person_ID
	Inner Join dbo.Title T on P.Title_Code = T.Title_Code
	left outer join dbo.Provider_Payroll_Options O on Prov.Provider_ID = O.Provider_ID
	Left Outer Join dbo.Gender G on P.Gender_Code = G.Gender_Code
	Left Outer Join dbo.Country C on P.Country_Code = C.Country_Code
	Left Outer Join dbo.Language L on P.Language_Code = L.Language_Code
	Left Outer Join dbo.Employment_Status ES on P.Employment_Status_ID = ES.Employment_Status_ID
	Left Outer Join dbo.Marital_Status MS on P.Marital_Status_ID = MS.Marital_Status_ID
	Left Outer Join dbo.Interpreter_Status INS on P.Interpreter_Status_ID = INS.Interpreter_Status_ID
	Left Outer Join dbo.Ethnicity_Classification EC on P.Ethnicity_Class_Code = EC.Ethnicity_Class_Code
) J002 ON J002.[Provider_ID] = J001.[Provider_ID]

LEFT OUTER JOIN dbo.Provider_Contract J003 ON J003.[Provider_ID] = J002.[Provider_ID]

LEFT OUTER JOIN 
(
	SELECT 
		C.Centre_ID
		,C.Centre_Code
		,O.Organisation_Name [Centre] 
	from dbo.Centre C	
	JOIN dbo.Organisation O ON C.Centre_ID = O.Organisation_ID
) J004 ON J004.[Centre_ID] = J003.[Organisation_ID]

LEFT OUTER JOIN dbo.Service_Provision_Position J005 ON J005.[Service_Prov_Position_ID] = J001.[SPPID]
LEFT OUTER JOIN dbo.Provider_Classification J006 ON J006.[Provider_Class_Code] = J005.[Provider_Class_Code]
LEFT OUTER JOIN dbo.Shift J007 ON J007.[Shift_Code] = J005.[Shift_Code]
INNER JOIN dbo.[Team_Position] J008 ON J008.[Service_Prov_Position_ID] = J005.[Service_Prov_Position_ID]
LEFT OUTER JOIN dbo.[Service_Delivery_Work_Team] J009 ON J009.[Centre_ID] = J008.[Centre_ID] AND J009.[Team_No] = J008.[Team_No]

where 
	J005.Centre_ID = @RAC_Site 
	and J006.Provider_Class_Code in(@Provider_Classification) 
	and J001.SPPID<>0 
	and J001.sppid is not null 
	and  J003.Effective_date_to is null

Group by 
	J002.[Provider_ID] 
	,J002.[Given_Names] 
	,J002.[Last_Name] 
	,J004.[Centre_ID] 
	,J001.[Absence_Code] 
	,J006.[Description] 
	,J002.Employee_Status_Code
Order by Last_Name