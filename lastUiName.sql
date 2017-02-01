with data as (select userId, eventTimestamp,
first_value(UIName ignore nulls) over (partition by userId order by eventTimestamp) as lastValue --get the first ever value backwards
from events
where sessionId is not null --exclude non-gameplay events such as the sending of a notification
)
,aggregates as (select userId, max(eventTimestamp)::date as last_seen_date, max (lastValue) as lastUiName
from data
group by userId
)
select lastUiName,
count(case when last_seen_date> current_date-7 then 1 else null end) currentPlayers,
count(case when last_seen_date< current_date-7 then 1 else null end) lapsedPlayers
from aggregates
group by lastUiName
