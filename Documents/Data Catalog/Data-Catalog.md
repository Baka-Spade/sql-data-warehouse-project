# Gold Layer Data Catalog

## Document Information

| Property | Value |
|----------|-------|
| Project | SQL Data Warehouse |
| Database | BakaDBW |
| Schema | Gold |
| Layer | Presentation |
| Architecture | Medallion Architecture |
| Data Model | Star Schema |
| Author | Arpit Panchal |
| Version | 1.0 |

---

# Purpose

The Gold layer represents the presentation layer of the SQL Data Warehouse. It provides business-ready datasets optimized for reporting, analytics, and dashboarding.

Unlike the Bronze and Silver layers, the Gold layer is designed for analytical consumption by business users and BI tools. The underlying data has already been cleansed, standardized, and validated in the Silver layer.

---

# Design Principles

The Gold layer follows these principles:

- Star Schema dimensional modeling
- Business-friendly naming conventions
- Conformed dimensions
- Surrogate keys for analytical joins
- Minimal business logic
- Optimized for reporting and analytics

---

# Gold Layer Objects

| Object | Type | Description |
|---------|------|-------------|
| Gold.Dim_Customers | Dimension | Customer master data enriched from CRM and ERP |
| Gold.Dim_Products | Dimension | Product master data enriched with category information |
| Gold.Fact_Sales | Fact | Transactional sales data linked to customer and product dimensions |

---

# Star Schema

*(Insert Gold_Diagram.png here)*

```html
<p align="center">
<img src="images/Gold_Diagram.png" width="900">
</p>
```

---

# Dimension: Gold.Dim_Customers

## Overview

| Property | Value |
|----------|-------|
| Object Type | View |
| Grain | One row per customer |
| Primary Key | Customer_Key |
| Business Key | Customer_Id |

### Source Tables

- Silver.crm_cust_info
- Silver.erp_CUST_AZ12
- Silver.erp_LOC_A101

---

## Column Dictionary

| Column | Data Type | Description |
|---------|-----------|-------------|
| Customer_Key | INT | Warehouse surrogate key |
| Customer_Id | INT | Customer identifier from CRM |
| Customer_No | NVARCHAR(50) | Business customer number |
| FirstName | NVARCHAR(50) | Customer first name |
| LastName | NVARCHAR(50) | Customer last name |
| Country | NVARCHAR(50) | Customer country from ERP |
| Gender | NVARCHAR(50) | Customer gender |
| MaritalStatus | NVARCHAR(50) | Customer marital status |
| Birth_Date | DATE | Customer date of birth |
| Create_Date | DATE | Customer creation date |

---

## Business Rules

- CRM is the primary source for customer information.
- ERP enriches demographic and geographical attributes.
- CRM gender takes precedence over ERP gender.
- One record exists per customer.

---

## Data Quality Rules

- Customer_Key must be unique.
- Customer_Id must be unique.
- Birth_Date cannot be in the future.
- Country should contain standardized values.

---

# Dimension: Gold.Dim_Products

## Overview

| Property | Value |
|----------|-------|
| Object Type | View |
| Grain | One row per active product |
| Primary Key | Product_Key |
| Business Key | Product_No |

### Source Tables

- Silver.crm_prd_info
- Silver.erp_PX_CAT_G1V2

---

## Column Dictionary

| Column | Data Type | Description |
|---------|-----------|-------------|
| Product_Key | INT | Warehouse surrogate key |
| Product_Id | INT | Product identifier |
| Product_No | NVARCHAR(50) | Business product number |
| Product_Name | NVARCHAR(50) | Product name |
| Product_Category_Id | NVARCHAR(50) | Product category identifier |
| Product_Category | NVARCHAR(50) | Product category |
| Product_SubCategory | NVARCHAR(50) | Product subcategory |
| Product_Line | NVARCHAR(50) | Product line |
| Product_Maintenance | NVARCHAR(50) | Maintenance classification |
| Product_Cost | INT | Product cost |
| Product_Start_Date | DATE | Product start date |

---

## Business Rules

- Only active products are included.
- Product categories are enriched using ERP reference data.
- One record exists per active product.

---

## Data Quality Rules

- Product_Key must be unique.
- Product_No must be unique.
- Product cost cannot be negative.
- Product category must exist.

---

# Fact: Gold.Fact_Sales

## Overview

| Property | Value |
|----------|-------|
| Object Type | View |
| Grain | One row per sales transaction |

### Source Tables

- Silver.crm_sales_details
- Gold.Dim_Customers
- Gold.Dim_Products

---

## Column Dictionary

| Column | Data Type | Description |
|---------|-----------|-------------|
| Order_No | NVARCHAR(50) | Sales order number |
| Product_Key | INT | Foreign key to Dim_Products |
| Customer_Key | INT | Foreign key to Dim_Customers |
| Order_Date | DATE | Order date |
| Ship_Date | DATE | Shipping date |
| Due_Date | DATE | Due date |
| Sales_Amount | INT | Sales value |
| Quantity | INT | Quantity sold |
| Price | INT | Unit price |

---

## Business Rules

- Customer business keys are translated into surrogate keys.
- Product business keys are translated into surrogate keys.
- The fact table stores measures only.
- Descriptive attributes are maintained in dimensions.

---

## Data Quality Rules

- Customer_Key must exist in Dim_Customers.
- Product_Key must exist in Dim_Products.
- Quantity must be greater than zero.
- Sales_Amount must not be negative.
- Order_Date cannot be NULL.

---

# Relationships

| Parent | Child | Relationship |
|----------|-------|--------------|
| Dim_Customers | Fact_Sales | 1 : Many |
| Dim_Products | Fact_Sales | 1 : Many |

---


# Business Glossary

| Term | Definition |
|------|------------|
| Fact Table | Stores measurable business events. |
| Dimension | Stores descriptive business information. |
| Business Key | Identifier originating from the source system. |
| Surrogate Key | Warehouse-generated key used for joins. |
| Grain | The level of detail represented by one row. |
| Star Schema | Dimensional model consisting of fact and dimension tables. |

---

# Known Limitations

- Gold objects are implemented as SQL views.
- Surrogate keys are generated using `ROW_NUMBER()` and are not persistent.
- Date dimension has not yet been implemented.
- Incremental loading is not supported.

---

# Future Enhancements

- Implement persistent surrogate keys.
- Add Dim_Date.
- Support Slowly Changing Dimensions (Type 2).
- Introduce incremental ETL processing.
- Add audit columns (DW_Load_Date, Record_Source).

---

