--Get the average number of seconds between events in the first 5 minutes of gameplay.
WITH first_day_events AS
  (SELECT userId,
          eventName,
          msSinceLastEvent,
          min(eventTimestamp) over (partition BY userId
                                    ORDER BY eventId) AS startTimeStamp,
          eventTimestamp
   FROM EVENTS
   WHERE eventDate = gaUserStartDate
     AND sessionID IS NOT NULL),
     firstMinutes AS
  (SELECT userId,
          msSinceLastEvent
   FROM first_day_events
   WHERE eventTimestamp - startTimeStamp<=interval '5 minute'-- check first 5 minutes
)
SELECT avg(msSinceLastEvent/1000)AS 'Average number of seconds between events'
FROM firstMinutes
ORDER BY 1 DESC
