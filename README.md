# 🛒 Retail ETL Data Warehouse Project

## 📌 Overview

This project implements an end-to-end ETL pipeline using AWS S3 and Databricks.
The goal is to ingest raw retail data, clean it, and transform it into a structured data warehouse model.

---

## 🏗️ Architecture

S3 → Bronze → Silver → Gold

* **Bronze Layer**: Raw data ingestion from S3
* **Silver Layer**: Data cleaning and transformation
* **Gold Layer**: Dimensional model (Fact & Dimension tables)

---

## ⚙️ Tech Stack

* AWS S3
* Databricks
* SQL

---

## 📂 Dataset

The dataset includes:

* Customers
* Products
* Stores
* Sales Transactions

---

