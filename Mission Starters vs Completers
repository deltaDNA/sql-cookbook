--Mission starts vs mission completes, this query shows what percentage of players get stuck or churn on a mission.
--Stack the starts but not completing players together with the players completing a mission and you will see the part of the total
WITH DATA AS
  (SELECT userId,
          missionName,
          eventName,
          max(CASE WHEN eventName = 'missionStarted' THEN 1 ELSE NULL END) over (partition BY userId, missionName) AS missionStartedFlag,
          max(CASE WHEN eventName = 'missionCompleted' THEN 1 ELSE NULL END) over (partition BY userId, missionName) AS missionCompletedFlag
   FROM events
   WHERE missionName IS NOT NULL), nonCompletionData AS
  (SELECT missionName,
          count(DISTINCT CASE WHEN missionStartedFlag THEN userId ELSE NULL END) AS players,
          count(DISTINCT CASE WHEN missionStartedFlag = 1
                AND missionCompletedFlag = 1 THEN userId ELSE NULL END) AS completedPlayers,
          count(DISTINCT CASE WHEN missionStartedFlag = 1
                AND missionCompletedFlag IS NULL THEN userId ELSE NULL END) AS n00bs
   FROM DATA
   GROUP BY missionName)
SELECT missionName AS "Mission Name",
       players AS "Players starting mission",
       completedPlayers AS "Number of players completing mission",
       n00bs AS "players started but not completed mission",
       n00bs/nullif(players,0) AS Ratio --NullIF since players could theoretically be 0 and we rather divide by null
FROM nonCompletionData
ORDER BY missionName;
