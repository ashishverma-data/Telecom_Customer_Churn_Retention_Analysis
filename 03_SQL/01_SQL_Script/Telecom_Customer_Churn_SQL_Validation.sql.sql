-- ============================================================
-- TELECOM CUSTOMER CHURN ANALYSIS 
-- ============================================================
-- Platform: MySQL 8.0+
-- Primary table: telco_customer_churn
--
-- BUSINESS OBJECTIVE
-- ------------------------------------------------------------
-- Identify the customer segments, services, commercial factors,
-- and risk signals associated with churn so the business can:
--   1. Quantify customer churn and recurring-revenue exposure.
--   2. Identify high-risk and high-value customers.
--   3. Understand churn by lifecycle, demographics, geography,
--      services, contracts, payment methods, and charges.
--   4. Prioritize retention and customer-value actions.
--   5. Provide reusable SQL outputs for dashboards and reporting.

-- Note:
--   Single-table analysis. No JOINs are required.
-- ============================================================

-- ============================================================
-- 01. DATABASE & TABLE SETUP
-- QUERY PURPOSE: Establish the database and analytical customer table.
-- ============================================================
CREATE DATABASE telco_customer_churn_db;
USE telco_customer_churn_db;
CREATE TABLE telco_customer_churn(
Customer_ID VARCHAR(30) PRIMARY KEY,
Country VARCHAR(50),
State VARCHAR(50),
City VARCHAR(70),
Zip_Code INT,
Latitude DECIMAL(10,6),
Longitude DECIMAL(10,6),
Gender  VARCHAR(20),
Senior_Citizen  VARCHAR(10),
Partner VARCHAR(10),
Dependents VARCHAR(10),
Tenure_Months INT,
Tenure_Group  VARCHAR(30),
Phone_Service  VARCHAR(30),
Multiple_Lines VARCHAR(30),
Internet_Service  VARCHAR(30),
Online_Security  VARCHAR(30),
Online_Backup  VARCHAR(30),
Device_Protection  VARCHAR(30),
Tech_Support VARCHAR(30),
Streaming_TV  VARCHAR(30),
Streaming_Movies  VARCHAR(30),
Service_Count INT,
Service_Category  VARCHAR(30),
Contract  VARCHAR(30),
Paperless_Billing  VARCHAR(30),
Payment_Method  VARCHAR(30),
Monthly_Charges  DECIMAL(10,2),
Monthly_Charges_Group  VARCHAR(30),
Total_Charges DECIMAL(10,2),
CLTV INT,
CLTV_Group  VARCHAR(30),
Churn_Score INT,
Churn_Risk  VARCHAR(30),
Churn_Label  VARCHAR(30),
Churn_Reason  VARCHAR(230)
);

-- ============================================================
-- 02. DATA IMPORT & MYSQL CONFIGURATION
-- QUERY PURPOSE: Configure local file loading and import the cleaned source data.
-- ============================================================
SET GLOBAL local_infile = 1;
SHOW GLOBAL VARIABLES LIKE 'local_infile';
LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/telco_customer_churn_cleaned.csv.csv'
INTO TABLE telco_customer_churn
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- ============================================================
-- 03. DATA STRUCTURE & QUALITY VALIDATION
-- QUERY PURPOSE: Validate schema, row volume, uniqueness, and critical-field completeness.
-- ============================================================
SHOW CREATE TABLE telco_customer_churn;
SELECT * 
FROM telco_customer_churn 
LIMIT 10;
SELECT COUNT(*) AS Total_Customers 
FROM telco_customer_churn;

-- 03.04 Check duplicate customer IDs
SELECT Customer_ID,
    COUNT(*) AS Duplicate_Count
FROM telco_customer_churn
GROUP BY Customer_ID
HAVING COUNT(*) > 1;

-- 03.05 Check missing critical analytical fields
SELECT
    SUM(Customer_ID IS NULL) AS Missing_Customer_ID,
    SUM(Churn_Label IS NULL) AS Missing_Churn_Label
FROM telco_customer_churn;

-- ============================================================
-- 04. OVERALL CUSTOMER & CHURN KPI ANALYSIS
-- QUERY PURPOSE: Quantify the core customer, churn, revenue-loss, and risk KPIs.
-- ============================================================
-- 04.01 Overall customer churn and revenue KPIs
SELECT 
	COUNT(*) AS Total_Customer,
    SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END) AS Retained_Customer,
    SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END) AS Churned_Customer,
	ROUND(SUM(Monthly_Charges),0)AS Monthly_Revenue,
    ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN Monthly_Charges ELSE 0 END),0) AS Revenue_Lost,
    ROUND(AVG(CLTV),0)AS Average_CLTV,
    ROUND(SUM(CASE WHEN Churn_Risk='High Risk' THEN 1 ELSE 0 END),0) AS High_Risk_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Retained_Rate,
    ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Churned_Rate,
    ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN Monthly_Charges ELSE 0 END)*100/
          SUM(Monthly_Charges),2) AS Monthly_Revenue_Lost_Rate          
