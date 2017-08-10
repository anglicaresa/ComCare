select
*
from dbo.Activity_Work_Table where Provider_ID = 10012268 and cast(Activity_Date as date) between '2017-05-08' and '2017-05-21' 