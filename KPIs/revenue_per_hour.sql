/* Get the timestamp and round it down to the hour,
then get the revenue for this hour, the total number of users as well as the total number of spenders within this window.
*/
select date_trunc('hour', eventTimestamp) as time,
to_char(sum(convertedproductamount)/100, '"$"999,999,999,999.00') as revenue,
count(distinct userid) active_users,
count(distinct case when convertedproductamount>0 then userId end) as spenders
from events
where revenuevalidated not in (2,3)
and eventName in ('gameStarted', 'transaction')
and eventTimestamp between current_timestamp() - interval '100 hours' and current_timestamp()
group by 1 order by 1 desc