FROM telco_customer_churn;

-- 04.02 Overall churn distribution
SELECT
    Churn_Label,
    COUNT(*) AS Total_Customers,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS Customer_Distribution_Rate
FROM telco_customer_churn
GROUP BY Churn_Label;

-- ============================================================
-- 05. TENURE & CUSTOMER LIFECYCLE ANALYSIS
-- QUERY PURPOSE: Measure churn and value across customer lifecycle stages.
-- ============================================================
-- 05.01 Customer churn by tenure group
SELECT Tenure_Group,
	COUNT(*) AS Total_Customer,
    SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END) AS Retained_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Retained_Rate,
    SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END) AS Churned_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Churned_Rate,
	ROUND(SUM(CASE WHEN Churn_Label='No' THEN Monthly_Charges ELSE 0 END),0) AS Retained_Revenue,
	ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN Monthly_Charges ELSE 0 END),0) AS Churned_Revenue,
	ROUND(AVG(CLTV),0)AS Average_CLTV
FROM telco_customer_churn
GROUP BY Tenure_Group
ORDER BY MIN(Tenure_Months);

-- ============================================================
-- 06. CUSTOMER DEMOGRAPHIC ANALYSIS
-- QUERY PURPOSE: Compare churn, retention, revenue, and value across demographic segments.
-- ============================================================
-- 06.01 Overall CUSTOMER DEMOGRAPHIC 
SELECT 
   'Gender' AS Category,
    Gender AS Response,
	COUNT(*) AS Total_Customer,
    SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END) AS Retained_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Retained_Rate,
    SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END) AS Churned_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Churned_Rate,
	ROUND(SUM(CASE WHEN Churn_Label='No' THEN Monthly_Charges ELSE 0 END),0) AS Retained_Revenue,
	ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN Monthly_Charges ELSE 0 END),0) AS Churned_Revenue,
	ROUND(AVG(CLTV),0)AS Average_CLTV
FROM telco_customer_churn
GROUP BY Gender
UNION ALL
SELECT 
   'Senior_Citizen' AS Category,
    Senior_Citizen AS Response,
	COUNT(*) AS Total_Customer,
    SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END) AS Retained_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Retained_Rate,
    SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END) AS Churned_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Churned_Rate,
	ROUND(SUM(CASE WHEN Churn_Label='No' THEN Monthly_Charges ELSE 0 END),0) AS Retained_Revenue,
	ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN Monthly_Charges ELSE 0 END),0) AS Churned_Revenue,
	ROUND(AVG(CLTV),0)AS Average_CLTV
FROM telco_customer_churn
GROUP BY Senior_Citizen
UNION ALL
SELECT 
   'Partner' AS Category,
    Partner AS Response,
	COUNT(*) AS Total_Customer,
    SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END) AS Retained_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Retained_Rate,
    SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END) AS Churned_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Churned_Rate,
	ROUND(SUM(CASE WHEN Churn_Label='No' THEN Monthly_Charges ELSE 0 END),0) AS Retained_Revenue,
	ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN Monthly_Charges ELSE 0 END),0) AS Churned_Revenue,
	ROUND(AVG(CLTV),0)AS Average_CLTV
FROM telco_customer_churn
GROUP BY Partner
UNION ALL
SELECT  
   'Dependents' AS Category,
    Dependents AS Response,
	COUNT(*) AS Total_Customer,
    SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END) AS Retained_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Retained_Rate,
    SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END) AS Churned_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Churned_Rate,
	ROUND(SUM(CASE WHEN Churn_Label='No' THEN Monthly_Charges ELSE 0 END),0) AS Retained_Revenue,
	ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN Monthly_Charges ELSE 0 END),0) AS Churned_Revenue,
	ROUND(AVG(CLTV),0)AS Average_CLTV
FROM telco_customer_churn
GROUP BY Dependents;

