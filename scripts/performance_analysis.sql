/*
===============================================================================
Performance Analysis
===============================================================================
Script Purpose:
    - This script evaluates customer, book, and order performance.
    - Identifies high-performing customers, best-selling books, and order efficiency.
    - Measures profitability, retention rates, and repeat customers.
    
Tables Used:
    - gold.fact_sales
    - gold.dim_customers
    - gold.dim_books
    - gold.dim_orders
===============================================================================
*/

-- Identify Top-Performing Customers by Total Spend
SELECT customer_id, full_name, SUM(price) AS total_spent,
       COUNT(order_id) AS total_orders,
       AVG(price) AS avg_order_value
FROM gold.fact_sales
JOIN gold.dim_customers USING (customer_id)
GROUP BY customer_id, full_name
ORDER BY total_spent DESC;
GO

-- Identify Repeat Customers (Customers with more than one order)
SELECT customer_id, full_name, COUNT(DISTINCT order_id) AS total_orders
FROM gold.fact_sales
JOIN gold.dim_customers USING (customer_id)
GROUP BY customer_id, full_name
HAVING COUNT(DISTINCT order_id) > 1
ORDER BY total_orders DESC;
GO

-- Calculate Customer Retention Rate (Percentage of Repeat Customers)
WITH TotalCustomers AS (
    SELECT COUNT(DISTINCT customer_id) AS total_customers FROM gold.fact_sales
),
RepeatCustomers AS (
    SELECT COUNT(DISTINCT customer_id) AS repeat_customers
    FROM gold.fact_sales
    GROUP BY customer_id
    HAVING COUNT(order_id) > 1
)
SELECT (SELECT repeat_customers FROM RepeatCustomers) * 100.0 / total_customers AS retention_rate
FROM TotalCustomers;
GO

-- Identify Best-Selling Books by Revenue
SELECT book_id, title, SUM(price) AS total_revenue,
       COUNT(order_id) AS total_orders
FROM gold.fact_sales
JOIN gold.dim_books USING (book_id)
GROUP BY book_id, title
ORDER BY total_revenue DESC;
GO

-- Identify Best-Selling Books by Order Count
SELECT book_id, title, COUNT(order_id) AS total_orders
FROM gold.fact_sales
JOIN gold.dim_books USING (book_id)
GROUP BY book_id, title
ORDER BY total_orders DESC;
GO

-- Calculate Average Order Processing Time (Time from Order Date to Status Update)
SELECT AVG(DATEDIFF(DAY, order_date, status_date)) AS avg_processing_time
FROM gold.dim_orders
WHERE status_value = 'Delivered';
GO

-- Identify Order Fulfillment Efficiency (Orders Delivered On Time)
SELECT COUNT(order_id) AS total_delivered,
       COUNT(CASE WHEN status_value = 'Delivered' THEN 1 END) * 100.0 / COUNT(order_id) AS on_time_delivery_rate
FROM gold.dim_orders;
GO

-- Calculate Revenue Per Order
SELECT order_id, SUM(price) AS total_order_value
FROM gold.fact_sales
GROUP BY order_id
ORDER BY total_order_value DESC;
GO

-- Identify Most Profitable Customers (Customers Generating the Highest Profit)
SELECT customer_id, full_name, SUM(price) AS total_spent,
       COUNT(order_id) AS total_orders,
       SUM(price) * 100.0 / (SELECT SUM(price) FROM gold.fact_sales) AS revenue_contribution
FROM gold.fact_sales
JOIN gold.dim_customers USING (customer_id)
GROUP BY customer_id, full_name
ORDER BY total_spent DESC;
GO

-- Monthly Performance Trends (Revenue and Order Count Over Time)
SELECT YEAR(order_date) AS year, MONTH(order_date) AS month,
       SUM(price) AS total_revenue,
       COUNT(order_id) AS total_orders
FROM gold.fact_sales
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month;
GO
