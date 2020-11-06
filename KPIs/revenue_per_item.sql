--Real currency spent, grouped by item.
--combine different child events from transaction event
WITH items as
  (SELECT productAmount, ItemName, mainEventId
   FROM events
   WHERE eventName = 'transaction'
     AND productCategory = 'ITEM'),
     spendings AS
  (SELECT i.ItemName,
          i.productAmount,
          i.mainEventId,
          e.convertedProductAmount
   FROM events AS e
   INNER JOIN items AS i ON e.mainEventId = i.mainEventId
   WHERE e.productCategory = 'REAL_CURRENCY'
   ORDER BY itemName)
SELECT itemName,
       sum(productAmount) as "items sold",
       round(sum(convertedProductAmount)/100,2.0) as revenue,
       count(*) as sales
FROM spendings
GROUP BY itemName
order by revenue desc
