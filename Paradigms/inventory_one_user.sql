--this query can be used to look at the transactions a user made over time, in the currentlyInInventory you find the amount of the item the user currently has.
SELECT CASE
           WHEN sessionId IS NOT NULL THEN 'client'
           ELSE 'server'
       END AS eventSource, --check where events come from, sessionless events are usually ghost events coming from a server
       eventTimestamp,
       conditional_change_event(mainEventID) over(partition BY userId
                                                  ORDER BY eventId)+1 AS transactionNumber,--numbers the transactions
       productName,
       sum(CASE
               WHEN transactionVector = 'RECEIVED' THEN productAmount
               ELSE -productAmount
           END) over (partition BY userId, productname
                      ORDER BY eventId) AS currentlyInInventory,-- this is available to the user at this point in time for this productName.
       transactionname,--the name of the transaction, telling you something about why the change happened.
       productAmount,
       transactionVector
FROM EVENTS
WHERE userId = 'userId goes here'
AND productAmount IS NOT NULL --include all events that report something about the productamount, these will be reported only on eventlevel 1
  AND eventlevel = 1 --only select events at eventlevel 1
ORDER BY eventId
