--Get the median and average session times
--The median times can only be retrieved in an analytic function
with data as (
select
	min(eventDate) as eventDate,
	sessionId,
	userId,
	sum(msSinceLastEvent) as sessionDurationMs,
	count(*)as eventCount
from
	EVENTS
group by
	sessionId,
	userId) ,
medianValues as (
select
	*,
	MEDIAN(sessionDurationMs) over (partition by eventDate) as medianSessionTime
from
	data
where
	eventCount>1
	-- exclude sessions with just one event
)
select
	eventDate,
	round(avg(sessionDurationMs)/ 1000, 2.0) as "Mean session time in seconds",
	case -- format time into an interval
		when avg(sessionDurationMs) < 0 then '-' || TO_CHAR(TRUNC(ABS(avg(sessionDurationMs))/ 3600000), 'FM9900') || ':' || 
    TO_CHAR(TRUNC(mod(ABS(avg(sessionDurationMs)), 3600000)/ 60000), 'FM00') || ':' || 
    TO_CHAR(TRUNC(mod(ABS(avg(sessionDurationMs)), 60000)/ 1000), 'FM00') || '.' || 
    TO_CHAR(mod(ABS(avg(sessionDurationMs)), 1000), 'FM000')
		else TO_CHAR(TRUNC(avg(sessionDurationMs)/ 3600000), 'FM9900') || ':' || 
    TO_CHAR(TRUNC(mod(avg(sessionDurationMs), 3600000)/ 60000), 'FM00') || ':' || 
    TO_CHAR(TRUNC(mod(avg(sessionDurationMs), 60000)/ 1000), 'FM00') || '.' || 
    TO_CHAR(mod(avg(sessionDurationMs), 1000), 'FM000') end as "Mean session time as interval",
	round(medianSessionTime / 1000, 2.0) as "Medain session time in seconds",
	case
		when medianSessionTime < 0 then '-' || TO_CHAR(TRUNC(ABS(medianSessionTime)/ 3600000), 'FM9900') || ':' || 
    TO_CHAR(TRUNC(mod(ABS(medianSessionTime), 3600000)/ 60000), 'FM00') || ':' || 
    TO_CHAR(TRUNC(mod(ABS(medianSessionTime), 60000)/ 1000),
		'FM00') || '.' || TO_CHAR(mod(ABS(medianSessionTime), 1000), 'FM000')
		else TO_CHAR(TRUNC(medianSessionTime/ 3600000), 'FM9900') || ':' || 
    TO_CHAR(TRUNC(mod(medianSessionTime, 3600000)/ 60000), 'FM00') || ':' || 
    TO_CHAR(TRUNC(mod(medianSessionTime, 60000)/ 1000), 'FM00') || '.' || 
    TO_CHAR(mod(medianSessionTime, 1000), 'FM000') end as "Median session time as interval",
	count(distinct userId) as "Sample size users",
	count(distinct sessionId) as "Sample size sessions"
from
	medianValues
group by
	eventDate,
	medianSessionTime
order by
	eventDate desc
