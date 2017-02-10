--The funnel tool enforces causality which means that what happens in step 1 needs to happen before step 2 for that user.
--This query looks for users who started any mission on the first day of playing and then looks at the number of users who did this and also completed a mission on day 2 of playing. This day 1 and day 2 filtering enforces causality as well but this could be left out or dictated by the game (if conditions for step 1 always precede conditions for step 2)
WITH step1 AS
  (SELECT DISTINCT userId
   FROM EVENTS
   WHERE eventDate = gaUserStartDate
     AND eventname = 'missionStarted'),
     step2 AS
  (SELECT DISTINCT userId
   FROM EVENTS
   WHERE userId IN
       (SELECT *
        FROM step1)
     AND eventDate - gaUserStartDate = 1
     AND eventName = 'missionCompleted')
SELECT 'step1' AS stepName,
       count(*) AS users
FROM step1
UNION
SELECT 'step2',
       count(*)
FROM step2
ORDER BY stepName
