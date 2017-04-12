use SCCM12_ANG
Begin
--select * from dbo.System_IP_Subnets_ARR --no good

select distinct ResourceID, DefaultIPGateway0 from dbo.v_Network_DATA_Serialized --seems too short
where DefaultIPGateway0 is not null

--select * from v_RA_System_SMSAssignedSites
end