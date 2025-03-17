/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Script Purpose:
    - This script segments data into meaningful groups for deeper analysis.
    - Segments customers by spending behavior.
    - Segments books by pricing and sales performance.
    - Segments orders based on value categories.
    
Tables Used:
    - gold.fact_sales
    - gold.dim_customers
    - gold.dim_books
===============================================================================
*/

-- Segment Customers by Total Spending (High, Medium, Low Value Customers)
SELECT customer_id, full_name, SUM(price) AS total_spent,
       CASE 
           WHEN SUM(price) > 1000 THEN 'High Value'
           WHEN SUM(price) BETWEEN 500 AND 1000 THEN 'Medium Value'
           ELSE 'Low Value'
       END AS customer_segment
FROM gold.fact_sales
JOIN gold.dim_customers USING (customer_id)
GROUP BY customer_id, full_name
ORDER BY total_spent DESC;
GO

-- Count Customers in Each Spending Segment
SELECT customer_segment, COUNT(customer_id) AS total_customers
FROM (
    SELECT customer_id, SUM(price) AS total_spent,
           CASE 
               WHEN SUM(price) > 1000 THEN 'High Value'
               WHEN SUM(price) BETWEEN 500 AND 1000 THEN 'Medium Value'
               ELSE 'Low Value'
           END AS customer_segment
    FROM gold.fact_sales
    GROUP BY customer_id
) AS segmented_customers
GROUP BY customer_segment;
GO

-- Segment Books by Price (Premium, Standard, Budget)
SELECT book_id, title, AVG(price) AS avg_price,
       CASE
           WHEN AVG(price) > 50 THEN 'Premium'
           WHEN AVG(price) BETWEEN 20 AND 50 THEN 'Standard'
           ELSE 'Budget'
       END AS price_category
FROM gold.fact_sales
JOIN gold.dim_books USING (book_id)
GROUP BY book_id, title
ORDER BY avg_price DESC;
GO

-- Count Books in Each Price Segment
SELECT price_category, COUNT(book_id) AS total_books
FROM (
    SELECT book_id, AVG(price) AS avg_price,
           CASE
               WHEN AVG(price) > 50 THEN 'Premium'
               WHEN AVG(price) BETWEEN 20 AND 50 THEN 'Standard'
               ELSE 'Budget'
           END AS price_category
    FROM gold.fact_sales
    GROUP BY book_id
) AS segmented_books
GROUP BY price_category;
GO

-- Segment Orders by Value (High, Medium, Low)
SELECT order_id, SUM(price) AS order_value,
       CASE 
           WHEN SUM(price) > 500 THEN 'High Value'
           WHEN SUM(price) BETWEEN 100 AND 500 THEN 'Medium Value'
           ELSE 'Low Value'
       END AS order_segment
FROM gold.fact_sales
GROUP BY order_id
ORDER BY order_value DESC;
GO

-- Count Orders in Each Value Segment
SELECT order_segment, COUNT(order_id) AS total_orders
FROM (
    SELECT order_id, SUM(price) AS order_value,
           CASE 
               WHEN SUM(price) > 500 THEN 'High Value'
               WHEN SUM(price) BETWEEN 100 AND 500 THEN 'Medium Value'
               ELSE 'Low Value'
           END AS order_segment
    FROM gold.fact_sales
    GROUP BY order_id
) AS segmented_orders
GROUP BY order_segment;
GO

-- Identify the Most Popular Segment of Books by Revenue Contribution
SELECT price_category, SUM(price) AS total_revenue
FROM (
    SELECT book_id, AVG(price) AS avg_price,
           CASE
               WHEN AVG(price) > 50 THEN 'Premium'
               WHEN AVG(price) BETWEEN 20 AND 50 THEN 'Standard'
               ELSE 'Budget'
           END AS price_category, price
    FROM gold.fact_sales
    JOIN gold.dim_books USING (book_id)
    GROUP BY book_id, price
) AS segmented_books
GROUP BY price_category
ORDER BY total_revenue DESC;
GO

-- Identify the Most Profitable Customer Segments
SELECT customer_segment, SUM(price) AS total_spent
FROM (
    SELECT customer_id, SUM(price) AS total_spent,
           CASE 
               WHEN SUM(price) > 1000 THEN 'High Value'
               WHEN SUM(price) BETWEEN 500 AND 1000 THEN 'Medium Value'
               ELSE 'Low Value'
           END AS customer_segment
    FROM gold.fact_sales
    GROUP BY customer_id
) AS segmented_customers
GROUP BY customer_segment
ORDER BY total_spent DESC;
GO
