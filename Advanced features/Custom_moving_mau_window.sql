--In this query we create a time slice by extrapolating the days between two fixed dates
--this is then joined onto the user activity of x days in the past. And next we count the unique number of users .
WITH dates AS (
SELECT DISTINCT EVENTDATE AS DAY
FROM events
WHERE EVENTDATE BETWEEN current_date - 30 AND current_date),
     activity AS
  (SELECT DISTINCT event_date,
                   user_id
   FROM fact_user_sessions_day
   WHERE event_date> CURRENT_DATE -62)
SELECT DAY,
       count(DISTINCT user_id)
FROM dates d
FULL OUTER JOIN activity a ON a.event_date BETWEEN d.day-30 AND d.day
WHERE DAY IS NOT NULL
GROUP BY DAY
ORDER BY DAY
