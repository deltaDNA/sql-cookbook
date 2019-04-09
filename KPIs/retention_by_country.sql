with retention_data as (
	select
		user_country, 
		count(distinct user_id)as installs, 
		count(distinct case when event_date-player_start_date = 7 then user_id end) as retainedD7 
	from fact_user_sessions_day
	where user_country is not null
	and player_start_date < current_date -7
	group by user_country
)
select *, retainedD7/installs as d7Retention
from retention_data
order by retainedD7/installs desc
