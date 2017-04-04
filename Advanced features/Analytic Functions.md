# Analytic functions

When you have data that is stored on multiple rows you sometimes want to know about something that is not just reported back in the event you are looking on. Traditionally with large databases with a lot of tables the goto way to resolve this was by joining data back onto itself. With our data warehouse running Vertica however this is not the best way to do this. Using analytic functions usually provide you with a way to enrich the rows you are looking for rather than joining onto a different dataset.

Analytic functions take all rows in the output and add a column to this that holds the output of an analytic function. The functions can be easily recognised as part of the parameters to retrieve in the select statement and will contain the `OVER` keyword.

### Intention
This tutorial we are aiming to explain what analytic functions are and how they can be used in the DeltaDNA context. All example queries are created with data mining our demo game in mind, [you can visit this tool by clicking here.](https://www.deltadna.net/demo-account/demo-game/live/data-mining)

## Example
A first example, say you want to get the average amount of revenue generated per spender when they finish mission 5 ("First Time User Forest #5"):
first we get all data in scope we need, the transactions (only events with convertedproductAmount) and mission 5 finishes.
we can do this with the following where statement:
```sql
where (eventName = 'missionCompleted' and missionName ='First Time User Forest #5')
or convertedProductAmount is not null
```
Next we want to get the total amount spent in game up to that point in time, we can do this by summing up the convertedProductAmount per user and ordering it chronologically (using the eventID)
```sql
SUM(convertedProductAmount) OVER (partition by userId order by eventID) as cumulative_revenue
```
Combining these values I can get a resultset that I can then do another pass over that allows me to select all missionCompleted events:
```sql
with data as (select eventName,userId,
SUM(convertedProductAmount) OVER (partition by userId order by eventID) as cumulative_revenue
from events
where (eventName = 'missionCompleted' and missionName ='First Time User Forest #5')
or convertedProductAmount is not null)
select * from data
where eventName = 'missionCompleted'
```
Since users can finish that mission multiple times and we don't want any users that have never spend any money at all we want to just get the lowest value for the cumulative_revenue for each user that is not null, use this in a second subquery (or CTE using the WITH statement.) Then we get the average value of the revenue_first_mission_5_complete in the last part of the query.
```sql
WITH DATA AS
  (SELECT eventName,
          userId,
          SUM(convertedProductAmount) OVER (partition BY userId ORDER BY eventID) AS cumulative_revenue
   FROM EVENTS
   WHERE (eventName = 'missionCompleted'
          AND missionName ='First Time User Forest #5')
     OR convertedProductAmount IS NOT NULL)
,spenderAggregates AS
  (SELECT userId,
          min(cumulative_revenue)AS revenue_first_mission_5_complete
   FROM DATA
   WHERE eventName = 'missionCompleted'
     AND cumulative_revenue IS NOT NULL
   GROUP BY userId)
SELECT avg(revenue_first_mission_5_complete) AS RESULT
FROM spenderAggregates
```


## Functions

Some default aggregate functions such as `SUM()` and `COUNT()` can be used as aggregate functions as well, you can find the complete list of functions here:
[On the official Vertica documentation page.](https://my.vertica.com/docs/8.0.x/HTML/index.htm#Authoring/SQLReferenceManual/Functions/Analytic/AnalyticFunctions.htm)

### RANK/DENSE_RANK
If you are looking to add a number to each event based on the order of passing by the values in the order clause you can use the RANK function. For example if you want to know what the most popular second event a user sends is then you can number the events using rank and report them as follows.
```sql
WITH DATA AS
  (SELECT userId,
          eventName,
          rank() over (partition BY userId ORDER BY eventTimestamp) AS eventNumber
   FROM EVENTS
   WHERE gaUserStartdate = eventDate)
SELECT eventName,
       count(*) AS occurrances
FROM DATA
WHERE eventNumber = 2
GROUP BY eventName
ORDER BY count(*) DESC
```
If two events come in at the same time this will cause for a gap however and the user will never get an event with eventNumber 2, like you will skip the third price if there is a shared second price in a contest. If you don't want to do this you can use the `DENSE_RANK`, this will add a number to each row that is either the same or one higher than the previous one.

### LAG/LEAD
The `LAG()` function can be used to get the value something on the previous row. For example if you want to get the time between starting a mission and completing it you can do the following:
```sql
WITH DATA AS
  (SELECT eventTimestamp,
          eventName,
          missionName,
          lag(eventTimestamp) over(partition BY userId ORDER BY eventTimestamp) AS previousTimestamp
   FROM EVENTS
   WHERE eventName IN ('missionStarted',
                       'missionCompleted') )
SELECT missionName,
       avg(eventTimestamp - previousTimestamp) AS 'Average Completion Time'
FROM DATA
WHERE eventName = 'missionCompleted'
GROUP BY missionName
ORDER BY missionName
```
By only looking at the missionCompleted event and assuming that you can't complete a mission without starting it before you get the intervals between these two timestamps.

`LEAD()` works the opposite way around, it will get data from the next row instead. We did not use this here since there is an option of not completing the mission.

### LAST_VALUE/FIRST_VALUE
`LAST_VALUE()` is probably one of the most useful functions, it can be used to get the last known value, usually one would provide the parameter and the `IGNORE NULLS` keyword to make sure it does not just copy over the parameter.
```sql
WITH DATA AS
  (SELECT last_value(clientVersion IGNORE NULLS) over (partition BY userId ORDER BY eventId) AS currentClientversion,
          userId,
          eventTimestamp,
          eventName,
          realCurrencyAmount,
          realCurrencyType,
          convertedProductAmount
   FROM EVENTS
   WHERE clientVersion IS NOT NULL
     OR eventName = 'transaction')
SELECT *
FROM DATA
WHERE eventName = 'transaction'
```
The `FIRST_VALUE` works the exact oposite and fill give you the first value ever seen for that user.

### CONDITIONAL_CHANGE_EVENT
The `CONDITIONAL_CHANGE_EVENT()` function holds a counter that will increment if the current row is different from the last row, if you order your events by eventID you can use this to, for example, create a sessionCounter. Since the first session will get the number 0 you might want to add one to it to get a 1 based number and have session 1 being the first session.
```sql
CONDITIONAL_CHANGE_EVENT(sessionid) over (partition BY userId ORDER BY eventTimestamp)+1 AS sessionCounter
```
# WORK IN PROGRESS


### PERCENTILE
TODO

### MEDIAN
TODO


## Partitioning
Within the over statement you can specify what you want to group by, there will be a seperate counter for each unique value. Without partitioning you will just get the aggregate for all rows within scope. 

The following will the total aggregate over all events to all events without grouping at all, this can be convenient if you want to calculate a percentage.
```sql
sum(convertedProductAmount) over ()
```
If you specify a parameter however you will create a separate counter that will give you the total per unique value of that parameter. For example userID or sessionID work well here:
```sql
sum(convertedProductAmount) over (partition by userID)
```
In the example above you get the total revenue generated by that user added to all their events.

## Ordering
Next to partitioning you can also add an order in which the analytic function is executed, some functions even require you to specify an order such as `RANK()` and `MEDIAN()` since these functions are driven by the row order.

The following will enrich all your rows with the cummulative revenue per user up to the time that event was received.
```sql
sum(convertedProductAmount) over (partition by userID order by eventTimestamp)
```


## windowing
TODO:
minimum: ()
Default value

1. row based
2. range based


### extra things to mention:
TODO:
-sessionCounter (conditional_change_event)
-count(case)


