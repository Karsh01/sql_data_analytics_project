/*
===============================================================================
Cumulative Analysis
===============================================================================
Script Purpose:
    - This script calculates cumulative metrics over time to analyze sales trends.
    - Helps in understanding revenue growth, cumulative order counts, and long-term performance.
    - Useful for tracking business progress and identifying key milestones.
    
Tables Used:
    - gold.fact_sales
===============================================================================
*/

-- Calculate Cumulative Sales Over Time
SELECT order_date, 
       SUM(price) AS daily_sales, 
       SUM(SUM(price)) OVER (ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_sales
FROM gold.fact_sales
GROUP BY order_date
ORDER BY order_date;
GO

-- Calculate Cumulative Order Count Over Time
SELECT order_date, 
       COUNT(order_id) AS daily_orders, 
       SUM(COUNT(order_id)) OVER (ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_orders
FROM gold.fact_sales
GROUP BY order_date
ORDER BY order_date;
GO

-- Calculate Cumulative Sales by Month
SELECT YEAR(order_date) AS year, MONTH(order_date) AS month, 
       SUM(price) AS monthly_sales, 
       SUM(SUM(price)) OVER (ORDER BY YEAR(order_date), MONTH(order_date) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_sales
FROM gold.fact_sales
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month;
GO

-- Calculate Cumulative Sales by Customer (Lifetime Value Tracking)
SELECT customer_id, full_name, 
       SUM(price) AS total_spent, 
       SUM(SUM(price)) OVER (PARTITION BY customer_id ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_spent
FROM gold.fact_sales
JOIN gold.dim_customers USING (customer_id)
GROUP BY customer_id, full_name, order_date
ORDER BY customer_id, order_date;
GO

-- Calculate Cumulative Revenue Contribution by Top Customers
WITH CustomerRevenue AS (
    SELECT customer_id, full_name, SUM(price) AS total_spent
    FROM gold.fact_sales
    JOIN gold.dim_customers USING (customer_id)
    GROUP BY customer_id, full_name
)
SELECT customer_id, full_name, total_spent,
       SUM(total_spent) OVER (ORDER BY total_spent DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_revenue
FROM CustomerRevenue;
GO

-- Calculate Cumulative Book Sales Over Time (Bestsellers Growth Tracking)
SELECT book_id, title, order_date, SUM(price) AS daily_sales, 
       SUM(SUM(price)) OVER (PARTITION BY book_id ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_book_sales
FROM gold.fact_sales
JOIN gold.dim_books USING (book_id)
GROUP BY book_id, title, order_date
ORDER BY book_id, order_date;
GO

-- Calculate Cumulative Percentage of Total Revenue Contribution Over Time
WITH TotalRevenue AS (
    SELECT SUM(price) AS total_sales FROM gold.fact_sales
)
SELECT order_date, SUM(price) AS daily_sales,
       SUM(SUM(price)) OVER (ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) * 100.0 / (SELECT total_sales FROM TotalRevenue) AS cumulative_percentage_of_total
FROM gold.fact_sales
GROUP BY order_date
ORDER BY order_date;
GO