-- ============================================================
-- 07. GEOGRAPHIC CUSTOMER ANALYSIS
-- QUERY PURPOSE: Identify geographic variation in churn, service adoption, revenue, and value.
-- ============================================================
-- 07.01 Customer churn and service adoption by city
SELECT City,
	COUNT(*) AS Total_Customer,
    SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END) AS Retained_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Retained_Rate,
    SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END) AS Churned_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Churned_Rate,
	ROUND(AVG(Service_Count),0) AS Avg_of_Service_Adopt,
	ROUND(SUM(CASE WHEN Churn_Label='No' THEN Monthly_Charges ELSE 0 END),0) AS Retained_Revenue,
	ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN Monthly_Charges ELSE 0 END),0) AS Churned_Revenue,
	ROUND(AVG(CLTV),0)AS Average_CLTV
FROM telco_customer_churn
GROUP BY City;


-- ============================================================
-- 08. SERVICE ADOPTION & PRODUCT ANALYSIS
-- QUERY PURPOSE: Evaluate service adoption patterns and their relationship with churn.
-- ============================================================
-- 08.01 Service-level churn analysis
SELECT Service_Category,
	COUNT(*) AS Total_Customer,
    ROUND(COUNT(*)*100/(SELECT COUNT(*) 
                        FROM telco_customer_churn),2) 
				AS Customer_Distribution_Rate,
    SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END) AS Retained_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Retained_Rate,
    SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END) AS Churned_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Churned_Rate
FROM telco_customer_churn
GROUP BY Service_Category;

-- 08.02 Service adoption analysis
SELECT 
   'Online_Security' AS Category,
    Online_Security AS Response,
	COUNT(*) AS Total_Customer,
    ROUND(COUNT(*)*100/7043 ,1) Total_Cust_Rate,
    SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END) AS Retained_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Retained_Rate,
    SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END) AS Churned_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Churned_Rate,
	ROUND(SUM(CASE WHEN Churn_Label='No' THEN Monthly_Charges ELSE 0 END),0) AS Retained_Revenue,
	ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN Monthly_Charges ELSE 0 END),0) AS Churned_Revenue,
	ROUND(AVG(CLTV),0)AS Average_CLTV
FROM telco_customer_churn
GROUP BY Online_Security
UNION ALL
SELECT 
   'Online_Backup' AS Category,
    Online_Backup AS Response,
	COUNT(*) AS Total_Customer,
    ROUND(COUNT(*)*100/7043 ,1) Total_Cust_Rate,
    SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END) AS Retained_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Retained_Rate,
    SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END) AS Churned_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Churned_Rate,
	ROUND(SUM(CASE WHEN Churn_Label='No' THEN Monthly_Charges ELSE 0 END),0) AS Retained_Revenue,
	ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN Monthly_Charges ELSE 0 END),0) AS Churned_Revenue,
	ROUND(AVG(CLTV),0)AS Average_CLTV
FROM telco_customer_churn
GROUP BY Online_Backup
UNION ALL
SELECT 
   'Device_Protection' AS Category,
    Device_Protection AS Response,
	COUNT(*) AS Total_Customer,
    ROUND(COUNT(*)*100/7043 ,1) Total_Cust_Rate,
    SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END) AS Retained_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Retained_Rate,
    SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END) AS Churned_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Churned_Rate,
	ROUND(SUM(CASE WHEN Churn_Label='No' THEN Monthly_Charges ELSE 0 END),0) AS Retained_Revenue,
	ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN Monthly_Charges ELSE 0 END),0) AS Churned_Revenue,
	ROUND(AVG(CLTV),0)AS Average_CLTV
FROM telco_customer_churn
GROUP BY Device_Protection
UNION ALL
SELECT 
   'Tech_Support' AS Category,
    Tech_Support AS Response,
	COUNT(*) AS Total_Customer,
    ROUND(COUNT(*)*100/7043 ,1) Total_Cust_Rate,
    SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END) AS Retained_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Retained_Rate,
    SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END) AS Churned_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Churned_Rate,
	ROUND(SUM(CASE WHEN Churn_Label='No' THEN Monthly_Charges ELSE 0 END),0) AS Retained_Revenue,
	ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN Monthly_Charges ELSE 0 END),0) AS Churned_Revenue,
	ROUND(AVG(CLTV),0)AS Average_CLTV
FROM telco_customer_churn
GROUP BY Tech_Support
UNION ALL
SELECT 
   'Streaming_TV' AS Category,
    Streaming_TV AS Response,
	COUNT(*) AS Total_Customer,
    ROUND(COUNT(*)*100/7043 ,1) Total_Cust_Rate,
    SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END) AS Retained_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Retained_Rate,
    SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END) AS Churned_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Churned_Rate,
	ROUND(SUM(CASE WHEN Churn_Label='No' THEN Monthly_Charges ELSE 0 END),0) AS Retained_Revenue,
	ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN Monthly_Charges ELSE 0 END),0) AS Churned_Revenue,
	ROUND(AVG(CLTV),0)AS Average_CLTV
