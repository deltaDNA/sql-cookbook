--Select the total revenue per user and use that to calculate the percentage spenders
--This number is in the default measure charts but this could count as a basis for a different query
with data as (select user_Id, sum(revenue) as rv
from fact_user_sessions_day
group by 1
)
select 
count(case when rv=0 then 1 else null end) as nonspenders,
count(nullif(rv,0))as Spenders, 
count(*) as totalUsers,
round(count(nullif(rv,0))/sum(case when rv=0 then 1 else null end)*100, 4.0) as percentageSpending
from data
