--Get the number of events without a session and the ones with a session by eventDate.
--At least some events should come from the client and have a sessionID set.
SELECT eventDate,
       count(*)-count(sessionId) AS 'sessionless events',
       count(sessionID) AS 'session events',
       round((count(*)-count(sessionId))/count(*) * 100,2.0) AS 'percentage'
FROM EVENTS
GROUP BY eventDate
ORDER BY eventDate DESC
