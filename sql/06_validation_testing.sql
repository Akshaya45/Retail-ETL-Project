-- Databricks notebook source
use retail_dw;

-- COMMAND ----------

--Duplicate TransactionID
SELECT
    TransactionID,
    COUNT(*) AS cnt

FROM fact_sales

GROUP BY TransactionID

HAVING COUNT(*) > 1;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC SOURCE TO TARGET VALIDATION
-- MAGIC

-- COMMAND ----------

--row count of source and target
SELECT 'bronze_customers' AS table_name, COUNT(*) AS row_count
FROM bronze_customers

UNION ALL

SELECT 'silver_customers', COUNT(*)
FROM silver_customers

UNION ALL

SELECT 'dim_customers', COUNT(*)
FROM dim_customers

UNION ALL

SELECT 'bronze_sales', COUNT(*)
FROM bronze_sales

UNION ALL

SELECT 'silver_sales', COUNT(*)
FROM silver_sales

UNION ALL

SELECT 'fact_sales', COUNT(*)
FROM fact_sales;

-- COMMAND ----------

--Colomn Mapping validation
SELECT
    b.CustomerID AS bronze_customerid,
    s.CustomerID AS silver_customerid,
    d.CustomerID AS gold_customerid

FROM bronze_customers b

JOIN silver_customers s
ON b.CustomerID = s.CustomerID

JOIN dim_customers d
ON s.CustomerID = d.CustomerID

LIMIT 20;

-- COMMAND ----------

SELECT
    b.CustomerID,
    b.CustomerName AS bronze_name,
    s.CustomerName AS silver_name,
    d.CustomerName AS gold_name,
    b.Email AS bronze_email,
    s.Email AS silver_email,
    d.Email AS gold_email,
    b.City AS bronze_city,
    s.City AS silver_city,
    d.City AS gold_city
FROM bronze_customers b
JOIN silver_customers s
ON CAST(b.CustomerID AS INT) = s.CustomerID
JOIN dim_customers d
ON s.CustomerID = d.CustomerID
;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC DATA TYPE VALIDATION

-- COMMAND ----------

DESCRIBE bronze_customers;

-- COMMAND ----------

DESCRIBE silver_customers;

-- COMMAND ----------

DESCRIBE dim_customers;


-- COMMAND ----------

DESCRIBE fact_sales;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC DATA TRANSFORMATION VALIDATION

-- COMMAND ----------

--LOWERCASE EMAIL VALIDATION
SELECT *
FROM silver_customers
WHERE Email != LOWER(Email);

-- COMMAND ----------

--TRIM VALIDATION
SELECT *
FROM silver_customers
WHERE CustomerName != TRIM(CustomerName)
   OR City != TRIM(City)
   OR Address != TRIM(Address);

-- COMMAND ----------

--DATE FORMATING VALIDATION
SELECT *
FROM silver_sales
WHERE TxnDate IS NULL;

-- COMMAND ----------

--CASE VALIDATION
SELECT *
FROM silver_stores
WHERE StoreName != INITCAP(StoreName);

-- COMMAND ----------

--DERIVED AMOUNT VALIDATION
SELECT
    f.TransactionID,
    f.Quantity,
    p.UnitPrice,
    f.Amount,
    (f.Quantity * p.UnitPrice) AS ExpectedAmount

FROM fact_sales f

JOIN dim_products p
ON f.ProductSK = p.ProductSK

WHERE f.Amount != (f.Quantity * p.UnitPrice);

-- COMMAND ----------

-- MAGIC %md
-- MAGIC DATA QUALITY VALIDATION

-- COMMAND ----------

--DUPLICATE TRANSACTION ID CHECK
SELECT
    TransactionID,
    COUNT(*) AS cnt

FROM fact_sales

GROUP BY TransactionID

HAVING COUNT(*) > 1;

-- COMMAND ----------

--REGION NULL CHECK
SELECT *
FROM silver_stores
WHERE Region IS NULL;

-- COMMAND ----------

--QUANTITY CHECK
SELECT *
FROM silver_sales
WHERE Quantity <= 0;


-- COMMAND ----------

--Referential Integrity Validation
SELECT *
FROM fact_sales
WHERE CustomerSK IS NULL
   OR ProductSK IS NULL
   OR StoreSK IS NULL;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC SCD TYPE 2 VALIDATION
-- MAGIC

-- COMMAND ----------

SELECT *
FROM dim_customers
WHERE CustomerID IN (
    SELECT CustomerID
    FROM dim_customers
    GROUP BY CustomerID
    HAVING COUNT(*) > 1
)
ORDER BY CustomerID, StartDate;

-- COMMAND ----------

--Active records validation
SELECT *

FROM dim_customers

WHERE IsActive = 1

AND EndDate <> CAST('9999-12-31' AS DATE);

-- COMMAND ----------

SELECT *
FROM dim_customers
WHERE IsActive = 0
AND EndDate = CAST('9999-12-31' AS DATE);

-- COMMAND ----------

-- MAGIC %md
-- MAGIC