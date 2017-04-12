
use ComCareProd

Select * From [dbo].Organisation
where
left([Organisation_Name], 9) = 'Home Care'