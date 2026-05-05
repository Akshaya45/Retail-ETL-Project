-- Databricks notebook source
CREATE DATABASE IF NOT EXISTS retail_dw;
USE retail_dw;

-- COMMAND ----------

DROP TABLE IF EXISTS bronze_customers;

CREATE TABLE bronze_customers
USING CSV
OPTIONS (
  path "s3://salessprintt9/customers_src_20042026100105.csv",
  header "true"
);

-- COMMAND ----------

DROP TABLE IF EXISTS bronze_products;

CREATE TABLE bronze_products
USING CSV
OPTIONS (
  path "s3://salessprintt9/products_src_20042026100105.csv",
  header "true",
  inferSchema "true"
);

-- COMMAND ----------

DROP TABLE IF EXISTS bronze_sales;

CREATE TABLE bronze_sales
USING CSV
OPTIONS (
  path "s3://salessprintt9/sales_transactions_src_20042026100107.csv",
  header "true",
  inferSchema "true"
);

-- COMMAND ----------

DROP TABLE IF EXISTS bronze_stores;

CREATE TABLE bronze_stores
USING CSV
OPTIONS (
  path "s3://salessprintt9/stores_src_20042026100107.csv",
  header "true",
  inferSchema "true"
);

-- COMMAND ----------

SELECT * FROM bronze_customers LIMIT 10;

-- COMMAND ----------

SELECT * FROM bronze_products LIMIT 10;

-- COMMAND ----------

SELECT * FROM bronze_sales LIMIT 10;

-- COMMAND ----------

SELECT * FROM bronze_stores LIMIT 10;