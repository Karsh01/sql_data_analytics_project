/*
===============================================================================
Report: Top-Selling Books Analysis
===============================================================================
Script Purpose:
    - This script generates a report on the best-selling books based on revenue and order volume.
    - Provides insights into the most popular and profitable books.
    - Includes rankings by total revenue and total orders per month and year.
    
Tables Used:
    - gold.fact_sales
    - gold.dim_books
===============================================================================
*/

-- Retrieve Top 10 Best-Selling Books by Total Revenue
SELECT TOP 10 book_id, title, SUM(price) AS total_revenue
FROM gold.fact_sales
JOIN gold.dim_books USING (book_id)
GROUP BY book_id, title
ORDER BY total_revenue DESC;
GO

-- Retrieve Top 10 Best-Selling Books by Number of Orders
SELECT TOP 10 book_id, title, COUNT(order_id) AS total_orders
FROM gold.fact_sales
JOIN gold.dim_books USING (book_id)
GROUP BY book_id, title
ORDER BY total_orders DESC;
GO

-- Retrieve Monthly Top-Selling Books by Revenue
SELECT YEAR(order_date) AS year, MONTH(order_date) AS month, title, SUM(price) AS total_revenue,
       RANK() OVER (PARTITION BY YEAR(order_date), MONTH(order_date) ORDER BY SUM(price) DESC) AS revenue_rank
FROM gold.fact_sales
JOIN gold.dim_books USING (book_id)
GROUP BY YEAR(order_date), MONTH(order_date), title
ORDER BY year, month, revenue_rank;
GO

-- Retrieve Monthly Top-Selling Books by Order Count
SELECT YEAR(order_date) AS year, MONTH(order_date) AS month, title, COUNT(order_id) AS total_orders,
       RANK() OVER (PARTITION BY YEAR(order_date), MONTH(order_date) ORDER BY COUNT(order_id) DESC) AS order_rank
FROM gold.fact_sales
JOIN gold.dim_books USING (book_id)
GROUP BY YEAR(order_date), MONTH(order_date), title
ORDER BY year, month, order_rank;
GO

-- Retrieve Yearly Top-Selling Books by Revenue
SELECT YEAR(order_date) AS year, title, SUM(price) AS total_revenue,
       RANK() OVER (PARTITION BY YEAR(order_date) ORDER BY SUM(price) DESC) AS revenue_rank
FROM gold.fact_sales
JOIN gold.dim_books USING (book_id)
GROUP BY YEAR(order_date), title
ORDER BY year, revenue_rank;
GO

-- Retrieve Yearly Top-Selling Books by Order Count
SELECT YEAR(order_date) AS year, title, COUNT(order_id) AS total_orders,
       RANK() OVER (PARTITION BY YEAR(order_date) ORDER BY COUNT(order_id) DESC) AS order_rank
FROM gold.fact_sales
JOIN gold.dim_books USING (book_id)
GROUP BY YEAR(order_date), title
ORDER BY year, order_rank;
GO

-- Identify Books with Consistently High Sales Over Multiple Years
WITH BookSales AS (
    SELECT book_id, title, YEAR(order_date) AS year, SUM(price) AS total_revenue,
           RANK() OVER (PARTITION BY YEAR(order_date) ORDER BY SUM(price) DESC) AS revenue_rank
    FROM gold.fact_sales
    JOIN gold.dim_books USING (book_id)
    GROUP BY book_id, title, YEAR(order_date)
)
SELECT book_id, title, COUNT(year) AS years_in_top_rank
FROM BookSales
WHERE revenue_rank <= 5
GROUP BY book_id, title
ORDER BY years_in_top_rank DESC;
GO

-- Retrieve Books with the Highest Sales Growth Year Over Year
WITH YearlySales AS (
    SELECT book_id, title, YEAR(order_date) AS year, SUM(price) AS total_revenue
    FROM gold.fact_sales
    JOIN gold.dim_books USING (book_id)
    GROUP BY book_id, title, YEAR(order_date)
)
SELECT y1.book_id, y1.title, y1.year, y1.total_revenue, 
       y2.total_revenue AS prev_year_revenue,
       ((y1.total_revenue - y2.total_revenue) / NULLIF(y2.total_revenue, 0)) * 100 AS year_over_year_growth
FROM YearlySales y1
LEFT JOIN YearlySales y2 ON y1.book_id = y2.book_id AND y1.year = y2.year + 1
ORDER BY year_over_year_growth DESC;
GO
