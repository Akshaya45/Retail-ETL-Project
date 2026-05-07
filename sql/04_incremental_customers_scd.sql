-- Databricks notebook source
USE retail_dw;

-- COMMAND ----------

--detect changed customers
CREATE OR REPLACE TEMP VIEW changed_customers AS

SELECT
    s.CustomerID,
    s.CustomerName,
    s.Email,
    s.City,
    s.Address,
    s.LastUpdated

FROM silver_customers s

JOIN dim_customers d
ON s.CustomerID = d.CustomerID

WHERE d.IsActive = 1

AND (
    s.City <> d.City
    OR s.Address <> d.Address
);

-- COMMAND ----------

--expire old records
UPDATE dim_customers

SET
    EndDate = CURRENT_DATE(),
    IsActive = 0

WHERE CustomerID IN (

    SELECT CustomerID

    FROM changed_customers
);

-- COMMAND ----------

--insert new + changed rowa
INSERT INTO dim_customers

SELECT
    (SELECT COALESCE(MAX(CustomerSK), 0)
     FROM dim_customers)

    + ROW_NUMBER() OVER (ORDER BY s.CustomerID) AS CustomerSK,

    s.CustomerID,
    s.CustomerName,
    s.Email,
    s.City,
    s.Address,

    CURRENT_DATE() AS StartDate,

    CAST('9999-12-31' AS DATE) AS EndDate,

    1 AS IsActive

FROM silver_customers s

LEFT JOIN dim_customers d
ON s.CustomerID = d.CustomerID
AND d.IsActive = 1

WHERE d.CustomerID IS NULL

OR s.CustomerID IN (
    SELECT CustomerID
    FROM changed_customers
);