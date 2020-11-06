--Get the number of events per user and the sample size. Should be below 100 on average.

SELECT eventDate,
       count(*)/count(DISTINCT userId) AS "Events per DAU",
       count(DISTINCT userId) AS "Sample Size"
FROM EVENTS
GROUP BY eventDate
ORDER BY eventDate DESC
