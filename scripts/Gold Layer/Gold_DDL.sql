/*==============================================================================
Project       : SQL Data Warehouse
Database      : BakaDBW
Schema        : Gold
Layer         : Gold
Object Type   : Views

===============================================================================
DESCRIPTION
-------------------------------------------------------------------------------
Creates the Gold layer presentation model by exposing business-ready dimensions
and fact views built on top of the standardized Silver layer.

The Gold layer follows a Star Schema design and is optimized for analytical
queries, reporting, and dashboarding.

===============================================================================
OBJECTS CREATED
-------------------------------------------------------------------------------
• Gold.Dim_Customers
• Gold.Dim_Products
• Gold.Fact_Sales

===============================================================================
SOURCE OBJECTS
-------------------------------------------------------------------------------
CRM
• Silver.crm_cust_info
• Silver.crm_prd_info
• Silver.crm_sales_details

ERP
• Silver.erp_CUST_AZ12
• Silver.erp_LOC_A101
• Silver.erp_PX_CAT_G1V2

===============================================================================
DESIGN PRINCIPLES
-------------------------------------------------------------------------------
• Star Schema
• Business-Friendly Naming
• Conformed Dimensions
• Surrogate Keys
• Fact-Dimension Relationships
• Reporting Optimized
• Current-State Dimensions

===============================================================================
BUSINESS RULES
-------------------------------------------------------------------------------
• Customer information is mastered from CRM and enriched using ERP.
• CRM Gender takes precedence over ERP Gender.
• Only active products are exposed.
• Product categories are enriched using ERP reference data.
• Fact table stores only transactional measures and foreign keys.

===============================================================================
DEPENDENCIES
-------------------------------------------------------------------------------
Bronze Layer
        ↓
Silver Layer
        ↓
Gold Layer
        ↓
Power BI / Analytics

===============================================================================
NOTES
-------------------------------------------------------------------------------
• Surrogate keys are generated using ROW_NUMBER() because Gold objects are
  implemented as views.

•
===============================================================================
*/--------------------------------------------------------------
--Gold.Dim_Customers

CREATE VIEW Gold.Dim_Customers
AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY cst_id) AS Customer_Key,
	CI.cst_id AS Customer_Id,
	CI.cst_key AS Customer_No,
	CI.cst_firstname AS FirstName,
	CI.cst_lastname AS LastName,
	LOC.CNTRY AS Country,
	CASE 
		WHEN CI.cst_gndr <> CA.GEN THEN CI.cst_gndr
		WHEN CI.cst_gndr IS NULL THEN CA.GEN
		ELSE CI.cst_gndr 
	END AS Gender,
	CI.cst_marital_status AS MaritalStatus,
	CA.BDATE AS Birth_Date,
	CI.cst_create_date AS Create_Date
FROM Silver.crm_cust_info AS CI
LEFT JOIN Silver.erp_CUST_AZ12 AS CA
ON CI.cst_key = CA.CID
LEFT JOIN Silver.erp_LOC_A101 AS LOC
ON CA.CID = LOC.CID

GO
--------------------------------------------------------------
--Gold.Dim_Products

CREATE VIEW Gold.Dim_Products
AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY prd_id) AS Product_Key,
	PRI.prd_id AS Product_Id,
	PRI.prd_key AS Product_No,
	PRI.prd_nm AS Product_Name,
	PRI.prd_cat_Id AS Product_Category_Id,
	PKC.CAT AS Product_Category,
	PKC.SUBCAT AS Product_SubCategory,
	PRI.prd_line AS Product_Line,
	PKC.MAINTENANCE AS Product_Maintenance,
	PRI.prd_cost AS	Product_Cost,
	PRI.prd_start_dt AS Product_Start_Date
FROM Silver.crm_prd_info AS PRI
LEFT JOIN Silver.erp_PX_CAT_G1V2 AS PKC
ON PRI.prd_cat_Id = PKC.ID
WHERE PRI.prd_end_dt IS NULL

GO
--------------------------------------------------------------
--Gold.Fact_Sakes

CREATE VIEW Gold.Fact_Sales
AS 
SELECT 
	SS.sls_ord_num AS Order_No,
	DP.Product_Key,		--Product Key from Dim_Products
	DC.Customer_Key,	--Customer Key from Dim_Customers
	SS.sls_order_dt AS Order_Date,
	SS.sls_ship_dt AS Ship_Date,
	SS.sls_due_dt AS Due_Date,
	SS.sls_sales AS Sales_Amount,
	SS.sls_quantity AS Quantity,
	SS.sls_price AS Price
FROM Silver.crm_sales_details AS SS
LEFT JOIN Gold.dim_Customers AS DC
ON SS.sls_cust_id = Customer_Id
LEFT JOIN Gold.Dim_Products AS DP
ON SS.sls_prd_key = DP.Product_No

--------------------------------------------------------------