FROM telco_customer_churn
GROUP BY Streaming_TV
UNION ALL
SELECT 
   'Streaming_Movies' AS Category,
    Streaming_Movies AS Response,
	COUNT(*) AS Total_Customer,
    ROUND(COUNT(*)*100/7043 ,1) Total_Cust_Rate,
    SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END) AS Retained_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Retained_Rate,
    SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END) AS Churned_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Churned_Rate,
	ROUND(SUM(CASE WHEN Churn_Label='No' THEN Monthly_Charges ELSE 0 END),0) AS Retained_Revenue,
	ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN Monthly_Charges ELSE 0 END),0) AS Churned_Revenue,
	ROUND(AVG(CLTV),0)AS Average_CLTV
FROM telco_customer_churn
GROUP BY Streaming_Movies
UNION ALL
SELECT 
   'Internet_Service' AS Category,
    Internet_Service AS Response,
	COUNT(*) AS Total_Customer,
    ROUND(COUNT(*)*100/7043 ,1) Total_Cust_Rate,
    SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END) AS Retained_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Retained_Rate,
    SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END) AS Churned_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Churned_Rate,
	ROUND(SUM(CASE WHEN Churn_Label='No' THEN Monthly_Charges ELSE 0 END),0) AS Retained_Revenue,
	ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN Monthly_Charges ELSE 0 END),0) AS Churned_Revenue,
	ROUND(AVG(CLTV),0)AS Average_CLTV
FROM telco_customer_churn
GROUP BY Internet_Service
UNION ALL
SELECT 
   'Multiple_Lines' AS Category,
    Multiple_Lines AS Response,
	COUNT(*) AS Total_Customer,
    ROUND(COUNT(*)*100/7043 ,1) Total_Cust_Rate,
    SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END) AS Retained_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Retained_Rate,
    SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END) AS Churned_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Churned_Rate,
	ROUND(SUM(CASE WHEN Churn_Label='No' THEN Monthly_Charges ELSE 0 END),0) AS Retained_Revenue,
	ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN Monthly_Charges ELSE 0 END),0) AS Churned_Revenue,
	ROUND(AVG(CLTV),0)AS Average_CLTV
FROM telco_customer_churn
GROUP BY Multiple_Lines
UNION ALL
SELECT 
   'Phone_Service' AS Category,
    Phone_Service AS Response,
	COUNT(*) AS Total_Customer,
    ROUND(COUNT(*)*100/7043 ,1) Total_Cust_Rate,
    SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END) AS Retained_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Retained_Rate,
    SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END) AS Churned_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Churned_Rate,
	ROUND(SUM(CASE WHEN Churn_Label='No' THEN Monthly_Charges ELSE 0 END),0) AS Retained_Revenue,
	ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN Monthly_Charges ELSE 0 END),0) AS Churned_Revenue,
	ROUND(AVG(CLTV),0)AS Average_CLTV
FROM telco_customer_churn
GROUP BY Phone_Service;



-- ============================================================
-- 09. CONTRACT & PAYMENT ANALYSIS
-- QUERY PURPOSE: Assess commercial structure and payment behavior as churn indicators.
-- ============================================================
-- 09.01 Contract type and churn performance
SELECT Contract,
    COUNT(*) AS Total_Customers,
    ROUND(COUNT(*)*100/(SELECT COUNT(*) 
                        FROM telco_customer_churn),2) 
				AS Customer_Distribution_Rate,
    SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END) AS Retained_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Retained_Rate,
    SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END) AS Churned_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Churned_Rate
FROM telco_customer_churn
GROUP BY Contract;

-- 09.02 Payment method and churn performance
SELECT Payment_Method,
    COUNT(*) AS Total_Customers,
    ROUND(COUNT(*)*100/7043 ,1) Total_Cust_Rate,
    SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END) AS Retained_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='No' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Retained_Rate,
    SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END) AS Churned_Customer,
    ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Churned_Rate
FROM telco_customer_churn
GROUP BY Payment_Method;


-- ============================================================
-- 10. CHURN REASON & CHURN RISK ANALYSIS
-- QUERY PURPOSE: Identify stated churn reasons, risk distribution, and priority customers.
-- ============================================================
-- 10.01 Churn reason distribution
SELECT Churn_Reason,
      SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END) AS Churned_Customer,
	  ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END)*100/
          7043,2) AS Churned_Distribution_Rate
