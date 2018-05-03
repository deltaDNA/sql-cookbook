
with user_windows as (
select user_id
, trunc(event_Date, 'D')::Date as week_commencing
, datediff(day,trunc(event_Date, 'D'),lead(trunc(event_Date, 'D'),1) over (partition by user_id order by trunc(event_Date, 'D'))) next_week 
, datediff(day,trunc(event_Date, 'D'),lag(trunc(event_Date, 'D'),1) over (partition by user_id order by trunc(event_Date, 'D'))) last_week
, min( trunc(player_start_date, 'D'))  as first_week
from fact_user_sessions_day
where event_date > current_date - interval '90 days' 
group by user_id, trunc(event_Date, 'D')
order by week_commencing
)
select (case when first_week=week_commencing or last_week=-14 then week_commencing else week_commencing+interval '7 days' end)::Date as w
, sum(case when next_week=7  and first_week!=week_commencing then 1 else 0 end) current
, sum(case when coalesce(next_week,0)!=7  and first_week!=week_commencing then -1 else 0 end) churned
, sum(case when first_week=week_commencing then 1 else 0 end) new_players
, sum(case when last_week = -14 then 1 else 0 end) returning
from user_windows
where week_commencing<current_date - interval '7 days'
group by w
order by w
