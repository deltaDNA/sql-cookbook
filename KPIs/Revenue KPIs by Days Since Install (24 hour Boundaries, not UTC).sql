-- Get the KPI's in 24 hour intervals since install rather than UTC days
with data as (
  select e.userID
    , first_value(eventTimestamp) over (partition by userID order by eventTimestamp) as "firstEventTimestamp"
    -- Calculate the Day Number based on number of 24 hour blocks since timestamp on first event, (i.e. Not UTC day boundaries)
    , round(datediff(hh,first_value(eventTimestamp) over (partition by userID order by eventTimestamp),eventTimestamp) / 24 +1 ,2.0):: integer as DayNumber
    , e.eventTimestamp
    , e.eventName
    , e.platform
    , convertedProductAmount
    , revenueValidated
  from events e
    where e.eventName in ('newPlayer', 'gameStarted', 'transaction')
      and gaUserStartDate > CURRENT_DATE -31
)
select DayNumber
, count(distinct(case when platform like 'IOS%' then userID end )) as "iOS Users"
, count(distinct(case when platform like 'IOS%' and eventName = 'transaction' and revenueValidated in (0,1) and convertedProductAmount > 0 then userID end )) as "iOS Spenders"
, count(case when platform like 'IOS%' and eventName = 'transaction' and revenueValidated in (0,1) and convertedProductAmount > 0 then convertedProductAmount end ) as "iOS Purchases"
, sum(case when platform like 'IOS%' and eventName = 'transaction' and revenueValidated in (0,1) and convertedProductAmount > 0 then convertedProductAmount end ) as "iOS Revenue"
, count(distinct(case when platform like 'ANDROID%' then userID end )) as "Andorid Users"
, count(distinct(case when platform like 'ANDROID%' and eventName = 'transaction' and revenueValidated in (0,1) and convertedProductAmount > 0 then userID end )) as "Android Spenders"
, count(case when platform like 'ANDROID%' and eventName = 'transaction' and revenueValidated in (0,1) and convertedProductAmount > 0 then convertedProductAmount end ) as "Android Purchases"
, sum(case when platform like 'ANDROID%' and eventName = 'transaction' and revenueValidated in (0,1) and convertedProductAmount > 0 then convertedProductAmount end ) as "Android Revenue"
from data
group by DayNumber
order by DayNumber ;
