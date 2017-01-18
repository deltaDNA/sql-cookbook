-- In the firstValues CTE we get the first timestamp we have see for a user and the timezoneoffset on the day they were first seen.
--Next we add a number of minutes extracted from the timezone definition, so we are adding the value -90 when converting '-0130'.
-- We now end up with the a row per install containing the timestamp the user is first seen on (localEventTimestamp) and the timezoneoffset in minutes.
WITH firstValues AS
  (SELECT userId,
          min(eventTimestamp)startTs,
          min(timezoneOffset)tzo
   FROM EVENTS
   WHERE eventDate = gaUserStartDate
   GROUP BY userId),
     results AS
  (SELECT tzo,
          startTs,
          TIMESTAMPADD(MINUTE, CASE
                                   WHEN CHAR_LENGTH(TZO)=5 THEN CAST(substring(tzo, 1,1)||'1' AS INTEGER) *-- get positive vs negative tzoffset
(CAST(substring(tzo, 2,2) AS INTEGER)*60 + cast(substring(tzo, 4,2) AS INTEGER))
                                   ELSE NULL --get tzoffset in minutes

                               END, startTs) AS localEventTimestamp,
          CASE
              WHEN CHAR_LENGTH(TZO)=5 THEN CAST(substring(tzo, 1,1)||'1' AS INTEGER) *-- get positive vs negative tzoffset
(CAST(substring(tzo, 2,2) AS INTEGER)*60 + cast(substring(tzo, 4,2) AS INTEGER))
              ELSE NULL --get tzoffset in minutes

          END AS minutes
   FROM firstValues)
SELECT *
FROM results
