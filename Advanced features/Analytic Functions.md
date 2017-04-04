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

Some default aggregate functions such as `SUM` and `COUNT` can be used as aggregate functions as well, you can find the complete list of functions here:
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
WHERE eventNumber = 1
GROUP BY eventName
ORDER BY count(*) DESC
```

# WORK IN PROGRESS

### LAG/LEAD


### last_value/first_value

### Conditional change event

### Percentile

### Median

-count()
-sum


## Partitioning
Within the over statement you can specify what you want to group by, there will be a seperate counter for each unique value. Without partitioning you will just get the aggregate for all rows within scope. 

The following will add a row with every unique
```sql
sum(convertedProductAmount) over ()
```


## Ordering
When the ordering is omitted 


## windowing

minimum: ()
user based:



## idioms:
-sessionCounter (conditional_change_event)
-count(case)


