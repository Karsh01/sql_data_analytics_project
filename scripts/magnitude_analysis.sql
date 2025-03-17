/*
===============================================================================
Magnitude Analysis
===============================================================================
Script Purpose:
    - This script analyzes the magnitude of sales transactions.
    - Identifies high-value and low-value orders.
    - Compares revenue contribution by different transaction sizes.
    - Helps assess customer and book impact based on purchase magnitude.
    
Tables Used:
    - gold.fact_sales
    - gold.dim_books
    - gold.dim_customers
===============================================================================
*/

-- Identify the highest-value transactions (Top 10 biggest orders)
SELECT TOP 10 order_id, customer_id, SUM(price) AS order_value
FROM gold.fact_sales
GROUP BY order_id, customer_id
ORDER BY order_value DESC;
GO

-- Identify the lowest-value transactions (Bottom 10 smallest orders)
SELECT TOP 10 order_id, customer_id, SUM(price) AS order_value
FROM gold.fact_sales
GROUP BY order_id, customer_id
ORDER BY order_value ASC;
GO

-- Retrieve the largest individual book purchases (most expensive items bought)
SELECT TOP 10 book_id, title, price
FROM gold.fact_sales
JOIN gold.dim_books USING (book_id)
ORDER BY price DESC;
GO

-- Retrieve the cheapest books sold
SELECT TOP 10 book_id, title, price
FROM gold.fact_sales
JOIN gold.dim_books USING (book_id)
ORDER BY price ASC;
GO

-- Categorize orders into High, Medium, and Low value segments
SELECT order_id, 
       SUM(price) AS order_value,
       CASE
           WHEN SUM(price) > 500 THEN 'High Value'
           WHEN SUM(price) BETWEEN 100 AND 500 THEN 'Medium Value'
           ELSE 'Low Value'
       END AS order_category
FROM gold.fact_sales
GROUP BY order_id
ORDER BY order_value DESC;
GO

-- Count of orders in each value category
SELECT order_category, COUNT(order_id) AS total_orders
FROM (
    SELECT order_id,
           SUM(price) AS order_value,
           CASE
               WHEN SUM(price) > 500 THEN 'High Value'
               WHEN SUM(price) BETWEEN 100 AND 500 THEN 'Medium Value'
               ELSE 'Low Value'
           END AS order_category
    FROM gold.fact_sales
    GROUP BY order_id
) AS categorized_orders
GROUP BY order_category;
GO

-- Identify customers with the highest single-order transactions
SELECT TOP 10 customer_id, full_name, MAX(price) AS highest_order_value
FROM gold.fact_sales
JOIN gold.dim_customers USING (customer_id)
GROUP BY customer_id, full_name
ORDER BY highest_order_value DESC;
GO

-- Identify customers with the lowest single-order transactions
SELECT TOP 10 customer_id, full_name, MIN(price) AS lowest_order_value
FROM gold.fact_sales
JOIN gold.dim_customers USING (customer_id)
GROUP BY customer_id, full_name
ORDER BY lowest_order_value ASC;
GO

-- Calculate the revenue percentage contributed by high-value transactions (orders above $500)
WITH HighValueOrders AS (
    SELECT SUM(price) AS total_high_value_sales
    FROM gold.fact_sales
    GROUP BY order_id
    HAVING SUM(price) > 500
)
SELECT (SUM(total_high_value_sales) * 100.0) / (SELECT SUM(price) FROM gold.fact_sales) AS high_value_order_percentage
FROM HighValueOrders;
GO

-- Analyze order magnitude over time (Yearly high-value order trends)
SELECT YEAR(order_date) AS year, COUNT(order_id) AS high_value_orders
FROM gold.fact_sales
WHERE order_id IN (
    SELECT order_id
    FROM gold.fact_sales
    GROUP BY order_id
    HAVING SUM(price) > 500
)
GROUP BY YEAR(order_date)
ORDER BY year;
GO