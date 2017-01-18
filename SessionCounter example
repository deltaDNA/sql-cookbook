--add a session counter to all events and use that to show the totals per xth session.
WITH DATA AS
  (SELECT eventName,
          userId,
          sessionId,
          CONDITIONAL_CHANGE_EVENT(sessionid) over (partition BY userId
                                                    ORDER BY eventTimestamp) AS sessionCounter
   FROM events
   WHERE userId IN
       (SELECT userId
        FROM events
        WHERE eventname = 'newPlayer')--added to remove sessions from people that started playing outside of data retention window
)
SELECT eventName,
       count(*) AS events,
       count(DISTINCT userId) AS users,
       round(count(*) / count(DISTINCT userId),2.0) AS 'ev per user in first session'
FROM DATA
WHERE sessionCounter = 0
GROUP BY eventName



