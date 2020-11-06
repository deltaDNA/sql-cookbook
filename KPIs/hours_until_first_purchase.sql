-- Hours Until First Purchase and Revenue of that Purchase
-- Gets all transactions that are transaction, newPlayer or gameStarted
-- Gets the hour difference between the first event and the first transaction event 
WITH transactions AS (
    SELECT 
        userid, 
        eventid, 
        eventlevel, 
        eventtimestamp, 
        First_value(eventtimestamp) OVER (PARTITION BY userid ORDER BY eventid) AS firstEventTimestamp, 
        eventname, 
        revenuevalidated, 
        convertedproductamount, 
        COUNT(convertedproductamount) OVER (PARTITION BY userid ORDER BY eventid) AS transactionNumber 
    FROM events 
    WHERE 
        eventname IN ( 'transaction', 'newPlayer', 'gameStarted' ) 
        AND gauserstartdate > (SELECT Min(eventtimestamp) FROM   EVENTS)
) 
SELECT 
    userid AS userId, 
    firsteventtimestamp AS userFirstSeen, 
    eventtimestamp AS firstPurchaseTimestamp, 
    Datediff('hour', firsteventtimestamp, eventtimestamp) AS hoursSinceInstall, 
    ROUND(convertedproductamount / 100, 2.0) :: FLOAT AS "Revenue USD" 
FROM transactions 
WHERE  
    eventname = 'transaction' 
    AND transactionnumber = 1 
    AND revenuevalidated IN ( 0, 1 ) 
    AND convertedproductamount IS NOT NULL 
ORDER  BY 
    userid, 
    eventid, 
    transactionnumber; 