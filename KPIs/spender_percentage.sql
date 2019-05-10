/*Gets the number of players who have ever spent and the number of players active.
*/
with dailyAggregates as (
select  event_date, 
        user_id, 
        sum(revenue) as revenue,
        sum(sum(revenue)) over (partition by user_id order by event_date) as cumulative_revenue
from fact_user_sessions_day
group by event_date, user_id
)
select  event_date,
        count(distinct user_id) as DAU,
        count(distinct case when revenue>0 then user_id end) as spenders_today,
        count(distinct case when revenue>0 then user_id end)/count(distinct user_id) as percentage_spending_today,
        count(distinct case when cumulative_revenue>0 then user_id end) as active_spenders,
        count(distinct case when cumulative_revenue>0 then user_id end)/count(distinct user_id) as percentage_spenders_active
from  dailyAggregates   
group by 1
order by 1 desc
