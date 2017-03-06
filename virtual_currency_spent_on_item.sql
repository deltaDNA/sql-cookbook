--Virtual currency spent, grouped by item.
--combine different child events from transaction event
--this will have to be grouped as a pivot table to be used in a data mining query
WITH items as
  (SELECT productAmount, ItemName, mainEventId
   FROM events
   WHERE eventName = 'transaction'
     AND productCategory = 'ITEM'),
     spendings AS
  (SELECT i.ItemName,
          i.productAmount,
          i.mainEventId,
          e.virtualCurrencyName,
          e.virtualCurrencyAmount
   FROM events AS e
   INNER JOIN items AS i ON e.mainEventId = i.mainEventId
   WHERE e.productCategory = 'VIRTUAL_CURRENCY'
   ORDER BY itemName)
SELECT itemName,
       virtualCurrencyName,
       sum(virtualCurrencyAmount)
FROM spendings
GROUP BY itemName,
         virtualCurrencyName
