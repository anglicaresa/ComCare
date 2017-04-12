If(OBJECT_ID('tempdb.dbo.#MyTempTable') Is Not Null)
Begin
    Drop Table #MyTempTable
End

CREATE TABLE #MyTempTable (OrgNm VarChar(32));  
	INSERT INTO #MyTempTable VALUES ('All Hallows Court');
	INSERT INTO #MyTempTable VALUES ('Canterbury Close');
	INSERT INTO #MyTempTable VALUES ('Dutton Court');
	INSERT INTO #MyTempTable VALUES ('Grandview Court');
	INSERT INTO #MyTempTable VALUES ('Ian George Court');
	INSERT INTO #MyTempTable VALUES ('St Laurences Court');
	INSERT INTO #MyTempTable VALUES ('Disabilities Children');
	INSERT INTO #MyTempTable VALUES ('Disabilities Adult');

select 
	*
--	J001.Organisation_Name 
--	from [appsql-3\TRAIN].[ComCareTRAIN].[dbo].[Organisation] J001

from #MyTempTable
where
	1=1
--	and J001.Organisation_Name in ( select OrgNm from #MyTempTable)


If(OBJECT_ID('tempdb.dbo.#MyTempTable') Is Not Null)
Begin
    Drop Table #MyTempTable
End

/*
Transitional Care Program
Home Care West
Allied Health Services
Home Care South
Exceptional Needs
Home Care North
Disabilities Children
Home Care East
Home Care Barossa Yorke Peninsula
Disabilities Adult
AnglicareSA Corporate Office
Dutton Court
All Hallows Court
Canterbury Close
Ian George Court
St Laurences Court
Grandview Court
Anglicaresa Oats
*/