--get all the messages sent in a certain step on a certain day and link these to the convertsion events in a (gamestarted) in the following 7 days
--measure occurence per day for campaign
with in_campaign as (
select userID, 
eventDate,
COALESCE(stepID,1) as stepID,
min(eventTimestamp) as stepTime, 
count(userID) over (partition by COALESCE(stepID,1), eventDate order by min(eventTimestamp)) as total_participants
from events
where eventName = "outOfGameSend"
and communicationState = "SENT"
and campaignID = 100--the ID of the campaign
and stepType = "STANDARD"
group by userID, COALESCE(stepID,1), eventDate
)
select c.stepTime::date as "Date", c.stepID AS Step, max(total_participants) as Participants, count(distinct e.userID) as "Occurred", round(count(distinct e.userID)/max(total_participants)*100,2)::float as "%Occurrence"
from in_campaign c left join events e on e.userID = c.userID 
and e.eventTimestamp > c.stepTime 
and e.eventTimestamp < c.stepTime + interval "7 day"
and e.eventName = "gameStarted"
group by c.stepID, c.stepTime::date
order by c.stepTime::date, c.stepID, Participants
