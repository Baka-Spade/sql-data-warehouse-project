
/*==============================================================================

Project         : SQL Data Warehouse
Layer           : Silver
Procedure/Script: Load Silver Layer
Database        : BakaDBW

Description:
    Loads the Silver layer by extracting data from the Bronze layer,
    applying data cleansing, validation, standardization, and business
    transformation rules before populating the Silver tables.

Transformation Summary:
    • Removes duplicate customer records
    • Cleans leading/trailing spaces
    • Standardizes gender and marital status values
    • Standardizes country names
    • Cleans customer and product identifiers
    • Corrects invalid sales and price values
    • Validates order, ship, and due dates
    • Calculates product end dates using LEAD()
    • Replaces invalid or missing values where appropriate

Load Type:
    Full Refresh (TRUNCATE + INSERT)

Execution Flow:
    Bronze
        ↓
    Data Cleansing
        ↓
    Data Validation
        ↓
    Data Standardization
        ↓
    Silver

Dependencies:
    Bronze Layer must be successfully loaded before execution.

Revision History==============================================================================*/




DECLARE @start_time DATETIME , @end_time DATETIME
SET @start_time = GETDATE()
PRINT('----------INITIALIZING SILVER LAYER LOAD--------')
PRINT('------------------------------------------------------------')
/*========================================
             CRM SOURCE
========================================*/
PRINT('Loading CRM Source.....')
PRINT('------------------------------------------------------------')
PRINT('Loading Silver.crm_cust_info......')
PRINT('>>Truncating Silver.crm_cust_info')
TRUNCATE TABLE Silver.crm_cust_info;
PRINT('>>Inserting Clean Data from Bronze Table')
INSERT INTO Silver.crm_cust_info (
	 [cst_id]
    ,[cst_key]
    ,[cst_firstname]
    ,[cst_lastname]
    ,[cst_marital_status]
    ,[cst_gndr]
    ,[cst_create_date]
)

SELECT 
	cst_id ,
	TRIM(cst_key) AS cst_Key, 
	TRIM(cst_firstname) AS cst_FirstName,
	TRIM(cst_lastname)AS cst_LastNmme,
		CASE WHEN TRIM(UPPER(cst_marital_status)) = 'S' THEN 'Single'
			 WHEN TRIM(UPPER(cst_marital_status)) = 'M' THEN 'Married'
		END AS cst_Marital_Status,
		CASE WHEN TRIM(UPPER(cst_gndr)) = 'M' THEN 'Male' 
			 WHEN TRIM(UPPER(cst_gndr)) = 'F' THEN 'Female'
		END AS cst_Gndr,
	cst_create_date 
FROM (
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag
	FROM Bronze.crm_cust_info
)t 
WHERE flag = 1 AND cst_id IS NOT NULL
PRINT('>>Insert Successful')
PRINT('------------------------------------------------------------')

------------------------------------------------------------

PRINT('Loading Silver.crm_prd_info......')
PRINT('>>Truncating Silver.crm_prd_info')
TRUNCATE TABLE Silver.crm_prd_info;
PRINT('>>Inserting Clean Data from Bronze Table')
INSERT INTO Silver.crm_prd_info
(
    prd_id,
    prd_key,
    prd_cat_Id,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)

SELECT * FROM (
SELECT 
	prd_id,
	SUBSTRING(prd_key, 7, len(prd_key)) AS Prd_key,
	REPLACE(SUBSTRING(prd_key, 1 , 5), '-', '_') AS Cat_Id,
	prd_nm,
	COALESCE(prd_cost, 0) AS prd_cost,
	CASE WHEN prd_line = 'S' THEN 'Sports'
		WHEN prd_line = 'R' THEN 'Road'
		WHEN prd_line = 'M' THEN 'Mountain'
		WHEN prd_line = 'T' THEN 'Touring'
		Else 'Unknown'
	END AS Prd_line,
	prd_start_dt,
	DATEADD(DAY , -1,LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)) AS prd_end_dt
FROM Bronze.crm_prd_info 
)t

PRINT('>>Insert Successful')
PRINT('------------------------------------------------------------')


-------------------------------------------------------

PRINT('Loading Silver.crm_sales_details......')
PRINT('>>Truncating Silver.crm_sales_details')
TRUNCATE TABLE silver.crm_sales_details;

PRINT('>>Inserting Clean Data from Bronze Table')
;WITH SalesCTE AS 
( 
SELECT *,
CASE WHEN sls_sales IS NULL 
		   OR sls_sales <= 0 
		   OR sls_sales <> (ABS(sls_price) * sls_quantity) 
		 THEN (ABS(sls_price) * NULLIF(sls_quantity, 0)) 
	 ELSE sls_sales
	END AS C_sls_sales
FROM Bronze.crm_sales_details
)

