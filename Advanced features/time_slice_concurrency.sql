--concurrent users in data
--create a dataset with timestamps between two points at regular intervals
--join sessions on these intervals if they start before and end after this point in time.
--Count the number of sessions on these intervals.
with timeslots as (
SELECT DISTINCT TIME_SLICE(EVENTTIMESTAMP, 10, 'MINUTE') AS slice_time
FROM events
WHERE EVENTTIMESTAMP BETWEEN CURRENT_TIMESTAMP - INTERVAL '10 day' AND CURRENT_TIMESTAMP
	),
sessions as (
select userid, sessionid, min(eventTimestamp) as sessionStart, max(eventTimestamp) as sessionEnd
	FROM  events
	WHERE eventTimestamp between  (CURRENT_DATE-10) and  now()
	and sessionId is not null
	group by 1,2)
select 
slice_time as time, 
count(sessionId) as activeSessions
from timeslots as ts
left join sessions s
on ts.slice_time >s.sessionStart and ts.slice_time < s.sessionEnd
group by ts.slice_time
order by ts.slice_time desc;
