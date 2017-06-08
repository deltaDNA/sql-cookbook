with data as (
	select 
		userId, 
		realcurrencyAmount,
		rank() over (partition by userId order by eventId) as transactionNumber
	from events
	where gaUserStartDate > (select min(eventDate) from events)--only get starters within time window
	and revenueValidated in (0,1)
	and realcurrencyAmount is not null
)
,userData as (
	select
		userId, 
		min(case when transactionNumber =1 then realcurrencyAmount end) as firstTransaction, 
		min(case when transactionNumber =2 then realcurrencyAmount end) as secondTransaction
	from data
	group by userId)
select
	firstTransaction,
	secondTransaction,
	count(*) as users
from userData
group by firstTransaction,secondTransaction
order by firstTransaction,secondTransaction

