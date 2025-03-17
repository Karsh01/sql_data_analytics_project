/*
===============================================================================
Customer Retention Analysis
===============================================================================
Script Purpose:
    - This script analyzes customer retention and repeat purchases.
    - Identifies customers who have made multiple purchases.
    - Calculates retention rates and repeat customer trends over time.
    - Segments customers based on their order frequency.
    
Tables Used:
    - gold.fact_sales
    - gold.dim_customers
===============================================================================
*/

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

-- Analyze Monthly Repeat Purchase Trends
SELECT YEAR(order_date) AS year, MONTH(order_date) AS month,
       COUNT(DISTINCT CASE WHEN customer_id IN (
           SELECT customer_id FROM gold.fact_sales GROUP BY customer_id HAVING COUNT(order_id) > 1
       ) THEN customer_id END) AS repeat_customers,
       COUNT(DISTINCT customer_id) AS total_customers,
       COUNT(DISTINCT CASE WHEN customer_id IN (
           SELECT customer_id FROM gold.fact_sales GROUP BY customer_id HAVING COUNT(order_id) > 1
       ) THEN customer_id END) * 100.0 / COUNT(DISTINCT customer_id) AS repeat_customer_rate
FROM gold.fact_sales
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month;
GO

-- Identify Customers with the Highest Retention (Most Repeat Purchases)
SELECT customer_id, full_name, COUNT(order_id) AS total_orders
FROM gold.fact_sales
JOIN gold.dim_customers USING (customer_id)
GROUP BY customer_id, full_name
ORDER BY total_orders DESC
LIMIT 10;
GO

-- Segment Customers by Order Frequency
SELECT customer_id, full_name,
       COUNT(order_id) AS total_orders,
       CASE 
           WHEN COUNT(order_id) > 10 THEN 'Loyal Customer'
           WHEN COUNT(order_id) BETWEEN 5 AND 10 THEN 'Frequent Buyer'
           ELSE 'Occasional Buyer'
       END AS customer_segment
FROM gold.fact_sales
JOIN gold.dim_customers USING (customer_id)
GROUP BY customer_id, full_name
ORDER BY total_orders DESC;
GO

-- Count Customers in Each Order Frequency Segment
SELECT customer_segment, COUNT(customer_id) AS total_customers
FROM (
    SELECT customer_id,
           COUNT(order_id) AS total_orders,
           CASE 
               WHEN COUNT(order_id) > 10 THEN 'Loyal Customer'
               WHEN COUNT(order_id) BETWEEN 5 AND 10 THEN 'Frequent Buyer'
               ELSE 'Occasional Buyer'
           END AS customer_segment
    FROM gold.fact_sales
    GROUP BY customer_id
) AS segmented_customers
GROUP BY customer_segment;
GO

-- Calculate Average Time Between Orders for Repeat Customers
WITH OrderIntervals AS (
    SELECT customer_id, order_date,
           LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS previous_order_date
    FROM gold.fact_sales
)
SELECT customer_id, AVG(DATEDIFF(DAY, previous_order_date, order_date)) AS avg_days_between_orders
FROM OrderIntervals
WHERE previous_order_date IS NOT NULL
GROUP BY customer_id
ORDER BY avg_days_between_orders ASC;
GO

-- Identify Customers Who Have Not Ordered Recently (Churn Risk)
SELECT customer_id, full_name, MAX(order_date) AS last_order_date,
       DATEDIFF(DAY, MAX(order_date), GETDATE()) AS days_since_last_order
FROM gold.fact_sales
JOIN gold.dim_customers USING (customer_id)
GROUP BY customer_id, full_name
HAVING DATEDIFF(DAY, MAX(order_date), GETDATE()) > 180
ORDER BY days_since_last_order DESC;
GO
