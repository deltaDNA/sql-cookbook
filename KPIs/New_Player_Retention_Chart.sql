with days_data as 
     (select user_id 
		, player_start_date as install_date
		, event_date 	
	from fact_user_sessions_day
	where player_start_date >= CURRENT_DATE - 30
	group by user_id, player_start_date, event_date
       )
, aggregated_data as
      ( select DATEDIFF ('day', install_date, event_date) as DaysSinceInstall 
        , count(distinct user_id) as UniqueUsers
        from days_data
        group by 1       
  )
select DaysSinceInstall, UniqueUsers 
 , ROUND(UniqueUsers / FIRST_VALUE(UniqueUsers) OVER (order by DaysSinceInstall) *100,2)::float as Percentage
from aggregated_data
order by DaysSinceInstall