FROM telco_customer_churn
GROUP BY Churn_Reason
ORDER BY Churned_Customer DESC;


-- 10.02 Churn risk distribution
SELECT Churn_Risk,
COUNT(*) AS Total_Customers,
ROUND(COUNT(*)*100/(SELECT COUNT(*) 
                        FROM telco_customer_churn),2) 
				AS Customer_Distribution_Rate,
SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END) AS Churned_Customer,
ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Churned_Rate
FROM telco_customer_churn
GROUP BY Churn_Risk
ORDER BY Total_Customers DESC;

-- 10.03 High-risk customers with above-average monthly charges
SELECT Customer_ID, Monthly_Charges, Churn_Risk, Churn_Label
FROM telco_customer_churn
WHERE Churn_Risk = 'High Risk'
  AND Monthly_Charges >
      (SELECT AVG(Monthly_Charges)
          FROM telco_customer_churn)
ORDER BY Monthly_Charges DESC;

-- ============================================================
-- 11. CUSTOMER VALUE ANALYSIS
-- QUERY PURPOSE: Separate above-average CLTV customers and compare their churn status.
-- ============================================================
-- 11.01 Customers with above-average CLTV
WITH 
High_Value AS
          (SELECT Customer_ID,CLTV,Churn_Label
          FROM telco_customer_churn
          WHERE CLTV > 
          (SELECT AVG(CLTV)
          FROM telco_customer_churn))
SELECT *
FROM High_Value;

-- 11.02 High-value customers by churn status
SELECT Churn_Label,
    COUNT(*) AS High_Value_Customers,
    ROUND(AVG(CLTV), 0) AS Average_CLTV
FROM telco_cus
tomer_churn
WHERE CLTV >
      (SELECT AVG(CLTV)
          FROM telco_customer_churn)
GROUP BY Churn_Label;

-- ============================================================
-- 12. CUSTOMER CHARGES & VALUE SEGMENTATION
-- QUERY PURPOSE: Segment customers by charges and CLTV while monitoring churn exposure.
-- ============================================================
-- 12.01 Monthly charges group distribution
SELECT Monthly_Charges_Group,
COUNT(*) AS Total_Customers,
ROUND(COUNT(*)*100/(SELECT COUNT(*) 
                        FROM telco_customer_churn),2) 
				AS Customer_Distribution_Rate
FROM telco_customer_churn
GROUP BY Monthly_Charges_Group
ORDER BY Total_Customers DESC;

-- 12.02 CLTV group distribution
SELECT CLTV_Group,
COUNT(*) AS Total_Customer,
ROUND(COUNT(*)*100/(SELECT COUNT(*) 
                        FROM telco_customer_churn),2) 
				AS Customer_Distribution_Rate,
SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END) AS Churned_Customer,
ROUND(SUM(CASE WHEN Churn_Label='Yes' THEN 1 ELSE 0 END)*100/
          COUNT(*),2) AS Churned_Rate
FROM telco_customer_churn
GROUP BY CLTV_Group
ORDER BY Churned_Rate DESC;

-- ============================================================
-- 13. ADVANCED CUSTOMER ANALYSIS
-- QUERY PURPOSE: Rank high-value monthly-charge customers within contract groups.
-- ============================================================
-- 13.01 Rank top customers by monthly charges within contract
WITH 
Contract_Group_Rank AS 
(SELECT Customer_ID,Contract,Monthly_Charges,
    RANK() OVER (
        PARTITION BY Contract
        ORDER BY Monthly_Charges DESC) AS Contract_Rank
FROM telco_customer_churn)
SELECT	Contract,Customer_ID,
      SUM(Monthly_Charges) AS Monthly_Charges,
      Contract_Rank
FROM Contract_Group_Rank
WHERE Contract_Rank<=3
GROUP BY Contract,Customer_ID;

-- ============================================================
-- 14. REUSABLE BUSINESS VIEW
-- QUERY PURPOSE: Publish a reusable view of churned customers for downstream reporting.
-- ============================================================
-- 14.01 Create reusable view for churned customers
CREATE OR REPLACE VIEW vw_churned_customers AS
SELECT *
FROM telco_customer_churn
WHERE Churn_Label = 'Yes';

-- 14.02 Review churned customer view
SELECT *
FROM vw_churned_customers;

-- ============================================================
-- END OF TELECOM CUSTOMER CHURN ANALYSIS
-- ============================================================