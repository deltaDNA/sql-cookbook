WITH relevant_data AS (
	    SELECT
	      userId,
	      eventDate,
	      responseEngagementName,
	      eventTimestamp,
	      responseVariantName,
	      responseMessageSequence,
	      eventName,
      lead(eventName = 'gameStarted') OVER (PARTITION BY userId ORDER BY eventTimestamp) AS nextEventIsTestEvent,
      lead(eventTimestamp) OVER (PARTITION BY userId ORDER BY eventTimestamp) AS nextTimestamp
    FROM events
    WHERE ((eventName = 'engageResponse' and responseEngagementName = 'A/B test campaign'
		              )
			           OR (eventName = 'gameStarted'
				)
				    )
			), results AS (
			    SELECT
			      eventDate AS Date,
			      responseVariantName AS Variant,
			      responseMessageSequence AS Step,
			      count(DISTINCT userID) AS Participants,
      count(DISTINCT CASE WHEN nextEventIsTestEvent AND datediff(d, eventTimestamp, nextTimestamp) <= 1
	         THEN userId END) AS Occurred
	    FROM relevant_data
	WHERE (eventName = 'engageResponse')
	GROUP BY eventDate, responseVariantName, responseMessageSequence
)
SELECT
  *,
  round(Occurred / Participants * 100, 2) :: FLOAT AS "Occurred %"