--average mission length
--In the first CTE missions we add a counter to keep track of the mission try we are in which is upped after the start of a mission and after the end of a mission (hence the DESC order in the over clause)
--In the second CTE we add up the time for each missionGroup.
--In the select query we take only the missionCompletedEvent and select the time it took from starting the mission to completing it.
WITH missions AS
  (SELECT userId,
          sessionId,
          eventName,
          missionId,
          userLevel,
          eventTimestamp,
          msSinceLastEvent,
          count(CASE WHEN eventName IN('missionCompleted', 'missionStarted') THEN 1 ELSE NULL END) over (partition BY userID
                                                                                                         ORDER BY eventTimestamp DESC) missionGroup
   FROM events), missionCompletedEvents AS
  (SELECT userId,
          missionGroup,
          missionID,
          sum(msSinceLastEvent) over (partition BY missionGroup, userId
                                      ORDER BY eventTimestamp)AS MissionCompletedTime
   FROM missions
   WHERE eventName = 'missionCompleted')
SELECT missionID,
       avg(missionCompletedTime)/1000 AS AverageMissionTimeInSeconds
FROM missionCompletedEvents
GROUP BY missionID
ORDER BY cast(missionId AS NUMERIC)
