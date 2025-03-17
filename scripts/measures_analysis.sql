/*
===============================================================================
Measures Analysis
===============================================================================
Script Purpose:
    - This script computes key business performance measures from the data warehouse.
    - Measures include Total Revenue, Average Order Value (AOV), Book Popularity, 
      Customer Spending, and other financial KPIs.
    
Tables Used:
    - gold.fact_sales
    - gold.dim_books
    - gold.dim_customers
===============================================================================
*/

-- Calculate Total Revenue (sum of all sales)
SELECT SUM(price) AS total_revenue
FROM gold.fact_sales;
GO

-- Calculate Total Number of Orders
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM gold.fact_sales;
GO

-- Calculate Average Order Value (AOV)
SELECT SUM(price) / COUNT(DISTINCT order_id) AS avg_order_value
FROM gold.fact_sales;
GO

-- Calculate Average Book Price
SELECT AVG(price) AS avg_book_price
FROM gold.fact_sales;
GO

-- Calculate Revenue Contribution by Customer
SELECT customer_id, SUM(price) AS total_spent
FROM gold.fact_sales
GROUP BY customer_id
ORDER BY total_spent DESC;
GO

-- Calculate Revenue Contribution by Book
SELECT book_id, title, SUM(price) AS total_sales
FROM gold.fact_sales
JOIN gold.dim_books USING (book_id)
GROUP BY book_id, title
ORDER BY total_sales DESC;
GO

-- Retrieve Top 10 Best-Selling Books by Revenue
SELECT TOP 10 book_id, title, SUM(price) AS total_revenue
FROM gold.fact_sales
JOIN gold.dim_books USING (book_id)
GROUP BY book_id, title
ORDER BY total_revenue DESC;
GO

-- Retrieve Top 10 Best-Selling Books by Order Count
SELECT TOP 10 book_id, title, COUNT(order_id) AS total_orders
FROM gold.fact_sales
JOIN gold.dim_books USING (book_id)
GROUP BY book_id, title
ORDER BY total_orders DESC;
GO

-- Retrieve Top 10 Highest-Spending Customers
SELECT TOP 10 customer_id, full_name, SUM(price) AS total_spent
FROM gold.fact_sales
JOIN gold.dim_customers USING (customer_id)
GROUP BY customer_id, full_name
ORDER BY total_spent DESC;
GO

-- Calculate Total Number of Unique Customers
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM gold.fact_sales;
GO

-- Calculate Percentage of Revenue from Top 10 Customers
WITH Top_Customers AS (
    SELECT TOP 10 customer_id, SUM(price) AS total_spent
    FROM gold.fact_sales
    GROUP BY customer_id
    ORDER BY total_spent DESC
)
SELECT SUM(total_spent) * 100.0 / (SELECT SUM(price) FROM gold.fact_sales) AS revenue_percentage
FROM Top_Customers;
GO

-- Retrieve Revenue by Month
SELECT YEAR(order_date) AS year, MONTH(order_date) AS month, SUM(price) AS total_sales
FROM gold.fact_sales
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month;
GO
