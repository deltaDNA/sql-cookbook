--Get the median and average session times
--The median times can only be retrieved in an analytic function
WITH DATA AS
  (SELECT min(eventDate) AS eventDate,
          sessionId,
          userId,
          sum(msSinceLastEvent) AS sessionDurationMs,
          count(*)AS eventCount
   FROM EVENTS
   GROUP BY sessionId,
            userId) ,medianValues as
  (SELECT *, MEDIAN(sessionDurationMs) OVER (PARTITION BY eventDate) AS medianSessionTime
   FROM DATA
   WHERE eventCount>1-- exclude sessions with just one event
)
SELECT eventDate,
       round(avg(sessionDurationMs)/1000,2.0) AS "Mean session time in seconds",
       (avg(sessionDurationMs)::varchar||"ms")::interval AS "Mean session time as interval",
       round(medianSessionTime/1000, 2.0) AS "Medain session time in seconds",
       (medianSessionTime::varchar||'ms')::interval AS "Median session time as interval",
       count(DISTINCT userId) AS "Sample size users",
       count(DISTINCT sessionId) AS "Sample size sessions"
FROM medianValues
GROUP BY eventDate,
         medianSessionTime
ORDER BY eventDate DESC
