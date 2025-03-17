/*
===============================================================================
Change Over Time Analysis
===============================================================================
Script Purpose:
    - This script analyzes how sales, revenue, and order volume change over time.
    - It calculates month-over-month, year-over-year growth rates, and trends.
    - Identifies sales acceleration or decline patterns.
    
Tables Used:
    - gold.fact_sales
===============================================================================
*/

-- Calculate Year-Over-Year Sales Growth
SELECT YEAR(order_date) AS year, 
       SUM(price) AS total_sales, 
       LAG(SUM(price)) OVER (ORDER BY YEAR(order_date)) AS prev_year_sales,
       (SUM(price) - LAG(SUM(price)) OVER (ORDER BY YEAR(order_date))) / NULLIF(LAG(SUM(price)) OVER (ORDER BY YEAR(order_date)), 0) * 100 AS year_over_year_growth
FROM gold.fact_sales
GROUP BY YEAR(order_date)
ORDER BY year;
GO

-- Calculate Month-Over-Month Sales Growth
SELECT YEAR(order_date) AS year, MONTH(order_date) AS month, 
       SUM(price) AS total_sales, 
       LAG(SUM(price)) OVER (ORDER BY YEAR(order_date), MONTH(order_date)) AS prev_month_sales,
       (SUM(price) - LAG(SUM(price)) OVER (ORDER BY YEAR(order_date), MONTH(order_date))) / NULLIF(LAG(SUM(price)) OVER (ORDER BY YEAR(order_date), MONTH(order_date)), 0) * 100 AS month_over_month_growth
FROM gold.fact_sales
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month;
GO

-- Calculate Week-Over-Week Sales Growth
SELECT DATEPART(YEAR, order_date) AS year, DATEPART(WEEK, order_date) AS week, 
       SUM(price) AS total_sales, 
       LAG(SUM(price)) OVER (ORDER BY DATEPART(YEAR, order_date), DATEPART(WEEK, order_date)) AS prev_week_sales,
       (SUM(price) - LAG(SUM(price)) OVER (ORDER BY DATEPART(YEAR, order_date), DATEPART(WEEK, order_date))) / NULLIF(LAG(SUM(price)) OVER (ORDER BY DATEPART(YEAR, order_date), DATEPART(WEEK, order_date)), 0) * 100 AS week_over_week_growth
FROM gold.fact_sales
GROUP BY DATEPART(YEAR, order_date), DATEPART(WEEK, order_date)
ORDER BY year, week;
GO

-- Calculate the Highest and Lowest Sales Growth Months
WITH MonthlyGrowth AS (
    SELECT YEAR(order_date) AS year, MONTH(order_date) AS month, 
           SUM(price) AS total_sales, 
           LAG(SUM(price)) OVER (ORDER BY YEAR(order_date), MONTH(order_date)) AS prev_month_sales,
           (SUM(price) - LAG(SUM(price)) OVER (ORDER BY YEAR(order_date), MONTH(order_date))) / NULLIF(LAG(SUM(price)) OVER (ORDER BY YEAR(order_date), MONTH(order_date)), 0) * 100 AS month_over_month_growth
    FROM gold.fact_sales
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT TOP 1 * FROM MonthlyGrowth ORDER BY month_over_month_growth DESC;
GO

SELECT TOP 1 * FROM MonthlyGrowth ORDER BY month_over_month_growth ASC;
GO

-- Calculate Cumulative Sales Over Time
SELECT order_date, 
       SUM(price) AS daily_sales, 
       SUM(SUM(price)) OVER (ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_sales
FROM gold.fact_sales
GROUP BY order_date
ORDER BY order_date;
GO

-- Identify Sudden Spikes or Drops in Sales (Detecting Outliers)
SELECT order_date, SUM(price) AS total_sales,
       AVG(SUM(price)) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS moving_avg_sales,
       (SUM(price) - AVG(SUM(price)) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) / NULLIF(AVG(SUM(price)) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 0) * 100 AS percent_change
FROM gold.fact_sales
GROUP BY order_date
HAVING ABS((SUM(price) - AVG(SUM(price)) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)) / NULLIF(AVG(SUM(price)) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 0) * 100) > 50
ORDER BY percent_change DESC;
GO