INSERT INTO silver.crm_sales_details 
(
    sls_ord_num ,
    sls_prd_key ,
    sls_cust_id ,
    sls_order_dt ,
    sls_ship_dt ,
    sls_due_dt ,
    sls_sales ,
    sls_quantity ,
    sls_price 

)
	
SELECT 
	TRIM(sls_ord_num),
	sls_prd_key,
	sls_cust_id,
	CASE 
		WHEN sls_order_dt = 0 OR LEN(sls_order_dt) <> 8 THEN NULL 
		ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
	END AS sls_order_dt,
	CASE 
		WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) <> 8 THEN NULL 
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) 
	END AS sls_ship_dt,
	CASE 
		WHEN sls_due_dt = 0 OR LEN(sls_due_dt) <> 8 THEN NULL 
		ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) 
	END AS sls_due_dt,
	C_sls_sales,
	sls_quantity,
	CASE WHEN sls_price IS NULL 
		   OR sls_price <= 0 
		   OR sls_price <> (ABS(C_sls_sales) / sls_quantity) 
		 THEN (ABS(C_sls_sales) / NULLIF(sls_quantity, 0)) 
		 ELSE sls_price
	END AS sls_price
FROM SalesCTE

PRINT('>>Insert Successful')
PRINT('------------------------------------------------------------')

------------------------------------------------------------

/*========================================
             ERP SOURCE
========================================*/
PRINT('Loading ERP Source.....')
PRINT('------------------------------------------------------------')
------------------------------------------------------------
PRINT('Loading Silver.erp_CUST_AZ12......')
PRINT('>>Truncating Silver.erp_CUST_AZ12')
TRUNCATE TABLE Silver.erp_CUST_AZ12;
PRINT('>>Inserting Clean Data from Bronze Table')
INSERT INTO Silver.erp_CUST_AZ12
(
    CID,
    BDATE, 
    GEN 
)

SELECT 
	CASE 
		WHEN TRIM(CID) LIKE 'NAS%' THEN TRIM(SUBSTRING(CID, 4 ,LEN(CID)))
		ELSE TRIM(CID)
	END AS CID,
	CASE
		WHEN BDATE > GETDATE() THEN NULL
		ELSE BDATE 
	END AS BDATE,
	CASE WHEN TRIM(GEN) = 'M' THEN 'Male'
		WHEN TRIM(GEN) = 'F' THEN 'Female'
		WHEN GEN <> TRIM(GEN) OR GEN = '' THEN NULL
		ELSE GEN
	END AS GEN
FROM Bronze.erp_CUST_AZ12 

PRINT('>>Insert Successful')
------------------------------------------------------------
PRINT('Loading Silver.erp_LOC_A101......')
PRINT('>>Truncating Silver.erp_LOC_A101')
TRUNCATE TABLE silver.erp_LOC_A101;
PRINT('>>Inserting Clean Data from Bronze Table')
INSERT INTO silver.erp_LOC_A101
(
	CID,
	CNTRY
)


SELECT 
	REPLACE(TRIM(CID) , '-' , '') AS CID,
	CASE 
		WHEN CNTRY = 'DE' THEN 'Germany'
		WHEN CNTRY = 'UK' THEN 'United Kingdom'
		WHEN CNTRY = 'US' OR CNTRY = 'USA' THEN 'United States'
		WHEN TRIM(CNTRY) = '' THEN NULL
		ELSE TRIM(CNTRY)
	END AS CNTRY
FROM Bronze.erp_LOC_A101

PRINT('>>Insert Successful')
PRINT('------------------------------------------------------------')

------------------------------------------------------------

PRINT('Loading Silver.erp_PX_CAT_G1V2......')
PRINT('>>Truncating Silver.erp_PX_CAT_G1V2')
TRUNCATE TABLE Silver.erp_PX_CAT_G1V2;
PRINT('>>Inserting Clean Data from Bronze Table')
INSERT INTO Silver.erp_PX_CAT_G1V2
(
	ID ,
    CAT,
    SUBCAT,
    MAINTENANCE
)

SELECT 
	TRIM(ID),
	TRIM(CAT),
	TRIM(SUBCAT),
	TRIM(MAINTENANCE)
FROM Bronze.erp_PX_CAT_G1V2

PRINT('>>Insert Successful')
PRINT('------------------------------------------------------------')

------------------------------------------------------------

SET @end_time = GETDATE()

PRINT('--------SILVER LAYER SUCCESSFULLY LOADED--------')
PRINT('>>Time Taken ' + CAST(DATEDIFF(second,@start_time,@end_time) AS VARCHAR) + 's')
PRINT('------------------------------------------------------------')
