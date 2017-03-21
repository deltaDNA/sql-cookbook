--count sessionLength in last 2 weeks and then band the results.
WITH sessionData as
  (SELECT userId, sessionID, sum(msSinceLastEvent) AS duration, count(*)AS eventCount
   FROM EVENTS
   WHERE eventDate> CURRENT_DATE-14-- only last 10 days
GROUP BY userId, sessionID)
SELECT round(duration/60000/5,0.0)*5 AS durationBandMinutes, --divide by 5 minutes, round, and then multiply by 5
count(*)
FROM sessionData
WHERE duration IS NOT NULL
GROUP BY 1
ORDER BY 1
