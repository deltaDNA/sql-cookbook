with timeslots as(
	SELECT DISTINCT TIME_SLICE(EVENTTIMESTAMP, 1, 'MINUTE') AS slice_time
FROM events
WHERE EVENTTIMESTAMP BETWEEN CURRENT_TIMESTAMP - INTERVAL '6 hour' AND CURRENT_TIMESTAMP
), data as(
select userId, sessionId, min(eventTimestamp)startTime, max(eventTimestamp)endTime
from events where eventTimestamp between current_timestamp()-interval '6 hours' and current_timestamp()
group by 1,2
)
select slice_time, count(distinct userId) from timeslots ts
left join data d
on ts.slice_time between d.startTime and d.endTime
group by slice_time
order by slice_time desc