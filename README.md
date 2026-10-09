# Software License Sales Analytics

An end-to-end **data engineering, analytics engineering, and business intelligence** portfolio project built with **Python, PostgreSQL, dbt, SQL, and Power BI**.

The project demonstrates how raw operational data can be ingested, validated, transformed into a dimensional model, tested with dbt, and delivered through interactive Power BI dashboards that answer business questions.

---

## Project Overview

The goal of this project was not only to build dashboards, but to create a complete analytics pipeline:

```text
CSV source files
      ↓
Python ingestion
      ↓
PostgreSQL raw schema
      ↓
dbt staging models
      ↓
dbt data quality tests
      ↓
dbt dimensional marts
      ↓
Power BI semantic model
      ↓
Business dashboards and recommendations
```

This structure separates **raw data ingestion**, **data transformation**, **data quality testing**, **analytics modelling**, and **business reporting**.

---

## Data Engineering & Analytics Engineering Highlights

This project demonstrates practical data engineering and dbt skills, including:

- Loading multiple CSV source files into PostgreSQL with Python
- Separating raw source data from transformed analytics models
- Building reusable dbt staging models
- Standardising data types, text values, IDs, dates, and business fields
- Creating fact and dimension tables for analytics
- Implementing dbt `not_null`, `unique`, `accepted_values`, and `relationships` tests
- Writing custom SQL data tests
- Investigating source-data problems directly in PostgreSQL
- Preserving unresolved source-quality issues instead of inventing values
- Creating explicit data-quality flags inside fact models
- Building a star-schema model for Power BI
- Connecting transformation logic to business reporting requirements

The project therefore covers both **analytics engineering** and **business intelligence**, rather than only dashboard development.

---

## Technology Stack

| Layer | Technology |
|---|---|
| Source data | CSV |
| Ingestion | Python |
| Database | PostgreSQL |
| Transformation | dbt |
| Data validation | dbt tests + PostgreSQL SQL checks |
| Modelling | Dimensional / star schema |
| Analytics | DAX |
| Visualisation | Power BI |
| Version control | Git / GitHub |

---

## Source Data

The raw dataset contains six business entities:

- `customers.csv`
- `products.csv`
- `sales_reps.csv`
- `subscriptions.csv`
- `invoices.csv`
- `opportunities.csv`

The Python ingestion script loads these files into the PostgreSQL `raw` schema.

```text
src/ingest_data.py
```

---

## PostgreSQL Data Quality Investigation

Before and during dbt development, SQL queries were used to investigate source-data issues directly in PostgreSQL.

The investigation included:

- duplicate customer IDs
- non-standard subscription statuses
- missing subscription seat counts
- orphan invoice references
- negative invoice amounts
- invalid sales representative references
- invalid subscription date ranges

The investigation queries are included here:

```text
sql/data_quality_checks.sql
```

This creates a clear audit trail between manual investigation and automated dbt testing.

---

## dbt Transformation Layer

### Staging Models

The staging layer cleans and standardises source data before it reaches the reporting model.

```text
stg_customers
stg_products
stg_sales_reps
stg_subscriptions
stg_invoices
stg_opportunities
```

Examples of staging work include:

- standardising country and status values
- converting columns to appropriate data types
- deduplicating customer records
- cleaning invoice amounts
- validating IDs and relationships
- preparing business-ready fields for downstream models

---

## dbt Data Quality Testing

The project uses both built-in and custom dbt tests.

### Built-in tests

Examples include:

```text
not_null
unique
accepted_values
relationships
```

### Custom tests

```text
test_invoice_amount_non_negative.sql
test_subscription_dates_valid.sql
```

The final dbt build completed with:

```text
PASS=45
WARN=4
ERROR=0
TOTAL=49
```

### Known Data Quality Issues

