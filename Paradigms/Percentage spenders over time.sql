-- Calculates the % of all players that are spenders. 
-- The first CTE pulls the date range
-- The second CTE pulls player start dates and first payment dates
-- The final part of the query pulls it all togteher
WITH dates AS
  ( SELECT DAY::date
     FROM
       (SELECT (CURRENT_DATE-30)::TIMESTAMP AS date_range
       UNION SELECT CURRENT_DATE::TIMESTAMP)AS ts timeseries DAY AS '1 days' over (ORDER BY date_range))
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