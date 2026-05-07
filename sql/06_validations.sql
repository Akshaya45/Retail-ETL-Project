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

--Active records validation
SELECT *

FROM dim_customers

WHERE IsActive = 1

AND EndDate <> CAST('9999-12-31' AS DATE);

-- COMMAND ----------

