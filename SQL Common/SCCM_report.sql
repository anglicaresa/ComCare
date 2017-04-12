--for Nick F

use SCCM12_ANG
Begin

SELECT distinct
	CS.name0 'Computer Name'
	,CS.domain0 'Domain'
	,CS.UserName0 'User'
	,BIOS.SerialNumber0 'Bios serial'
	,SE.SerialNumber0 'System Enclosure serial'
	,CS.Manufacturer0 'Manufacturer'
	,CS.Model0 'model'
	,OS.Caption0 'OS'
	,RAA.SMS_Assigned_Sites0 'Site'
	,RAM.TotalPhysicalMemory0 'Total Memory'
	,sum(isnull(LDisk.Size0,'0')) 'Hardrive Size'
	,sum(isnull(LDisk.FreeSpace0,'0')) 'Free Space'
	,CPU.CurrentClockSpeed0 'CPU Speed'
	,J001.DefaultIPGateway0
	,(
		Case
		when J001.DefaultIPGateway0 = '10.10.5.1' then 'Augustus Short'
		when J001.DefaultIPGateway0 = '10.10.40.1' then 'Holden Hill'
		when J001.DefaultIPGateway0 = '10.10.5.0' then 'Cathedral Lodge'
		when J001.DefaultIPGateway0 = '10.10.5.24' then 'Cathedral Lodge'
		when J001.DefaultIPGateway0 = '10.10.0.1' then 'St Barnabas'
		when J001.DefaultIPGateway0 = '10.105.0.1' then 'Church Street (Salisbury)'
		when J001.DefaultIPGateway0 = '10.10.37.1' then 'Grand View Court'
		when J001.DefaultIPGateway0 = '10.102.0.1' then 'Southern Hub'
		when J001.DefaultIPGateway0 = '10.101.0.1' then 'Outer Southern Hub'
		when J001.DefaultIPGateway0 = '10.10.27.1' then 'All Hallows'
		when J001.DefaultIPGateway0 = '10.10.13.1' then 'St Laurance'
		when J001.DefaultIPGateway0 = '10.103.0.1' then 'Elizabeth Grove'
		when J001.DefaultIPGateway0 = '10.10.20.1' then 'Dutton Court'
		when J001.DefaultIPGateway0 = '10.10.22.1' then 'Phillip Highway'
		when J001.DefaultIPGateway0 = '10.10.18.1' then 'Canterbury Close'
		when J001.DefaultIPGateway0 = '10.10.21.1' then 'Salisbury Old Rectory'
		when J001.DefaultIPGateway0 = '10.10.19.1' then 'Elizabeth Mission'
		when J001.DefaultIPGateway0 = '10.10.26.1' then 'West Works'
		when J001.DefaultIPGateway0 = '10.10.35.1' then 'St Marys'
		when J001.DefaultIPGateway0 = '10.104.0.2' then 'Bridge View'
		when J001.DefaultIPGateway0 = '10.10.32.1' then 'Evolution'
		when J001.DefaultIPGateway0 = '10.10.10.1' then 'St Lukes'
		when J001.DefaultIPGateway0 = '10.10.11.1' then 'Moor Street'
		when J001.DefaultIPGateway0 = '10.10.23.1' then 'Miller Place'
		when J001.DefaultIPGateway0 = '10.10.17.1' then 'Gawler'
		when J001.DefaultIPGateway0 = '10.10.15.1' then 'Daphne Street'
		when J001.DefaultIPGateway0 = '10.10.33.1' then 'Wanslea'
		when J001.DefaultIPGateway0 = '10.10.11.1' then 'Carington Street'
		when J001.DefaultIPGateway0 = '10.100.0.1' then 'Western Hub'
		else ''
		end
	)'Site from SubNetMask'
from dbo.v_GS_COMPUTER_SYSTEM CS right join v_GS_PC_BIOS BIOS on BIOS.ResourceID = CS.ResourceID
	right join dbo.v_GS_SYSTEM SYS on SYS.ResourceID = CS.ResourceID
	right join dbo.v_GS_OPERATING_SYSTEM OS on OS.ResourceID = CS.ResourceID
	right join dbo.v_RA_System_SMSAssignedSites RAA on RAA.ResourceID = CS.ResourceID
	right join dbo.V_GS_X86_PC_MEMORY RAM on RAM.ResourceID = CS.ResourceID
	right join dbo.v_GS_Logical_Disk LDisk on LDisk.ResourceID = CS.ResourceID
	right join dbo.v_GS_Processor CPU on CPU.ResourceID = CS.ResourceID
	right join dbo.v_GS_SYSTEM_ENCLOSURE SE on SE.ResourceID = CS.ResourceID
	
	left outer join 
	(
	select
		Net.ResourceID
		,Net.DefaultIPGateway0
		,ROW_NUMBER() 
		over
		(
			Partition By Net.ResourceID 
			Order By
				Case
				when Net.DefaultIPGateway0 IS NOT NULL then '1'
				else '9'
				end
		)'RN'
		From dbo.v_Network_DATA_Serialized Net-- on Net.ResourceID = CS.ResourceID
	)J001 on J001.ResourceID = CS.ResourceID
	
where 
	1=1
	and LDisk.DriveType0 =3
	and J001.RN < 2

group by 
	CS.Name0 
	,CS.domain0
	,CS.Username0
	,BIOS.SerialNumber0
	,SE.SerialNumber0
	,CS.Manufacturer0
	,CS.Model0
	,OS.Caption0
	,RAA.SMS_Assigned_Sites0
	,RAM.TotalPhysicalMemory0
	,CPU.CurrentClockSpeed0
	,J001.DefaultIPGateway0

end