# sql-cookbook
Common SQL recipes and best practises

## Purpose

This repository aims to provide a number of best practises and ideas on how to construct queries that provide interesting data in a way that works well with our platform.

Use these queries as you please for educational purposes and to adjust them to suit your specific needs.

Also everyone is welcome to contribute, just fork the project and file a pull request. 

## Reference

These queries can be used to run within the deltaDNA platform in the data mining section. Alternatively when adding either _live or _dev to the table selection you can use these queries in your favourite DB tool via direct access as well.

[Data mining reference](http://docs.deltadna.com/reference/analyze/data-mining/ "data mining").

[Direct SQL Access reference](http://docs.deltadna.com/reference/analyze/direct-sql-access/ "direct access").

The queries are executed by an HP vertica DBMS and the SQL dialect used is defined by them and described in the following documentation:
HP Vertica documentation
A [HP Vertica documentation](https://my.vertica.com/docs/8.0.x/HTML/#Authoring/SQLReferenceManual/SQLReferenceManual.htm "Vertica Docs").


## Prerequisites

We assume some basic knowledge of SQL select statements and a basic knowledge of the data structure within the DeltaDNA platform, what events you are sending in and what they denote.

In this cookbook we aim to show how SQL queries can be best used to query the data with the DeltaDNA platform. The theory applies to both the data mining feature as well as direct access.

### Data Mining
Our data mining feature enables you to write an SQL query that retrieves data from the tables exposed and shows your the result on screen. These results can then be shown as a graph, a pie chart or as plain data. The queries can be stored and used in custom dashboards and email reports. You can even use data mining queries to create a list of userID's that you can then use within the platform as a target list.

### Direct Access
Direct Access is the name of our direct database connection. We provide an endpoint where you can directly connect to the data warehouse as if it was a simple PostgreSQL (Postgres) database. This way you can connect via tools like Tableau, dBeaver or directly within Python or R to the data warehouse. This provides for an infinitely flexible use of the data but it does require some more work on your part. What direct access is not intended for is to mirror the data somewhere else, if you'd like to do this then please download the raw data exports from our S3 archive and use these.

### Data mining and Direct Access, the differences
Data mining is part of the platform and is linked to the game and the environment. Within data mining you'll have the events table which is the table for the environment you're in (dev or live) for your game. Direct access connects to the game, this means here you don't have an events table but both the events_dev and the events_live

### The data warehouse
The data warehouse consists of a Verica database, we currently expose this via direct access as a Postgres database since the SQL dialect is similar but Postgres is supported by more clients than Vertica.

Vertica is a column store database that is especially good at analytics. Obviously this is a good thing but there are some things to keep in mind.

There are a lot of columns, hence why it's also called a wide table, for the way it is stored this is not an issue since only rows that have a value in that column are stored. Naturally there will be quite a few empty values in this table.
Due to all events being stored in this one table there will be a lot of rows when represented as a table.

When querying the data it makes a big difference how many columns are within scope. The columns you are not interested in should not be queried. This makes `select count(*) from events` usually faster than `select * from events limit 1` When you select a row with all columns anyway you'll quickly find that it is hard to find the values you are actually interested since you will keep having to scroll horizontally.

## Tips
Use analytic functions instead of joins
- use case = select clientVersion (clientVersionLast)

Get the last clientVersion known for a user from the user_metrics table and join it back on to the events table by joining the events 
 
```sql
select events.EventName, user_metrics.fieldClientVersionLast, count(distinct userId) as users
from events, user_metrics
where user_metrics.user_id = events.userId
and eventDate > current_date-14
group by events.EventName, user_metrics.fieldClientVersionLast
 ```

Instead you can use an analytic function to find the last value of the field clientVersion for that user.
```sql
with dataCTE as (select eventName, 
last_value(ClientVersion ignore nulls) over (partition by userId order by eventId) as lastClientVersion, userId
from events
where eventDate > current_date-14
)
select eventName, lastClientVersion, count(distinct userId) as users
from dataCTE
group by eventName, lastClientVersion
```

## Query Performance

A column store database, like Vertica, stores a table of data by splitting the data into multiple indexed data stores where a data store is a chunk split up by column name and within that the partitions the table is set to have. Next to that a data store can be ordered to improve performance for certain types of queries.

If you are able to define a subset of items in the column or partition definition you can massively increase the query execution performance.

So only selecting the columns you are interested in will mean that instead of retrieving the data for all columns only the relevant columns are touched. Try running: 
select eventTimestamp, userid, eventName from events order by 1
Instead of:
```
select * from events order by eventTimestamp
```
In the case of the events table it helps to limit the number of dates your query is looking at.
```
Where eventDate = current_date -10
```
Or if you can limit the number of events to look at:
```
Where eventName = ‘gameStarted’
````
Or if you define the users you are interested in:
```
Where userId in (‘ThisUser’, ‘AnotherUser’)
```
Alternatively if you can sample the data based on the userId so you can do a simple operation that tells you if the user should be included in your search, like only look at users starting with an ‘a’
```
where left(userID, 1) = 'a'
```

Another, more random way to query a subset of users is to run a hash function on the userId which returns a number and then running a modulo on the outcome of that, which gives you a pseudo random number and get only the items where this returns 0, this gives you 1/100th of all users and makes the query nearly 100x as fast. Using this when debugging a complicated query is recommended. (protip: try changing the 100 for 10000 for a smaller subset and changing the 0 for a different number to test with a different sample!)
```
where mod(hash(userId), 100)=0
```

**Spooling**

The next step in running any query is returning the results. This is depending on bandwidth and might cause performance issues on a slow internet connection. Returning 100 rows will not be a problem and most db tools like dbeaver and data mining will limit the number of returned rows to something below 1000. When running queries from R and Python this is an easy pitfall, especially when running on your laptop via a mobile data connection in the park.

**Filtering in a query**

Filter as early as possible in a query to make the next step quicker.
So instead of:
```
With data as (select eventName, userid, platform from events)
Select * from data
Where eventName = ‘gameStarted’
```
Do

```
With data as (select eventName, userid, platform from events
where eventName = ‘gameStarted’)
Select * from data
```

