/* get the date of the first payment and count the number of users */
select  firstPaymentTimestamp::date as spend_date, 
        count(*) as spenders
from user_metrics
where firstPaymentTimestamp is not null
group by 1 
order by 1 desc
