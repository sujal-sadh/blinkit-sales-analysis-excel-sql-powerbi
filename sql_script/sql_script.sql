/*
=============================================================
 Project : Blinkit Sales Analysis
 File    : blinkit_analysis.sql
 Author  : Sujal Sadh
 Date    : 2025-10-04
 Database: PostgreSQL (tested), compatible with SQL standard
 Purpose : Data cleaning + exploratory sales analysis queries
=============================================================
*/

/* -----------------------------------------------------------
 STEP 1: Preview the dataset (sample rows)
------------------------------------------------------------*/
-- Show first 10 rows to understand structure
SELECT *
FROM blinkit_table
LIMIT 10;

/* -----------------------------------------------------------
 STEP 2: Data Cleaning - Standardize Item_Fat_Content
------------------------------------------------------------*/
-- Ensure consistent labels for fat content
UPDATE blinkit_table
SET Item_Fat_Content = CASE
    WHEN Item_Fat_Content ILIKE 'low fat' THEN 'Low Fat'
    WHEN Item_Fat_Content = 'LF'          THEN 'Low Fat'
    WHEN Item_Fat_Content = 'reg'         THEN 'Regular'
    ELSE Item_Fat_Content
END
WHERE Item_Fat_Content ILIKE 'low fat'
   OR Item_Fat_Content = 'LF'
   OR Item_Fat_Content = 'reg';

/* -----------------------------------------------------------
 STEP 3: Key Metrics (KPIs)
------------------------------------------------------------*/
-- Total sales in millions
SELECT CONCAT(CAST(SUM(Sales)/1000000 AS DECIMAL(10,2)), 'M') AS total_sales_millions
FROM blinkit_table;

-- Average sales per item
SELECT CAST(AVG(Sales) AS DECIMAL(10,1)) AS average_sales
FROM blinkit_table;

-- Total number of items
SELECT COUNT(*) AS number_of_items
FROM blinkit_table;

-- Average rating
SELECT CAST(AVG(Rating) AS DECIMAL(10,2)) AS average_rating
FROM blinkit_table;

/* -----------------------------------------------------------
 STEP 4: Sales Analysis by Category
------------------------------------------------------------*/
-- Total sales by fat content
SELECT 
    Item_Fat_Content,
    CAST(SUM(Sales) AS DECIMAL(10,2)) AS total_sales_by_fat_content
FROM blinkit_table
GROUP BY Item_Fat_Content
ORDER BY total_sales_by_fat_content DESC;

-- Total sales by item type
SELECT 
    Item_Type,
    CAST(SUM(Sales) AS DECIMAL(10,2)) AS total_sales_by_item_type
FROM blinkit_table
GROUP BY Item_Type
ORDER BY total_sales_by_item_type DESC;

-- Fat content contribution by outlet location
SELECT 
    Outlet_Location_Type,
    COALESCE(SUM(Sales) FILTER (WHERE Item_Fat_Content = 'Low Fat'), 0) AS Low_Fat,
    COALESCE(SUM(Sales) FILTER (WHERE Item_Fat_Content = 'Regular'), 0) AS Regular
FROM blinkit_table
GROUP BY Outlet_Location_Type
ORDER BY Outlet_Location_Type;

/* -----------------------------------------------------------
 STEP 5: Outlet-based Sales Analysis
------------------------------------------------------------*/
-- Total sales by outlet establishment year
SELECT 
    Outlet_Establishment_Year,
    CAST(SUM(Sales) AS DECIMAL(10,2)) AS total_sales
FROM blinkit_table
GROUP BY Outlet_Establishment_Year
ORDER BY Outlet_Establishment_Year ASC;

-- Percentage of sales by outlet size
SELECT 
    Outlet_Size, 
    CAST(SUM(Sales) AS DECIMAL(10,2)) AS total_sales,
    CAST((SUM(Sales) * 100.0 / SUM(SUM(Sales)) OVER()) AS DECIMAL(10,2)) AS sales_percentage
FROM blinkit_table
GROUP BY Outlet_Size
ORDER BY total_sales DESC;