WITH relevant_data AS (
	    SELECT
	      userId,
	      eventDate,
	      responseEngagementName,
	      eventTimestamp,
	      responseVariantName,
	      responseMessageSequence,
	      eventName,
	      --Check if the next event for this user is the test event
      lead(eventName = 'gameStarted') OVER ( userWindow ) AS nextEventIsTestEvent,
      --Get the time of the following event
      lead(eventTimestamp) OVER ( userWindow ) AS nextTimestamp
    FROM events
    WHERE ((eventName = 'engageResponse' and responseEngagementName = 'A/B test campaign'
		              )
			           OR (eventName = 'gameStarted'
				)
				    )
				    WINDOW userWindow AS (PARTITION BY userId ORDER BY eventTimestamp )
			), results AS (
			    SELECT
			      eventDate AS Date,
			      responseVariantName AS Variant,
			      responseMessageSequence AS Step,
			      count(DISTINCT userID) AS Participants,
			      -- Get the number of people who reach the test event within the interval
      count(DISTINCT CASE WHEN nextEventIsTestEvent AND (nextTimestamp - eventTimestamp) <= '1 days' :: INTERVAL
	        THEN userId END) AS Occurred
	    FROM relevant_data
	WHERE (eventName = 'engageResponse')
	GROUP BY eventDate, responseVariantName, responseMessageSequence
)
SELECT
  *,
  round(Occurred / Participants * 100, 2) :: FLOAT AS "Occurred %"
FROM results
ORDER BY Date, Variant, Step
