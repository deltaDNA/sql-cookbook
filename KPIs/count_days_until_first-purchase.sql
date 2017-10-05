-- Count of Days Until First Purchase
WITH userPurchases AS (
    SELECT
        user_id,
        datediff(day, player_start_date, event_date) daysSinceInstall,
        row_number() OVER (PARTITION BY user_id ORDER BY event_date) spendNumber
    FROM fact_user_sessions_day
    WHERE revenue > 0
)

SELECT 
    daysSinceInstall AS daysUntilFirstPurchase, 
    COUNT(DISTINCT user_id) AS userCount
FROM userPurchases
WHERE spendNumber = 1 AND daysSinceInstall >= 0
GROUP BY daysSinceInstall
ORDER BY daysSinceInstall ASC