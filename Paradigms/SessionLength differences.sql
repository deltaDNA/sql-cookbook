--In older SDK's the session lengths can be very long if an app has been backgrounded. As of 4.1 we have limited the background time to a maximum of 5 minutes, after backgrounding an app for more than 5 minutes a new session will be started.
--This query applies to older SDK's and compares the difference between sessions where we exclude any gaps longer than 5 minutes
WITH DATA AS
  (SELECT sessionId,
          sum(msSinceLastEvent)AS sessionLength,
          sum(CASE
                  WHEN msSinceLastEvent < 300000 THEN msSinceLastEvent
                  ELSE NULL
              END)AS compensatedSessionLength,
          count(*) AS eventCount
   FROM EVENTS
   GROUP BY sessionId)
SELECT sessionId,
       (sessionLength|| ' ms')::interval AS sessionLength,
       (compensatedSessionLength|| ' ms')::interval AS compensatedSessionLength,
       eventCount
FROM DATA
