# Telecom Customer Churn & Retention Analysis 📊

## Project Overview

This project analyzes telecom customer churn and retention patterns using an end-to-end data analytics workflow.

**Workflow:**

Excel → Power Query → Power BI → MySQL

The objective is to identify churn drivers, analyze customer behavior, measure revenue impact, and generate actionable retention insights.

Dataset analyzed: **7,043 customer records**

---

## Tools Used

- Microsoft Excel
- Power Query
- Power BI
- MySQL
- SQL
---

## Project Workflow

### Data Preparation (Excel + Power Query)

Performed:

- Data cleaning
- Data type correction
- Null value handling
- Duplicate removal
- Feature engineering

Created analytical fields:

- Tenure Group
- Monthly Charges Group
- CLTV Group
- Churn Risk
- Service Count
- Service Category

Final cleaned dataset:

- Rows: 7,043
- Columns: 37

---

## Power BI Dashboard

Built a structured analytical data model using fact and dimension tables.

The dashboard contains two analytical pages:

### Overview Dashboard

Includes:

- Total customers
- Retained customers
- Churned customers
- Revenue analysis
- Customer demographics
- Service analysis
- Geographic analysis


### Retention Analysis Dashboard

Includes:

- Customer lifecycle analysis
- Tenure-based retention
- Contract analysis
- Payment method analysis
- Service and customer value analysis

---

## Key KPIs

| KPI | Value |
|---|---:|
| Total Customers | 7,043 |
| Retained Customers | 5,174 |
| Churned Customers | 1,869 |
| Retention Rate | 73.5% |
| Churn Rate | 26.5% |
| Monthly Charges | $456.1K |
| Revenue Lost | $139.1K |
| Average CLTV | $4.4K |
| High Risk Customers | 2,983 |

---

## Key Insights

- New customers have the highest churn rate (**52.9%**).
- Veteran customers have the lowest churn rate (**6.6%**).
- Month-to-month contracts have the highest churn rate (**42.7%**).
- Electronic check customers have the highest churn rate (**45.3%**).
- Fiber optic customers show higher churn exposure (**41.9%**).
- High Risk customers have a churn rate of **59.2%**.

---

## SQL Validation

MySQL was used as an independent validation and analysis layer.

Performed:

- Data quality checks
- KPI validation
- Customer segmentation
- Lifecycle analysis
- Contract analysis
- Payment analysis
- Service analysis
- Risk analysis
- Customer value analysis

SQL concepts used:

- Aggregations
- CASE statements
- CTEs
- Window functions(`ROW_NUMBER()`)
- Subqueries
- Views

---

## Project Structure

```
Telecom-Customer-Churn-Analysis/

├── 01_Raw_Data
│   └── Original telecom customer dataset

├── 02_Cleaned_Data
│   └── Cleaned dataset after Power Query transformations

├── 03_SQL
│   └── MySQL validation and analytical queries

├── 04_Power_BI
│   └── Power BI dashboard (.pbix) file

├── 05_Screenshots
│   └── Dashboard and Power Query evidence screenshots

├── 06_Project_Report
│   └── Detailed project documentation

└── README.md
```

---

## Skills Demonstrated

✔ Data Cleaning  
✔ Power Query Transformation  
✔ Feature Engineering  
✔ Data Modeling  
✔ DAX Measures  
✔ Power BI Dashboard Development  
✔ SQL Analytics  
✔ KPI Validation  
✔ Business Intelligence Reporting  

---

## Conclusion

This project delivers a complete customer analytics solution by combining data preparation, business intelligence dashboards, SQL validation, and actionable retention insights.

---

## Project Information

**Project Title:** Telecom Customer Churn & Retention Analysis  
**Prepared By:** Ashish Verma  
**Role:** Data Analyst | MIS Analyst | Reporting Analyst  
**Tools Used:** Excel | Power Query | Power BI | MySQL  
**Project Type:** End-to-End Data Analytics & Business Intelligence Project
