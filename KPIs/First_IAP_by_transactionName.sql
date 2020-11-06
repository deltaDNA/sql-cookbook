--First deposit by transactionName
with transactions as (
select 
	userId, eventTimestamp,transactionName, convertedproductAmount, revenueValidated, 
	rank() over (partition by userid order by eventTimestamp) as transactionNumber
from events 
where convertedProductAmount>0 and revenueValidated in (0,1)
)
select
	transactionName,
	count(*) as "IAP count",
	sum(convertedproductAmount)/100::float as Revenue
from transactions
where transactionNumber = 1
group by transactionName
order by 2 desc
