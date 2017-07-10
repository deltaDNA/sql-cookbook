--Get the total LTV (predicted smartads LTV + confirmed IAP LTV)
--Only works for data within data retention window, hence the gaUserStartDate filter.
--Keep in mind the predictedAdRevenue is only a prediction.
with data as (
	select 
		gaUserStartdate, 
		count(distinct userId) as userCount,
		sum(case when revenueValidated in (0,1) then convertedProductAmount/100 end) as IapRevenue, 
		sum(case when eventname = 'adClosed' and adstatus = 'Success' then  adEcpm/100000 end) as PredictedAdRevenue
	from events
	where gaUserStartDate>= (select min(eventDate) from events)
	group by gaUserStartdate)
select 
	gaUserStartDate as 'install date',
	round(IapRevenue/userCount,4)::float as 'IAP LTV',
	round(PredictedAdRevenue/userCount,4)::float as 'Predicted Ad LTV',
	round((PredictedAdRevenue+IapRevenue)/userCount,4)::float as 'total LTV'
from data
order by gaUserStartDate
