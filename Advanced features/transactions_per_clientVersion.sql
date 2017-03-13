--Since the clientVersion is sent in on the gameStarted event at the start of every session but not on each event we can't just filter events by clientVersion in one go.
--However we can extrapolate the clientVersion using an analytic function (with the OVER statement)
with data as (
select last_value(clientVersion ignore nulls) over (partition by userId order by eventId) as currentClientversion
,userId
,eventTimestamp
,eventName
,realCurrencyAmount
,realCurrencyType
,convertedProductAmount
from events
where clientVersion is not null
or eventName = 'transaction')
select *
from data
where eventName = 'transaction'
