--get the number of users who were in a session at a given timeslot:
with timeslots as(
	select
		slice_time
	from
		(			
                select current_timestamp()-interval '6 hours' as date_range
		union
                select current_timestamp()
		) as ts timeseries slice_time as '1 minutes' over(order by date_range)
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
