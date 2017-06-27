--ARPDAU, Average Revenue Per Daily Active User
--specifically for currencies with an exponent of 2.
select event_date,
round(sum(revenue)/100/count(distinct user_id),4)::float as ARPDAU
from fact_user_sessions_day
where event_date between current_date -30 and current_date
group by event_date
order by event_date desc;
