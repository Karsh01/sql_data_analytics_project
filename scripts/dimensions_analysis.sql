/*
===============================================================================
Dimensions Analysis
===============================================================================
Script Purpose:
    - This script explores the key dimensions in the data warehouse.
    - It retrieves distinct values, counts unique entries, and provides insights into
      categorical data such as customer segments, book genres, order statuses, and more.
    
Tables Used:
    - gold.dim_customers
    - gold.dim_books
    - gold.dim_orders
    
===============================================================================
*/

-- Retrieve distinct customer countries and count customers per country
SELECT country_name, COUNT(DISTINCT customer_id) AS total_customers
FROM gold.dim_customers
GROUP BY country_name
ORDER BY total_customers DESC;
GO

-- Retrieve distinct address statuses and count customers in each status category
SELECT address_status, COUNT(customer_id) AS total_customers
FROM gold.dim_customers
GROUP BY address_status
ORDER BY total_customers DESC;
GO

-- Retrieve the number of customers by city
SELECT city, COUNT(customer_id) AS total_customers
FROM gold.dim_customers
GROUP BY city
ORDER BY total_customers DESC;
GO

-- Retrieve distinct book languages and count books per language
SELECT language_name, COUNT(DISTINCT book_id) AS total_books
FROM gold.dim_books
GROUP BY language_name
ORDER BY total_books DESC;
GO

-- Retrieve distinct publishers and count books published by each
SELECT publisher_name, COUNT(book_id) AS total_books
FROM gold.dim_books
GROUP BY publisher_name
ORDER BY total_books DESC;
GO

-- Retrieve distinct order statuses and count the number of orders per status
SELECT status_value, COUNT(order_id) AS total_orders
FROM gold.dim_orders
GROUP BY status_value
ORDER BY total_orders DESC;
GO

-- Retrieve the number of orders by customer
SELECT customer_id, COUNT(order_id) AS total_orders
FROM gold.dim_orders
GROUP BY customer_id
ORDER BY total_orders DESC;
GO

-- Retrieve distinct order dates and count orders per date
SELECT order_date, COUNT(order_id) AS total_orders
FROM gold.dim_orders
GROUP BY order_date
ORDER BY order_date DESC;
GO

-- Retrieve the most common book titles (books that appear in multiple orders)
SELECT title, COUNT(book_id) AS order_count
FROM gold.dim_books
JOIN gold.fact_sales USING (book_id)
GROUP BY title
ORDER BY order_count DESC;
GO
