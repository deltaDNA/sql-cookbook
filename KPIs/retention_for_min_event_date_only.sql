with DATA AS
  ( SELECT min(event_date) as event_date,
           player_start_date,
           user_id,
           DATEDIFF(DAY,player_start_date,min(event_date)) AS N
   FROM fact_user_sessions_day
where DATEDIFF(DAY,player_start_date,current_date)<36
group by player_start_date,
           user_id, session_Id
), retention AS
  ( SELECT player_start_date,
           COUNT (DISTINCT CASE WHEN n = 0 THEN user_id ELSE NULL END)AS installs,
           COUNT (DISTINCT CASE WHEN n = 1 THEN user_id ELSE NULL END)AS "day 1 retention",
           COUNT (DISTINCT CASE WHEN n = 7 THEN user_id ELSE NULL END)AS "day 7 retention",
           COUNT (DISTINCT CASE WHEN n = 14 THEN user_id ELSE NULL END)AS "day 14 retention",
           COUNT (DISTINCT CASE WHEN n = 30 THEN user_id ELSE NULL END)AS "day 30 retention"
   FROM DATA
   GROUP BY player_start_date)
SELECT *,
round("day 1 retention"/"installs"*100,2.0) as "D1%",
round("day 7 retention"/"installs"*100,2.0) as "D7%",
round("day 14 retention"/"installs"*100,2.0) as "D14%",
round("day 30 retention"/"installs"*100,2.0) as "D30%"
FROM retention
ORDER BY player_start_date DESC

