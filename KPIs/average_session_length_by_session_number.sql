-- Shows average session length in minutes, sessionCount grouped by the session number 

-- Get session data
-- Conditional change event pulls out the sessionid only when it has changed from the last occurance 
WITH sessions AS (
    SELECT 
        userid, 
        sessionid, 
        eventtimestamp,
        eventname, 
        mssincelastevent,
        CONDITIONAL_CHANGE_EVENT(sessionid) OVER (PARTITION BY userid ORDER BY eventid) + 1 AS SessionCounter 
    FROM events WHERE sessionid IS NOT NULL 
                AND mssincelastevent IS NOT NULL
), 
    -- Get aggregate data from the session data 
    session_aggregates AS (
        SELECT 
            Max(userid) AS userID, 
            Min(eventtimestamp), 
            sessionid, 
            sessioncounter, 
            SUM(mssincelastevent) AS msSessionLength,
            Count(*) AS eventCount 
         FROM sessions 
         GROUP BY sessionid, 
                  sessioncounter
    ) 
        -- Further aggregate data 
        SELECT 
            sessioncounter as sessionNumber, 
            Count(*) AS sessionsCounted, 
            Round(Avg(mssessionlength) / 60000, 2.0) :: FLOAT AS avgSessionLengthMinutes
        FROM session_aggregates 
        GROUP BY sessioncounter 
        ORDER BY sessioncounter; 