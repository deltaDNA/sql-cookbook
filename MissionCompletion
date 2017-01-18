--Mission completion and drop off:
--First we select the users who start playing their first mission within scope
--then we add counters for all mission end events and mission start events.
--The sum of failed completed and abandoned should add up to be equal to the number of started
--this can be visualised by stacking them within data mining and getting a line of mission starts
WITH starters AS
  (SELECT userId
   FROM events
   WHERE missionId ='0'-- number of your first mission
     AND eventName = 'missionStarted')
SELECT missionId,
          missionName,
          count(CASE WHEN eventName = 'missionStarted' THEN 1 ELSE NULL END) AS started,
          count(CASE WHEN eventName = 'missionFailed' THEN 1 ELSE NULL END) AS failed,
          count(CASE WHEN eventName = 'missionCompleted' THEN 1 ELSE NULL END) AS completed,
          count(CASE WHEN eventName = 'missionAbandoned' THEN 1 ELSE NULL END) AS abandoned
   FROM events
   WHERE userId IN
       (SELECT userId
        FROM starters)
   AND eventLevel = 0
   AND missionId is not null
   GROUP BY missionId,
            missionName
ORDER BY CAST (missionId AS NUMERIC);
