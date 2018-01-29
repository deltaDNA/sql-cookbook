-- User churn and rolling retention based on Day 28
-- Rolling retention is the inverse of churn.
-- Keep in mind that new data can come in and churn will go down over time.
with activity_data as (select 
	player_start_date, event_date, 
	event_date-player_start_date as n,
	user_id
	from fact_user_sessions_day 
	group by player_start_date, event_date, user_id
)
select 
	player_start_date, 
	count(distinct user_id) as installs,
	count(distinct case when N>=28 then user_id end) as d28Retained,
	count(distinct case when N>=28 then user_id end)/count(distinct user_id) * 100 as d28RollingRetention,
	100-(count(distinct case when N>=28 then user_id end)/count(distinct user_id) * 100) as d28Churn
from activity_data
where player_start_date > current_date -60 and event_date > current_date -60
group by player_start_date
order by player_start_date