| Issue | Records | Treatment |
|---|---:|---|
| Duplicate customer IDs | 3 | Deduplicated in staging |
| Negative invoice amounts | 27 | Standardised in staging and re-tested |
| Invalid subscription date ranges | 13 | Preserved and flagged |
| Invalid sales rep references | 11 | Preserved and flagged |
| Missing subscription seats | 7 | Preserved as known source-quality issue |
| Orphan invoice references | 5 | Preserved and flagged |

A key design principle in this project was:

> **Do not silently invent corrections when the source data does not provide enough evidence.**

Issues that could be corrected safely were fixed. Issues that could not be corrected confidently were retained, documented, and surfaced as warnings or flags.

---

## Analytics Marts

The final dbt models form a Power BI-friendly star schema.

### Dimensions

```text
dim_customers
dim_products
dim_sales_reps
dim_date
```

### Facts

```text
fct_subscriptions
fct_invoices
fct_opportunities
```

The fact models also contain useful analytics fields such as:

- `net_revenue`
- `weighted_pipeline_value`
- `is_closed_won`
- `is_closed`
- `is_orphan_invoice`
- `is_orphan_sales_rep`
- `is_valid_date_range`
- `is_seats_missing`

These fields make business rules explicit and reusable across reporting.

---

## Power BI Data Model

Power BI connects to the dbt marts stored in PostgreSQL.

The model uses single-direction, one-to-many relationships from dimensions to facts.

Examples:

```text
dim_customers → fct_invoices
dim_customers → fct_opportunities
dim_customers → fct_subscriptions

dim_products → fct_invoices
dim_products → fct_subscriptions

dim_sales_reps → fct_opportunities

dim_date → invoice_date
dim_date → opportunity_created_date
dim_date → subscription_start_date
```

The date dimension is marked as the model's Date table.

---

# Business Questions Answered

The reporting layer was designed around management questions rather than isolated visuals.

## Revenue & Subscription Questions

- How much net revenue is being generated?
- How does revenue change by month?
- Which products and editions contribute most?
- How many subscriptions are active?
- How large is the installed seat base?
- What is the subscription status mix?
- How do refunds and payment statuses affect revenue?

## Sales & Customer Questions

- How large is the open sales pipeline?
- What is the overall sales win rate?
- Which pipeline stages contain the most opportunity value?
- Which sales representatives combine strong conversion and pipeline?
- Which countries contain the strongest open pipeline?
- Which customer accounts should the sales team prioritise?

---

# Power BI Dashboards

## 1. Revenue & Subscriptions

![Revenue & Subscriptions Dashboard](docs/images/Revenue%20%26%20Subscriptions.png)

The dashboard combines revenue, subscription, product, and payment analysis.

Key KPIs include:

- **Net Revenue:** 72.8M
- **Active Subscriptions:** 872
- **Total Seats:** 135K
- **Average Invoice Value:** 19.66K

The page also analyses:

- monthly revenue performance
- revenue by product and edition
- subscription status mix
- payment-status impact on net revenue
- billing type and year filtering

---

## 2. Sales & Customers

![Sales & Customers Dashboard](docs/images/Sales%20%26%20Customers.png)

The dashboard focuses on pipeline health, sales performance, geography, and account prioritisation.

Key KPIs include:

- **Open Pipeline:** 34.29M
- **Weighted Pipeline:** 31.19M
- **Win Rate:** 65.66%
- **Won Deals:** 564

The page also analyses:

- pipeline by stage
- sales representative performance
- open pipeline by country
- priority customer accounts
- sales team and regional filtering

---

# Example Business Insights

The dashboards support several practical conclusions.

### Revenue

Revenue performance is not evenly distributed across products and months. Management can use the product and monthly views to identify strong product lines and investigate unusual revenue peaks or declines.

### Subscription Health

Active subscriptions represent a major portion of the installed base, while expired, cancelled, and trial subscriptions provide opportunities for renewal, win-back, and conversion activity.

### Pipeline

The sales pipeline is distributed across multiple countries rather than being dependent on a single geography, reducing concentration risk.

### Sales Performance

