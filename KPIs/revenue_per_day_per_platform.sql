-- Revenue per Day per mobile Platform
-- Easily adaptable to show dollar revenue or add/adjust platforms
SELECT 
    event_date, 
    SUM(CASE WHEN platform LIKE 'ANDROID%' THEN revenue END) AS " Android revenueInPence", 
    count(DISTINCT(CASE WHEN platform LIKE 'ANDROID%' THEN user_id END)) AS "Android userCount", 
    sum(CASE WHEN platform LIKE 'IOS%' THEN revenue END) AS " iOS revenueInPence", 
    count(DISTINCT(CASE WHEN platform LIKE 'IOS%' THEN user_id END)) AS "iOS userCount"
FROM fact_user_sessions_day
WHERE 
    event_date BETWEEN CURRENT_DATE - 31 AND CURRENT_DATE
    AND event_date = player_start_date
GROUP BY event_date
ORDER BY event_date DESC;