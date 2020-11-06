-- Show userCount, spenderCount, purchaseCount and revenue per platform per day since launch
-- Uses 24 hour time difference from timestamp rather than day difference from date
WITH data AS (
    SELECT 
        e.userid, 
        First_value(eventtimestamp) over (PARTITION BY userid ORDER BY eventtimestamp) AS "firstEventTimestamp",
        ROUND(Datediff(hh, First_value(eventtimestamp) OVER (PARTITION BY userid ORDER BY eventtimestamp), eventtimestamp) / 24 + 1, 2.0) :: INTEGER AS DayNumber, 
        e.eventtimestamp, 
        e.eventname, 
        e.platform, 
        convertedproductamount, 
        revenuevalidated 
    FROM events e 
    WHERE 
        e.eventname IN ( 'newPlayer', 'gameStarted', 'transaction' ) 
        AND gauserstartdate > current_date - 31) 
SELECT daynumber, 
   COUNT(DISTINCT(CASE WHEN platform LIKE 'IOS%' THEN userid END)) AS "iOS Users", 
   COUNT(DISTINCT(CASE WHEN platform LIKE 'IOS%' 
                        AND eventname = 'transaction' 
                        AND revenuevalidated IN ( 0, 1 ) 
                        AND convertedproductamount > 0 THEN userid END)) AS "iOS Spenders", 
   COUNT(CASE WHEN platform LIKE 'IOS%' 
                AND eventname = 'transaction' 
                AND revenuevalidated IN ( 0, 1 ) 
                AND convertedproductamount > 0 THEN convertedproductamount END) AS "iOS Purchases", 
   SUM(CASE WHEN platform LIKE 'IOS%' 
              AND eventname = 'transaction' 
              AND revenuevalidated IN ( 0, 1 ) 
              AND convertedproductamount > 0 THEN convertedproductamount END) AS "iOS Revenue", 
   COUNT(DISTINCT(CASE WHEN platform LIKE 'ANDROID%' THEN userid END)) AS "Android Users", 
   COUNT(DISTINCT(CASE WHEN platform LIKE 'ANDROID%' 
                        AND eventname = 'transaction' 
                        AND revenuevalidated IN ( 0, 1 ) 
                        AND convertedproductamount > 0 THEN userid END)) AS "Android Spenders", 
   COUNT(CASE WHEN platform LIKE 'ANDROID%' 
                AND eventname = 'transaction' 
                AND revenuevalidated IN ( 0, 1 ) 
                AND convertedproductamount > 0 THEN convertedproductamount END) AS "Android Purchases", 
   SUM(CASE WHEN platform LIKE 'ANDROID%' 
            AND eventname = 'transaction' 
            AND revenuevalidated IN ( 0, 1 ) 
            AND convertedproductamount > 0 THEN convertedproductamount END) AS "Android Revenue" 
FROM   data 
GROUP  BY daynumber 
ORDER  BY daynumber; 