-- Databricks notebook source
USE retail_dw;

-- COMMAND ----------

INSERT INTO fact_sales

SELECT
    (SELECT COALESCE(MAX(SalesSK), 0)
     FROM fact_sales)
    + ROW_NUMBER() OVER (
        ORDER BY s.TransactionID
      ) AS SalesSK,

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
    ON s.StoreID = st.StoreID

WHERE s.TransactionID NOT IN (
    SELECT TransactionID
    FROM fact_sales
);