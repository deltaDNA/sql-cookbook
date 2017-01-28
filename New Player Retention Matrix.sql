----------------------------
-- New Player Retention Matrix
with days_data as 
	(select user_id 
		, player_start_date as install_date
		, event_date 	
	from fact_user_sessions_day
	where player_start_date >= CURRENT_DATE - 30
	group by user_id, player_start_date, event_date
	)
select install_date
 	, NULLIFZERO (count (distinct case when event_date - install_date = 0 then user_id else null end)) as "installs"
	, NULLIFZERO (count (distinct case when event_date - install_date = 1 then user_id else null end)) as "1"
	, NULLIFZERO (count (distinct case when event_date - install_date = 2 then user_id else null end)) as "2"
	, NULLIFZERO (count (distinct case when event_date - install_date = 3 then user_id else null end)) as "3"
	, NULLIFZERO (count (distinct case when event_date - install_date = 4 then user_id else null end)) as "4"
	, NULLIFZERO (count (distinct case when event_date - install_date = 5 then user_id else null end)) as "5"
	, NULLIFZERO (count (distinct case when event_date - install_date = 6 then user_id else null end)) as "6"
	, NULLIFZERO (count (distinct case when event_date - install_date = 7 then user_id else null end)) as "7"
	, NULLIFZERO (count (distinct case when event_date - install_date = 8 then user_id else null end)) as "8"
	, NULLIFZERO (count (distinct case when event_date - install_date = 9 then user_id else null end)) as "9"
	, NULLIFZERO (count (distinct case when event_date - install_date = 10 then user_id else null end)) as "10"
	, NULLIFZERO (count (distinct case when event_date - install_date = 11 then user_id else null end)) as "11"
	, NULLIFZERO (count (distinct case when event_date - install_date = 12 then user_id else null end)) as "12"
	, NULLIFZERO (count (distinct case when event_date - install_date = 13 then user_id else null end)) as "13"
	, NULLIFZERO (count (distinct case when event_date - install_date = 14 then user_id else null end)) as "14"
	, NULLIFZERO (count (distinct case when event_date - install_date = 21 then user_id else null end)) as "21"
	, NULLIFZERO (count (distinct case when event_date - install_date = 30 then user_id else null end)) as "30"
from days_data
	where CURRENT_DATE - event_date between 0 and 30
group by 1
order by 1 desc