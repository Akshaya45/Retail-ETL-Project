-- Databricks notebook source
USE retail_dw;

-- COMMAND ----------

DROP TABLE IF EXISTS dim_customers;

CREATE TABLE dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY CustomerID, LastUpdated) AS CustomerSK,
    CustomerID,
    CustomerName,
    Email,
    City,
    Address,
    CURRENT_DATE() AS StartDate,
    CAST('9999-12-31' AS DATE) AS EndDate,
    1 AS IsActive
FROM silver_customers;

-- COMMAND ----------

DROP TABLE IF EXISTS dim_products;

CREATE TABLE dim_products AS

SELECT
    ROW_NUMBER() OVER (ORDER BY ProductID) AS ProductSK,
    ProductID,
    ProductName,
    Category,
    UnitPrice,
    CURRENT_DATE() AS EffectiveDate

FROM silver_products;

-- COMMAND ----------

DROP TABLE IF EXISTS dim_stores;

CREATE TABLE dim_stores AS

SELECT
    ROW_NUMBER() OVER (ORDER BY StoreID) AS StoreSK,
    StoreID,
    StoreName,
    Region

FROM silver_stores;

-- COMMAND ----------

DROP TABLE IF EXISTS fact_sales;

CREATE TABLE fact_sales AS

SELECT
    ROW_NUMBER() OVER (ORDER BY s.TransactionID) AS SalesSK,
    s.TransactionID,
    c.CustomerSK,
    p.ProductSK,
    st.StoreSK,
    s.Quantity,
    s.Quantity * p.UnitPrice AS Amount,
    s.TxnDate

FROM silver_sales s

JOIN (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY CustomerID
                   ORDER BY CustomerSK DESC
               ) AS rn
        FROM dim_customers
        WHERE IsActive = 1
    )
    WHERE rn = 1
) c
ON s.CustomerID = c.CustomerID

JOIN dim_products p
    ON s.ProductID = p.ProductID

JOIN dim_stores st
    ON s.StoreID = st.StoreID;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC VALIDATION

-- COMMAND ----------

SELECT * FROM dim_customers LIMIT 10;

-- COMMAND ----------

SELECT * FROM dim_products LIMIT 10;

-- COMMAND ----------

SELECT * FROM dim_stores LIMIT 10;

-- COMMAND ----------

SELECT * FROM fact_sales LIMIT 10;

-- COMMAND ----------

-- 1. Check row counts
SELECT COUNT(*) FROM dim_customers;

-- COMMAND ----------

SELECT COUNT(*) FROM dim_products;

-- COMMAND ----------

SELECT COUNT(*) FROM dim_stores;

-- COMMAND ----------

SELECT COUNT(*) FROM fact_sales;

-- COMMAND ----------

SELECT CustomerID, COUNT(*) AS active_count
FROM dim_customers
WHERE IsActive = 1
GROUP BY CustomerID
HAVING COUNT(*) > 1;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC Duplicate CustomerID records were retained with unique surrogate keys for SCD/history analysis and reported as a data quality issue.

-- COMMAND ----------

SELECT * FROM dim_customers;

-- COMMAND ----------

SELECT * FROM fact_sales LIMIT 20;