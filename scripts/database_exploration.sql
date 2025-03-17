/*
===============================================================================
Database Exploration
===============================================================================
Purpose:
    - To explore the structure of the BookstoreDWH database, including the list of tables and their schemas.
    - To inspect the columns and metadata for specific tables within the bronze, silver, and gold layers.

Tables Used:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
===============================================================================
*/

-- Retrieve a list of all tables in the BookstoreDWH database
SELECT 
    TABLE_CATALOG AS Database_Name,
    TABLE_SCHEMA AS Schema_Name,
    TABLE_NAME AS Table_Name,
    TABLE_TYPE AS Table_Type
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_CATALOG = 'BookstoreDWH';
GO

-- Retrieve all columns for a specific table (gold.fact_sales)
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE, 
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'gold' AND TABLE_NAME = 'fact_sales';
GO

-- Retrieve all columns for a specific table (silver_orders)
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE, 
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'silver' AND TABLE_NAME = 'silver_orders';
GO

-- Retrieve all columns for a specific table (bronze.book)
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE, 
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'bronze' AND TABLE_NAME = 'book';
GO
