--In this query we create a time slice and then join all daily activity back on the event to generate a moving window.
WITH dates AS
  (SELECT DAY::date
   FROM
     (SELECT (CURRENT_DATE-30)::TIMESTAMP AS date_range
      UNION SELECT CURRENT_DATE::TIMESTAMP)AS ts timeseries DAY AS '1 days' over (
                                                                                  ORDER BY date_range)),
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
