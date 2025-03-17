/*
===============================================================================
Ranking Analysis
===============================================================================
Script Purpose:
    - This script ranks key business metrics for books, customers, and orders.
    - Identifies best-selling books, top customers, and highest-value transactions.
    - Uses ranking functions to compare performance.
    
Tables Used:
    - gold.fact_sales
    - gold.dim_books
    - gold.dim_customers
===============================================================================
*/

-- Rank Books by Total Sales Revenue
SELECT book_id, title, SUM(price) AS total_revenue,
       RANK() OVER (ORDER BY SUM(price) DESC) AS sales_rank
FROM gold.fact_sales
JOIN gold.dim_books USING (book_id)
GROUP BY book_id, title
ORDER BY sales_rank;
GO

-- Rank Books by Number of Orders
SELECT book_id, title, COUNT(order_id) AS total_orders,
       RANK() OVER (ORDER BY COUNT(order_id) DESC) AS order_rank
FROM gold.fact_sales
JOIN gold.dim_books USING (book_id)
GROUP BY book_id, title
ORDER BY order_rank;
GO

-- Rank Customers by Total Spending
SELECT customer_id, full_name, SUM(price) AS total_spent,
       RANK() OVER (ORDER BY SUM(price) DESC) AS spending_rank
FROM gold.fact_sales
JOIN gold.dim_customers USING (customer_id)
GROUP BY customer_id, full_name
ORDER BY spending_rank;
GO

-- Rank Customers by Number of Orders
SELECT customer_id, full_name, COUNT(order_id) AS total_orders,
       RANK() OVER (ORDER BY COUNT(order_id) DESC) AS order_count_rank
FROM gold.fact_sales
JOIN gold.dim_customers USING (customer_id)
GROUP BY customer_id, full_name
ORDER BY order_count_rank;
GO

-- Rank Orders by Transaction Value
SELECT order_id, SUM(price) AS order_value,
       RANK() OVER (ORDER BY SUM(price) DESC) AS order_value_rank
FROM gold.fact_sales
GROUP BY order_id
ORDER BY order_value_rank;
GO

-- Rank Books by Average Price
SELECT book_id, title, AVG(price) AS avg_price,
       RANK() OVER (ORDER BY AVG(price) DESC) AS price_rank
FROM gold.fact_sales
JOIN gold.dim_books USING (book_id)
GROUP BY book_id, title
ORDER BY price_rank;
GO

-- Rank Customers by Average Order Value (AOV)
SELECT customer_id, full_name, AVG(price) AS avg_order_value,
       RANK() OVER (ORDER BY AVG(price) DESC) AS avg_order_rank
FROM gold.fact_sales
JOIN gold.dim_customers USING (customer_id)
GROUP BY customer_id, full_name
ORDER BY avg_order_rank;
GO

-- Rank Books by Cumulative Revenue Contribution
WITH CumulativeRevenue AS (
    SELECT book_id, title, SUM(price) AS total_revenue,
           SUM(SUM(price)) OVER (ORDER BY SUM(price) DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_revenue
    FROM gold.fact_sales
    JOIN gold.dim_books USING (book_id)
    GROUP BY book_id, title
)
SELECT book_id, title, total_revenue,
       RANK() OVER (ORDER BY cumulative_revenue DESC) AS cumulative_rank
FROM CumulativeRevenue;
GO

-- Rank Monthly Sales Performance
SELECT YEAR(order_date) AS year, MONTH(order_date) AS month, SUM(price) AS monthly_sales,
       RANK() OVER (ORDER BY SUM(price) DESC) AS monthly_rank
FROM gold.fact_sales
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY monthly_rank;
GO
