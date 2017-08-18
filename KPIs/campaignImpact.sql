with sends as(
select userid
,eventdate
,campaignName
,communicationState
,eventtimestamp as sendtime
from events
where eventname = 'outOfGameSend'
and campaignName !=''
)
,gameStarts as(
select userid
,eventtimestamp as startTime
from events
where eventname = 'gameStarted'
)
,missionStarts as(
select userid
,eventtimestamp as missionTime
from events
where eventname = 'missionStarted'
)
,IAPs as(
select userid
,eventtimestamp as iapTime
from events
where convertedProductAmount > 0 and revenueValidated < 2
)
,sendOpens as(
select g.userid
,eventdate
,campaignName
,sendTime
,communicationState
,min(sendTime) as nextLogin
,min(missionTime) as nextMission
,min(iapTime) as nextIAP
from sends s left join gameStarts g on s.userid = g.userid and sendTime between startTime and startTime + interval '24 HOURS'
left join missionStarts m on s.userid = m.userid and missionTime between startTime and startTime + interval '24 HOURS'
left join IAPs i on s.userid = i.userid and iapTime between startTime and startTime + interval '24 HOURS'
group by g.userid,eventdate,campaignName,sendTime,communicationState
)
select eventDate
,campaignName
,count(distinct userid) as Delivery
--,count(distinct case when communicationState = 'SENT' then userid end) as Sends
,count(distinct case when communicationState = 'FAIL' then userid end) as Bounces
,count(distinct case when communicationState = 'SENT'and timestampdiff(HH,nextLogin,sendTime) < 24 then userid end) "App Open"
,count(distinct case when communicationState = 'SENT'and timestampdiff(HH,nextMission,sendTime) < 24 then userid end) "Game Play"
,count(distinct case when communicationState = 'SENT'and timestampdiff(HH,nextIAP,sendTime) < 24 then userid end) "IAP"
from sendOpens
group by eventDate,campaignName
order by eventDate desc,campaignName
