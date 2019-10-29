SELECT min(CONVERT(BIGINT, SUB.RunTimeSeconds)) as Min, max(CONVERT(BIGINT, SUB.RunTimeSeconds)) as Max, 
FORMAT(COUNT(*), '#,0') as 'Count', CONVERT(time(0), 
DATEADD(SECOND, AVG(CONVERT(BIGINT, SUB.RunTimeSeconds)), 0)) as 'BCT hh:mm:ss' --,
,AVG(CONVERT(BIGINT, SUB.RunTimeSeconds)) as BCT_AvTimeSecs
 --, STDEVP(CONVERT(BIGINT, SUB.RunTimeSeconds)
FROM
(
select  
[RunTimeSeconds] 
		  FROM [NeptuneIntegration].[dbo].[Unit] as U WITH (NOLOCK)  
			join [dbo].[CorporateCalendar] as C WITH (NOLOCK) on U.UnitPartitionKey = C.CLDR_YYYYMMDD_VAL 
			WHERE 
				[RunTimeSeconds] >= 0				
) SUB
