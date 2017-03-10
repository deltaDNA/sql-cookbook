--Get the tipping point for when users would be in the top 1% of the group of spenders.
--Then use this to find the 1% of the spenders.
WITH spenders AS
  (SELECT user_Id,
          totalRealCurrencySpent,
          PERCENTILE_CONT(.01) WITHIN GROUP(ORDER BY totalRealCurrencySpent DESC) OVER (PARTITION BY 1) AS top1Percent
   FROM user_metrics
   WHERE totalRealCurrencySpent>0 --only select spenders
  )
SELECT count(*) AS spenders,
       count(CASE
                 WHEN totalRealCurrencySpent>=top1Percent THEN 1
                 ELSE NULL
             END) AS top1PercentSpenders
FROM spenders
