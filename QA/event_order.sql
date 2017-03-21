--In order for session times to be measured accurately and for first and last value metrics to work okay events need to come in in the order they occured in.
--Since the device time might not be 100% accurate and can automatically be adjusted it could occasionally happen that an event has a timestamp slightly before the next one, this should only happen in up to 1%of the events.
WITH eventData AS
  (SELECT userId,
          eventDate,
          eventTimestamp,
          lag(eventTimestamp) over(partition BY userId
                                   ORDER BY eventId),
                              EXTRACT(EPOCH
                                      FROM eventTimestamp - lag(eventTimestamp) over(partition BY userId
                                                                                     ORDER BY eventId)) AS secondsdiff
   FROM EVENTS
   WHERE sessionId IS NOT NULL--exclude ghost events
),
     aggregates AS
  (SELECT eventDate,
          count(CASE
                    WHEN secondsdiff<0 THEN 1
                    ELSE NULL
                END) AS 'wrongOrderEvents',
          count(CASE
                    WHEN secondsdiff>=0 THEN 1
                    ELSE NULL
                END) AS 'rightOrderEvents',
          count(DISTINCT CASE
                             WHEN secondsdiff<0 THEN userId
                             ELSE NULL
                         END) AS 'wrongOrderUsers',
          count(DISTINCT userId) AS userCount,
          count(*) AS eventCount
   FROM eventData
   GROUP BY eventDate)
SELECT eventDate,
       wrongOrderEvents,
       eventCount,
       wrongOrderUsers,
       userCount,
       round(wrongOrderEvents/eventCount*100,2.0) AS 'percentage of events in wrong order',
       round(wrongOrderUsers/userCount*100,2.0) AS 'percentage of users with events in wrong order'
FROM aggregates
ORDER BY eventDate DESC
