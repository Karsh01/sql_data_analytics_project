/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'BookstoreDWH' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, this script creates schemas
    for 'bronze', 'silver', and 'gold' layers.

WARNING:
    Running this script will drop the entire 'BookstoreDWH' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

USE master;
GO

-- Drop and recreate the 'BookstoreDWH' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'BookstoreDWH')
BEGIN
    ALTER DATABASE BookstoreDWH SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE BookstoreDWH;
END;
GO

-- Create the 'BookstoreDWH' database
CREATE DATABASE BookstoreDWH;
GO

USE BookstoreDWH;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO

-- Create Gold Layer Tables
CREATE TABLE gold.dim_customers (
    customer_id     INT PRIMARY KEY,
    first_name      NVARCHAR(255),
    last_name       NVARCHAR(255),
    email           NVARCHAR(255),
    city            NVARCHAR(100),
    country_name    NVARCHAR(100),
    address_status  NVARCHAR(50)
);
GO

CREATE TABLE gold.dim_books (
    book_id         INT PRIMARY KEY,
    title           NVARCHAR(255),
    isbn13          NVARCHAR(13),
    author_name     NVARCHAR(255),
    language_name   NVARCHAR(100),
    num_pages       INT,
    publication_date DATE,
    publisher_name  NVARCHAR(255)
);
GO

CREATE TABLE gold.dim_orders (
    order_id        INT PRIMARY KEY,
    order_date      DATE,
    customer_id     INT,
    status_value    NVARCHAR(50)
);
GO

CREATE TABLE gold.fact_sales (
    order_id        INT,
    order_date      DATE,
    customer_id     INT,
    book_id         INT,
    price          DECIMAL(10,2),
    status_id       INT,
    status_value    NVARCHAR(50)
);
GO

-- Load Data into Gold Layer
TRUNCATE TABLE gold.dim_customers;
GO

BULK INSERT gold.dim_customers
FROM '/Users/karsh/Downloads/sql-analytics-project/gold.dim_customers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
GO

TRUNCATE TABLE gold.dim_books;
GO

BULK INSERT gold.dim_books
FROM '/Users/karsh/Downloads/sql-analytics-project/gold.dim_books.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
GO

TRUNCATE TABLE gold.dim_orders;
GO

BULK INSERT gold.dim_orders
FROM '/Users/karsh/Downloads/sql-analytics-project/gold.dim_orders.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
GO

TRUNCATE TABLE gold.fact_sales;
GO

BULK INSERT gold.fact_sales
FROM '/Users/karsh/Downloads/sql-analytics-project/gold.fact_sales.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
GO
