select eventDate,
count(*)/count(distinct userId) as 'Events per DAU'
from events
group by eventDate 
order by eventDate desc
