--In the data CTE we add the last known value for the parameter userLevel to all the other events and bring the interesting columns into scope
--Next we group all events and the data by the last known value for the userlevel and create the aggregates we are interested in.
WITH DATA AS
  (SELECT eventName,
          userId,
          last_value(userLevel IGNORE NULLS) over (partition BY userId
                                         ORDER BY eventId) AS current_level,
          eventDate,
          msSinceLastEvent
   FROM EVENTS)
SELECT coalesce(current_level, 0) AS LEVEL,--replace not known yet with level 0
        sum(msSinceLastEvent)/1000 AS "Seconds Spent On Level",
        count(DISTINCT userId) AS "Number of users",
        count(DISTINCT eventDate) AS "Total days spent",
        count(DISTINCT eventDate)/count(DISTINCT userId) AS "average days spent",
        sum(msSinceLastEvent)/1000/count(DISTINCT userId) AS "average seconds in game spent on level"
FROM DATA
GROUP BY current_level
ORDER BY current_level
