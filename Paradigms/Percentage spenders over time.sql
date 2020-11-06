-- Calculates the % of all players that are spenders. 
-- The first CTE pulls the date range
-- The second CTE pulls player start dates and first payment dates
-- The final part of the query pulls it all togteher
WITH dates AS (
SELECT DISTINCT EVENTDATE AS DAY
FROM events
WHERE EVENTDATE BETWEEN current_date - 30 AND current_date),
, players AS 
  ( SELECT user_id
     , MIN(event_date) as startDate
     , MIN(case when revenue > 0 then event_date end) as firstPaymentDate 
    FROM fact_user_sessions_day 
    GROUP BY user_id)
SELECT DAY
  , count(DISTINCT p.user_id) AS Players
  , count(DISTINCT case when p.firstPaymentDate <= DAY then p.user_id end) as Payers
  , ROUND((count(DISTINCT case when p.firstPaymentDate <= DAY then p.user_id end) / count(DISTINCT p.user_id))*100,2) AS "% Spenders"
FROM dates d
  LEFT JOIN players p on p.startDate <= d.day
WHERE DAY IS NOT NULL 
GROUP BY DAY
ORDER BY DAY;