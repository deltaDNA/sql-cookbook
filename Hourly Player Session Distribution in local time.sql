--Get number of active users per hour based on the local timestamp.
with firstValues as (
	select userId
		, eventTimestamp as startTs
		, min(timezoneOffset)tzo 
	from events	
	where eventName = 'gameStarted'	
	group by userId, eventTimestamp)
, results as (
	select userID
		, TIMESTAMPADD(minute, case when CHAR_LENGTH(TZO)=5 then CAST(substring(tzo, 1,1)||'1' as INTEGER) *-- get positive vs negative tzoffset
			(CAST(substring(tzo, 2,2) as INTEGER)*60 + cast(substring(tzo, 4,2) as INTEGER)) else null --get tzoffset in minutes
			end	,startTs )as localEventTimestamp
	from firstValues)
select date_part('hour', localEventTimestamp) as LocalHour 
	, count(distinct userID) as UniqueUsers
from results
where  localEventTimestamp is not null
group by 1
order by 1
