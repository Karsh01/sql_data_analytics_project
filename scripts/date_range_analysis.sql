/*
===============================================================================
Date Range Analysis
===============================================================================
Script Purpose:
    - This script analyzes sales, orders, and book trends over specific date ranges.
    - It examines sales performance by year, month, quarter, and daily trends.
    - Provides comparisons between different time periods for business insights.
    
Tables Used:
    - gold.fact_sales
    - gold.dim_orders
===============================================================================
*/

-- Retrieve total sales and number of orders for a specific year (e.g., 2023)
SELECT YEAR(order_date) AS year, COUNT(order_id) AS total_orders, SUM(price) AS total_sales
FROM gold.fact_sales
WHERE YEAR(order_date) = 2023
GROUP BY YEAR(order_date)
ORDER BY year;
GO

-- Retrieve monthly sales trends for the latest year available in the dataset
SELECT YEAR(order_date) AS year, MONTH(order_date) AS month, SUM(price) AS total_sales, COUNT(order_id) AS total_orders
FROM gold.fact_sales
WHERE YEAR(order_date) = (SELECT MAX(YEAR(order_date)) FROM gold.fact_sales)
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month;
GO

-- Retrieve quarterly sales trends for trend analysis
SELECT YEAR(order_date) AS year, DATEPART(QUARTER, order_date) AS quarter, SUM(price) AS total_sales, COUNT(order_id) AS total_orders
FROM gold.fact_sales
GROUP BY YEAR(order_date), DATEPART(QUARTER, order_date)
ORDER BY year, quarter;
GO

-- Retrieve daily sales trends for the last 30 days
SELECT order_date, SUM(price) AS total_sales, COUNT(order_id) AS total_orders
FROM gold.fact_sales
WHERE order_date >= DATEADD(DAY, -30, (SELECT MAX(order_date) FROM gold.fact_sales))
GROUP BY order_date
ORDER BY order_date DESC;
GO

-- Compare sales between two specific years (e.g., 2022 vs. 2023)
SELECT 
    YEAR(order_date) AS year, 
    SUM(price) AS total_sales, 
    COUNT(order_id) AS total_orders
FROM gold.fact_sales
WHERE YEAR(order_date) IN (2022, 2023)
GROUP BY YEAR(order_date)
ORDER BY year;
GO

-- Retrieve the highest and lowest sales days in history
SELECT TOP 1 order_date, SUM(price) AS total_sales
FROM gold.fact_sales
GROUP BY order_date
ORDER BY total_sales DESC;
GO

SELECT TOP 1 order_date, SUM(price) AS total_sales
FROM gold.fact_sales
GROUP BY order_date
ORDER BY total_sales ASC;
GO

-- Retrieve orders by weekday to analyze which days have the highest sales
SELECT DATENAME(WEEKDAY, order_date) AS day_of_week, COUNT(order_id) AS total_orders, SUM(price) AS total_sales
FROM gold.fact_sales
GROUP BY DATENAME(WEEKDAY, order_date)
ORDER BY total_sales DESC;
GO

-- Retrieve sales trends over the past 12 months for trend visualization
SELECT FORMAT(order_date, 'yyyy-MM') AS month_year, SUM(price) AS total_sales, COUNT(order_id) AS total_orders
FROM gold.fact_sales
WHERE order_date >= DATEADD(YEAR, -1, (SELECT MAX(order_date) FROM gold.fact_sales))
GROUP BY FORMAT(order_date, 'yyyy-MM')
ORDER BY month_year;
GO
