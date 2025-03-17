/*
===============================================================================
High-Performing Authors Analysis
===============================================================================
Script Purpose:
    - This script identifies top-performing authors based on revenue and order count.
    - Analyzes sales trends for authors over time.
    - Identifies authors with consistent high performance and those with the fastest growth.
    - Breaks down author performance by book category and sales region.
    
Tables Used:
    - gold.fact_sales
    - gold.dim_books
    - gold.dim_customers
===============================================================================
*/

-- Identify Top 10 Best-Selling Authors by Total Revenue
SELECT TOP 10 author_name, SUM(price) AS total_revenue
FROM gold.fact_sales
JOIN gold.dim_books USING (book_id)
GROUP BY author_name
ORDER BY total_revenue DESC;
GO

-- Identify Top 10 Best-Selling Authors by Number of Orders
SELECT TOP 10 author_name, COUNT(order_id) AS total_orders
FROM gold.fact_sales
JOIN gold.dim_books USING (book_id)
GROUP BY author_name
ORDER BY total_orders DESC;
GO

-- Identify Monthly Top-Selling Authors by Revenue
SELECT YEAR(order_date) AS year, MONTH(order_date) AS month, author_name, SUM(price) AS total_revenue,
       RANK() OVER (PARTITION BY YEAR(order_date), MONTH(order_date) ORDER BY SUM(price) DESC) AS revenue_rank
FROM gold.fact_sales
JOIN gold.dim_books USING (book_id)
GROUP BY YEAR(order_date), MONTH(order_date), author_name
ORDER BY year, month, revenue_rank;
GO

-- Identify Yearly Top-Selling Authors by Revenue
SELECT YEAR(order_date) AS year, author_name, SUM(price) AS total_revenue,
       RANK() OVER (PARTITION BY YEAR(order_date) ORDER BY SUM(price) DESC) AS revenue_rank
FROM gold.fact_sales
JOIN gold.dim_books USING (book_id)
GROUP BY YEAR(order_date), author_name
ORDER BY year, revenue_rank;
GO

-- Identify Authors with Consistently High Sales Over Multiple Years
WITH AuthorSales AS (
    SELECT author_name, YEAR(order_date) AS year, SUM(price) AS total_revenue,
           RANK() OVER (PARTITION BY YEAR(order_date) ORDER BY SUM(price) DESC) AS revenue_rank
    FROM gold.fact_sales
    JOIN gold.dim_books USING (book_id)
    GROUP BY author_name, YEAR(order_date)
)
SELECT author_name, COUNT(year) AS years_in_top_rank
FROM AuthorSales
WHERE revenue_rank <= 5
GROUP BY author_name
ORDER BY years_in_top_rank DESC;
GO

-- Identify Authors with the Highest Sales Growth Year Over Year
WITH YearlyAuthorSales AS (
    SELECT author_name, YEAR(order_date) AS year, SUM(price) AS total_revenue
    FROM gold.fact_sales
    JOIN gold.dim_books USING (book_id)
    GROUP BY author_name, YEAR(order_date)
)
SELECT y1.author_name, y1.year, y1.total_revenue, 
       y2.total_revenue AS prev_year_revenue,
       ((y1.total_revenue - y2.total_revenue) / NULLIF(y2.total_revenue, 0)) * 100 AS year_over_year_growth
FROM YearlyAuthorSales y1
LEFT JOIN YearlyAuthorSales y2 ON y1.author_name = y2.author_name AND y1.year = y2.year + 1
ORDER BY year_over_year_growth DESC;
GO

-- Identify Authors with the Most Books in the Top 100 Best-Sellers
WITH BookSales AS (
    SELECT book_id, title, author_name, SUM(price) AS total_revenue,
           RANK() OVER (ORDER BY SUM(price) DESC) AS revenue_rank
    FROM gold.fact_sales
    JOIN gold.dim_books USING (book_id)
    GROUP BY book_id, title, author_name
)
SELECT author_name, COUNT(book_id) AS books_in_top_100
FROM BookSales
WHERE revenue_rank <= 100
GROUP BY author_name
ORDER BY books_in_top_100 DESC;
GO

-- Identify Author Performance by Book Category
SELECT author_name, category, SUM(price) AS total_revenue, COUNT(order_id) AS total_orders
FROM gold.fact_sales
JOIN gold.dim_books USING (book_id)
GROUP BY author_name, category
ORDER BY total_revenue DESC;
GO

-- Identify Author Performance by Sales Region
SELECT author_name, country_name, SUM(price) AS total_revenue, COUNT(order_id) AS total_orders
FROM gold.fact_sales
JOIN gold.dim_books USING (book_id)
JOIN gold.dim_customers USING (customer_id)
GROUP BY author_name, country_name
ORDER BY total_revenue DESC;
GO
