# 🏗️ Medallion Data Warehouse Project (PostgreSQL)

## 📌 Overview
This project implements a **Medallion Architecture (Bronze → Silver → Gold)** data warehouse using **PostgreSQL**.  
The dataset consists of **1M+ records from an online sports store**, including CRM and ERP data sources.

The goal is to transform raw CSV data into **analytics-ready dimensional models** for reporting and business insights.

---

## 🧱 Architecture

### 🔹 Bronze Layer (Raw Data)
- Stores raw ingested data from CSV files
- No transformations applied
- Schema: `bronze`

**Tables:**
- `crm_cust_info`
- `crm_prd_info`
- `crm_sales_details`
- `erp_cust_az12`
- `erp_loc_a101`
- `erp_px_cat_g1v2`

---

### 🔹 Silver Layer (Cleaned & Transformed)
- Data cleaning, standardization, and validation
- Handles:
  - Null values
  - Duplicates
  - Data type corrections
  - Business rule transformations

**Key Transformations:**
- Trimmed string fields
- Standardized gender & marital status
- Converted integer dates → `DATE`
- Data validation for sales & pricing
- Deduplication using `ROW_NUMBER()`

**ETL Procedures:**
- `silver.clean_silver()` → truncates tables
- `silver.load_silver()` → loads cleaned data

---

### 🔹 Gold Layer (Analytics / BI)
- Dimensional modeling (Star Schema)
- Optimized for reporting & dashboards

**Views:**
- `gold.dim_customers`
- `gold.dim_products`
- `gold.fact_sales`

---

## 📊 Data Model (Star Schema)

### 🧑‍💼 Dimension Tables
- **dim_customers**
  - Customer demographics
  - Enriched with ERP data

- **dim_products**
  - Product hierarchy (Category, Subcategory)
  - Active product filtering (`prd_end_dt IS NULL`)

### 📈 Fact Table
- **fact_sales**
  - Sales transactions
  - Linked via surrogate keys:
    - `product_key`
    - `customer_key`

---

## ⚙️ Tech Stack
- **Database:** PostgreSQL
- **Language:** SQL (PL/pgSQL)
- **Architecture:** Medallion (Bronze, Silver, Gold)
- **Concepts:**
  - ETL Pipelines
  - Data Cleaning & Validation
  - Window Functions
  - Slowly Changing Dimensions (SCD)
  - Star Schema Modeling

---

## 🧠 Key Features

- ✔ **Medallion Architecture implementation** (Bronze → Silver → Gold)
- ✔ **End-to-end ETL pipeline** using PostgreSQL
- ✔ **Data quality checks** (duplicates, null handling, validation rules)
- ✔ **Business rule transformations** for clean analytics-ready data
- ✔ **Surrogate key generation** using window functions (`ROW_NUMBER()`)
- ✔ **Scalable design** for large datasets (1M+ records)

---

## 📌 Sample Business Use Cases

- **Customer Segmentation Analysis**  
  Identify customer demographics, behavior patterns, and lifecycle stages.

- **Product Performance Tracking**  
  Analyze product categories, sales contribution, and lifecycle trends.

- **Sales Trend Analysis**  
  Evaluate order patterns, seasonality, and revenue growth over time.

- **Revenue & Pricing Validation**  
  Ensure consistency between sales, quantity, and pricing logic.

---

## 📈 Future Improvements

- Implement **Slowly Changing Dimensions (SCD Type 2)** for historical tracking  
- Add **indexes and partitioning** for performance optimization  
- Integrate with **Power BI / Tableau** for interactive dashboards  
- Automate pipeline orchestration using **Airflow / dbt**  
- Add **data quality monitoring & alerting**

---

# 🚀 Why This Version Works

- **Recruiter-friendly** → clear sections, business value  
- **ATS-friendly** → keywords like ETL, Data Warehouse, Star Schema  
- **Data Engineer-level** → includes architecture + pipeline + modeling  
- **Project storytelling** → not just code, but impact  

---

If you want, I can:
- Add **architecture diagram (very high impact for GitHub)**
- Optimize this for **resume bullet points**
- Convert this into a **portfolio case study (with storytelling)**
