
/*==============================================================================
Layer        : Bronze
Description  :

This script initializes the Bronze layer by:

• Creating raw staging tables
• Removing any existing data
• Loading source files using BULK INSERT

Source Systems
--------------
• CRM
• ERP

WARNING
-------
This script recreates all Bronze tables.
Existing data will be permanently removed.
==============================================================================*/

DECLARE @start DATETIME, @end DATETIME;


SET @start = GETDATE();


PRINT('-------------------------------------')
PRINT('Loading Bronze Layer........')
PRINT('-------------------------------------')
/*========================================
			 CRM SOURCE
========================================*/
PRINT('-------------------------------------')
PRINT('Loading from CRM Source.............')
PRINT('-------------------------------------')
------------------------------------------
-- Bronze.crm_cust_info

DROP TABLE IF EXISTS Bronze.crm_cust_info;
CREATE TABLE Bronze.crm_cust_info 
(
	cst_id INT,
	cst_key	NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE	
); 

TRUNCATE TABLE Bronze.crm_cust_info;
BULK INSERT Bronze.crm_cust_info
FROM 'C:\sqlbackups\source_crm\cust_info.csv'
WITH 
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);


------------------------------------------
-- Bronze.crm_prd_info

DROP TABLE IF EXISTS Bronze.crm_prd_info ;
CREATE TABLE Bronze.crm_prd_info 
(
	prd_id INT,
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE
); 

TRUNCATE TABLE Bronze.crm_prd_info;
BULK INSERT Bronze.crm_prd_info
FROM 'C:\sqlbackups\source_crm\prd_info.csv'
WITH 
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);


------------------------------------------
-- Bronze.crm_sales_details

DROP TABLE IF EXISTS Bronze.crm_sales_details;
CREATE TABLE Bronze.crm_sales_details 
(
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt NVARCHAR(50),
	sls_ship_dt NVARCHAR(50),
	sls_due_dt NVARCHAR(50),
	sls_sales INT,
	sls_quantity INT,
	sls_price INT
); 

TRUNCATE TABLE Bronze.crm_sales_details;
BULK INSERT Bronze.crm_sales_details
FROM 'C:\sqlbackups\source_crm\sales_details.csv'
WITH 
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);

PRINT('-------------------------------------')
PRINT('SUCCESS')
PRINT('-------------------------------------')
------------------------------------------

/*========================================
			 ERP SOURCE
========================================*/
PRINT('-------------------------------------')
PRINT('Loading from ERP Source.............')
PRINT('-------------------------------------')
------------------------------------------
-- Bronze.erp_CUST_AZ12

DROP TABLE IF EXISTS Bronze.erp_CUST_AZ12;
CREATE TABLE Bronze.erp_CUST_AZ12
(
	CID NVARCHAR(50),
	BDATE DATE,
	GEN NVARCHAR(50)
); 

TRUNCATE TABLE Bronze.erp_CUST_AZ12;
BULK INSERT Bronze.erp_CUST_AZ12
FROM 'C:\sqlbackups\source_erp\CUST_AZ12.csv'
WITH
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);


------------------------------------------
-- Bronze.erp_LOC_A101

DROP TABLE IF EXISTS Bronze.erp_LOC_A101; 
CREATE TABLE Bronze.erp_LOC_A101 
(
	CID NVARCHAR(50),
	CNTRY NVARCHAR(50)
); 

TRUNCATE TABLE Bronze.erp_LOC_A101;
BULK INSERT Bronze.erp_LOC_A101
FROM 'C:\sqlbackups\source_erp\LOC_A101.csv'
WITH 
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);


------------------------------------------
-- Bronze.erp_PX_CAT_G1V2

DROP TABLE IF EXISTS Bronze.erp_PX_CAT_G1V2;
CREATE TABLE Bronze.erp_PX_CAT_G1V2 
(
	ID NVARCHAR(50),
	CAT NVARCHAR(50),
	SUBCAT NVARCHAR(50),
	MAINTENANCE NVARCHAR(50)
); 

TRUNCATE TABLE Bronze.erp_PX_CAT_G1V2;
BULK INSERT Bronze.erp_PX_CAT_G1V2
FROM 'C:\sqlbackups\source_erp\PX_CAT_G1V2.csv'
WITH 
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
);

PRINT('-------------------------------------')
PRINT('SUCCESS')
PRINT('-------------------------------------')
SET @end = GETDATE()

------------------------------------------
PRINT('*=========================================================')
PRINT('End of Script')
PRINT('Time Taken ' + CAST(DATEDIFF(second,@start,@end) AS NVARCHAR) + 'seconds')
PRINT('Bronze Layer has been initialized successfully.')
PRINT('=========================================================')