The sales-rep scatter plot highlights differences between pipeline ownership and conversion performance. Reps with strong pipeline but weaker win rates may need coaching, while strong converters with limited pipeline may benefit from additional lead allocation.

### Customer Prioritisation

The priority-account matrix helps sales teams focus on customers with the largest open opportunity value rather than treating every account equally.

### Data Quality

The project also shows that business reporting quality depends on upstream data quality. Invalid relationships, missing seat values, and inconsistent dates should ultimately be corrected at source-system level.

---

# Example Management Recommendations

- Investigate the business drivers behind the strongest and weakest revenue months.
- Protect high-performing products while monitoring product concentration risk.
- Create renewal and win-back campaigns for expired and cancelled subscriptions.
- Improve conversion of trial subscriptions into paid customers.
- Coach sales reps with high pipeline but lower conversion rates.
- Allocate more qualified opportunities to strong converters with limited open pipeline.
- Prioritise high-value customer accounts for sales follow-up.
- Resolve recurring data-quality issues at source rather than relying only on downstream fixes.

---

# Repository Structure

```text
software-license-sales-analytics/
│
├── data/
│   └── raw/
│       ├── customers.csv
│       ├── invoices.csv
│       ├── opportunities.csv
│       ├── products.csv
│       ├── sales_reps.csv
│       └── subscriptions.csv
│
├── src/
│   └── ingest_data.py
│
├── sql/
│   └── data_quality_checks.sql
│
├── license_sales_dbt/
│   ├── models/
│   │   ├── staging/
│   │   └── marts/
│   ├── tests/
│   └── dbt_project.yml
│
├── powerbi/
│   └── software_license_sales_dashboard.pbix
│
├── docs/
│   └── images/
│       ├── Revenue & Subscriptions.png
│       └── Sales & Customers.png
│
├── presentation/
│   └── software_license_sales_project_presentation.pptx
│
├── README.md
└── .gitignore
```

---

# How to Run the Project

## 1. Prepare PostgreSQL

Create the project database and keep local credentials in a `.env` file.

The `.env` file is excluded from Git and should never be committed.

## 2. Load Raw Data

From the project root:

```bash
python src/ingest_data.py
```

## 3. Run dbt

```bash
cd license_sales_dbt
dbt debug
dbt build
```

A successful build should create the staging and mart models and execute the configured data tests.

## 4. Open Power BI

Open:

```text
powerbi/software_license_sales_dashboard.pbix
```

Refresh the PostgreSQL connection if required.

---

# Skills Demonstrated

### Data Engineering
- Python data ingestion
- PostgreSQL database loading
- raw-data layer design
- SQL data-quality investigation
- source-to-target pipeline development

### Analytics Engineering
- dbt project structure
- staging models
- dimensional marts
- fact and dimension modelling
- dbt tests
- custom SQL tests
- relationship validation
- data-quality warning strategy
- business-rule modelling
- star-schema design

### Business Intelligence
- Power BI semantic modelling
- DAX measures
- interactive filtering
- KPI design
- dashboard development
- business-question-driven analysis
- insight generation
- management recommendations

---

# Project Presentation

A PowerPoint walkthrough of the complete project is included here:

```text
presentation/software_license_sales_project_presentation.pptx
```

The presentation covers:

- project architecture
- Python and PostgreSQL ingestion
- dbt staging and marts
- dbt testing
- dimensional modelling
- Power BI dashboards
- business insights
- recommendations

---

## Final Outcome

This project demonstrates a complete analytics workflow from **raw source data to business decision support**:

```text
Raw Data
   ↓
Python Ingestion
   ↓
PostgreSQL
   ↓
dbt Transformation
   ↓
dbt Testing
   ↓
Dimensional Data Model
   ↓
Power BI
   ↓
Business Insights & Recommendations
```

It is intended to demonstrate not only dashboard-building ability, but also **data engineering, analytics engineering, SQL, dbt, data modelling, data quality management, and business analysis skills**.
