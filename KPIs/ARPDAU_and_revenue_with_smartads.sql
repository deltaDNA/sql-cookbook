--arpdau and revenue for IAP and SmartAds revenue
--This query only works if the default currency of your game is USD
--Keep in mind that the SmartAds revenue is an estimate based on previous performance.
select eventdate,
round(
    (sum(convertedproductAmount)+sum(adEcpm/1000))/100/count(distinct userid)
,4)::float as ARPDAU,
(sum(convertedproductAmount)+sum(adEcpm)/1000)/100::float as "revenue for both IAP and SmartAds"
from events
where eventdate between current_date -30 and current_date
group by eventdate
order by eventdate desc
