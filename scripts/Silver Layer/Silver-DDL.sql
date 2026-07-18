USE BakaDBW

/*==============================================================================
Layer        : Silver
Description  :

This script initializes the Silver layer by:

• Creating cleansed and standardized tables
• Removing any existing data

Source Systems
--------------
• CRM
• ERP

WARNING
-------
This script recreates all Silver tables.
Existing data will be permanently removed.
==============================================================================*/

DECLARE @start DATETIME, @end DATETIME;

SET @start = GETDATE();

PRINT('-------------------------------------')
PRINT('Loading Silver Layer........')
PRINT('-------------------------------------')

/*========================================
             CRM SOURCE
========================================*/
PRINT('-------------------------------------')
PRINT('Loading from CRM Source.............')
PRINT('-------------------------------------')

------------------------------------------
-- Silver.crm_cust_info

DROP TABLE IF EXISTS Silver.crm_cust_info;
CREATE TABLE Silver.crm_cust_info
(
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE,
    dwh_Creation_Date DATETIME2 DEFAULT GETDATE()
);

------------------------------------------
-- Silver.crm_prd_info

DROP TABLE IF EXISTS Silver.crm_prd_info;
CREATE TABLE Silver.crm_prd_info
(
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_cat_Id NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwh_Creation_Date DATETIME2 DEFAULT GETDATE()
);
------------------------------------------
-- Silver.crm_sales_details

DROP TABLE IF EXISTS Silver.crm_sales_details;
CREATE TABLE Silver.crm_sales_details
(
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
    dwh_Creation_Date DATETIME2 DEFAULT GETDATE()
);
PRINT('-------------------------------------')
PRINT('SUCCESS')
PRINT('-------------------------------------')

/*========================================
             ERP SOURCE
========================================*/
PRINT('-------------------------------------')
PRINT('Loading from ERP Source.............')
PRINT('-------------------------------------')

------------------------------------------
-- Silver.erp_CUST_AZ12

DROP TABLE IF EXISTS Silver.erp_CUST_AZ12;
CREATE TABLE Silver.erp_CUST_AZ12
(
    CID NVARCHAR(50),
    BDATE DATE,
    GEN NVARCHAR(50),
    dwh_Creation_Date DATETIME2 DEFAULT GETDATE()
);

------------------------------------------
-- Silver.erp_LOC_A101

DROP TABLE IF EXISTS Silver.erp_LOC_A101;
CREATE TABLE Silver.erp_LOC_A101
(
    CID NVARCHAR(50),
    CNTRY NVARCHAR(50),
    dwh_Creation_Date DATETIME2 DEFAULT GETDATE()
);
------------------------------------------
-- Silver.erp_PX_CAT_G1V2

DROP TABLE IF EXISTS Silver.erp_PX_CAT_G1V2;
CREATE TABLE Silver.erp_PX_CAT_G1V2
(
    ID NVARCHAR(50),
    CAT NVARCHAR(50),
    SUBCAT NVARCHAR(50),
    MAINTENANCE NVARCHAR(50),
    dwh_Creation_Date DATETIME2 DEFAULT GETDATE()
);

PRINT('-------------------------------------')
PRINT('SUCCESS')
PRINT('-------------------------------------')

SET @end = GETDATE();

------------------------------------------
PRINT('*=========================================================')
PRINT('End of Script')
PRINT('Time Taken ' + CAST(DATEDIFF(SECOND, @start, @end) AS NVARCHAR) + ' seconds')
PRINT('Silver Layer has been initialized successfully.')
PRINT('=========================================================')
