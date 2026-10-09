# Software License Sales Analytics

End-to-end **data engineering, analytics engineering, and business intelligence** portfolio project using **Python, PostgreSQL, dbt, SQL, and Power BI**.

The project takes raw software-license sales data through ingestion, transformation, testing, dimensional modelling, and dashboard reporting.

## Architecture

```text
CSV files
   ↓
Python ingestion
   ↓
PostgreSQL raw schema
   ↓
dbt staging models
   ↓
dbt tests
   ↓
dbt dimensional marts
   ↓
Power BI
   ↓
Business insights
```

## Tech Stack

- **Python** — data ingestion
- **PostgreSQL** — raw data storage and SQL validation
- **dbt** — transformations, tests, lineage, marts
- **SQL** — data-quality investigation and modelling
- **Power BI / DAX** — semantic model, KPIs, dashboards
- **Git / GitHub** — version control and portfolio delivery

## Data Engineering & dbt Highlights

This project demonstrates:

- loading six CSV source files into PostgreSQL with Python
- separating raw, staging, and analytics layers
- building reusable dbt staging models
- creating fact and dimension tables
- using `not_null`, `unique`, `accepted_values`, and `relationships` tests
- writing custom SQL tests
- investigating source-data issues directly in PostgreSQL
- preserving unresolved data-quality problems as warnings instead of inventing values
- building a star schema for Power BI

### dbt Models

**Staging**
- `stg_customers`
- `stg_products`
- `stg_sales_reps`
- `stg_subscriptions`
- `stg_invoices`
- `stg_opportunities`

**Dimensions**
- `dim_customers`
- `dim_products`
- `dim_sales_reps`
- `dim_date`

**Facts**
- `fct_subscriptions`
- `fct_invoices`
- `fct_opportunities`

## Data Quality & Testing

Final dbt build:

```text
PASS=45
WARN=4
ERROR=0
TOTAL=49
```

| Issue | Records | Treatment |
|---|---:|---|
| Duplicate customer IDs | 3 | Deduplicated in staging |
| Negative invoice amounts | 27 | Standardised and re-tested |
| Invalid subscription dates | 13 | Preserved and flagged |
| Invalid sales rep references | 11 | Preserved as warning |
| Missing subscription seats | 7 | Preserved as warning |
| Orphan invoice references | 5 | Preserved as warning |

Custom tests:

```text
test_invoice_amount_non_negative.sql
test_subscription_dates_valid.sql
```

PostgreSQL investigation queries are available in:

```text
sql/data_quality_checks.sql
```

## Power BI Dashboards

### Revenue & Subscriptions

![Revenue & Subscriptions Dashboard](docs/images/Revenue%20%26%20Subscriptions.png)

Key KPIs:

- **Net Revenue:** 72.8M
- **Active Subscriptions:** 872
- **Total Seats:** 135K
- **Average Invoice Value:** 19.66K

Answers questions around revenue trends, product performance, subscription health, billing type, and payment status.

### Sales & Customers

![Sales & Customers Dashboard](docs/images/Sales%20%26%20Customers.png)

Key KPIs:

- **Open Pipeline:** 34.29M
- **Weighted Pipeline:** 31.19M
- **Win Rate:** 65.66%
- **Won Deals:** 564

Answers questions around pipeline health, sales-rep performance, geography, and priority customer accounts.

## Business Insights

- Revenue varies meaningfully by month and product, helping identify strong product lines and periods that need investigation.
- Expired, cancelled, and trial subscriptions provide renewal, win-back, and conversion opportunities.
- The open pipeline is distributed across several countries rather than being concentrated in one market.
- Sales reps with high pipeline but lower win rates may need coaching.
- Strong converters with limited pipeline may benefit from more qualified leads.
- High-value customer accounts can be prioritised using open pipeline value.
- Several reporting issues originate upstream, showing why source-data quality matters.

## Repository Structure

```text
software-license-sales-analytics/
├── data/raw/
├── src/
│   └── ingest_data.py
├── sql/
│   └── data_quality_checks.sql
├── license_sales_dbt/
│   ├── models/
│   │   ├── staging/
│   │   └── marts/
│   ├── tests/
│   └── dbt_project.yml
├── powerbi/
│   └── software_license_sales_dashboard.pbix
├── docs/images/
├── presentation/
│   └── software_license_sales_project_presentation.pptx
├── README.md
└── .gitignore
```

## How to Run

```bash
python src/ingest_data.py

cd license_sales_dbt
dbt debug
dbt build
```

Then open:

```text
powerbi/software_license_sales_dashboard.pbix
```

## Skills Demonstrated

**Data Engineering:** Python ingestion, PostgreSQL, raw-layer design, SQL validation

**Analytics Engineering:** dbt staging, marts, testing, lineage, dimensional modelling, data-quality handling

**Business Intelligence:** Power BI, DAX, KPI design, dashboarding, business analysis, recommendations

## Presentation

A project walkthrough is included here:

```text
presentation/software_license_sales_project_presentation.pptx
```
