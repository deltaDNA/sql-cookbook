--Find the last UiName per user and compare these for current players and players that haven't been playing for a while
WITH DATA AS
  (SELECT userId,
          eventTimestamp,
          first_value(UIName
                      IGNORE nulls) over (partition BY userId
                                          ORDER BY eventTimestamp) AS lastValue --get the first ever value backwards
FROM EVENTS
   WHERE sessionId IS NOT NULL --exclude non-gameplay events such as the sending of a notification
) ,aggregates AS
  (SELECT userId,
          max(eventTimestamp)::date AS last_seen_date,
          MAX (lastValue) AS lastUiName
   FROM DATA
   GROUP BY userId)
SELECT lastUiName,
       count(CASE
                 WHEN last_seen_date> CURRENT_DATE-7 THEN 1
                 ELSE NULL
             END) currentPlayers,
       count(CASE
                 WHEN last_seen_date< CURRENT_DATE-7 THEN 1
                 ELSE NULL
             END) lapsedPlayers
FROM aggregates
GROUP BY lastUiName
