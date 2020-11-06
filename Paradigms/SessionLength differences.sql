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
  case -- format time as an interval
		when sessionTime < 0 then '-' || TO_CHAR(TRUNC(ABS(sessionLength)/ 3600000), 'FM9900') || ':' || 
    TO_CHAR(TRUNC(mod(ABS(sessionLength), 3600000)/ 60000), 'FM00') || ':' || 
    TO_CHAR(TRUNC(mod(ABS(sessionLength), 60000)/ 1000), 'FM00') || '.' || 
    TO_CHAR(mod(ABS(sessionLength), 1000), 'FM000')
		else TO_CHAR(TRUNC(sessionLength/ 3600000), 'FM9900') || ':' || 
    TO_CHAR(TRUNC(mod(sessionLength, 3600000)/ 60000), 'FM00') || ':' || 
    TO_CHAR(TRUNC(mod(sessionLength, 60000)/ 1000), 'FM00') || '.' || 
    TO_CHAR(mod(sessionLength, 1000), 'FM000') end AS sessionLength,
  case
    when compensatedSessionLength < 0 then '-' || TO_CHAR(TRUNC(ABS(compensatedSessionLength)/ 3600000), 'FM9900') || ':' || 
    TO_CHAR(TRUNC(mod(ABS(compensatedSessionLength), 3600000)/ 60000), 'FM00') || ':' || 
    TO_CHAR(TRUNC(mod(ABS(compensatedSessionLength), 60000)/ 1000), 'FM00') || '.' || 
    TO_CHAR(mod(ABS(compensatedSessionLength), 1000), 'FM000')
		else TO_CHAR(TRUNC(compensatedSessionLength/ 3600000), 'FM9900') || ':' || 
    TO_CHAR(TRUNC(mod(compensatedSessionLength, 3600000)/ 60000), 'FM00') || ':' || 
    TO_CHAR(TRUNC(mod(compensatedSessionLength, 60000)/ 1000), 'FM00') || '.' || 
    TO_CHAR(mod(compensatedSessionLength, 1000), 'FM000') end AS compensatedSessionLength,
       eventCount
FROM DATA
