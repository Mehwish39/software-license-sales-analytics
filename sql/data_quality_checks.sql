-- ============================================================
-- SOFTWARE LICENSE SALES ANALYTICS
-- PostgreSQL Data Quality Checks
-- ============================================================
--
-- Purpose:
-- These queries were used to investigate and validate data-quality
-- issues found during the PostgreSQL and dbt workflow.
--
-- The checks cover:
--   1. Duplicate customer IDs
--   2. Subscription status quality
--   3. Missing subscription seats
--   4. Orphan invoice/subscription relationships
--   5. Negative invoice amounts
--   6. Invalid sales representative references
--   7. Invalid subscription date ranges
--
-- These queries are for investigation and validation only.
-- They do not modify the source data.
-- ============================================================


-- ============================================================
-- 1. CUSTOMER DUPLICATE CHECK
-- Requirement:
-- Customer IDs should uniquely identify one customer.
--
-- This query identifies customer IDs appearing more than once
-- in the staging customer table.
-- ============================================================
select
    customer_id,
    count(*) as row_count
from analytics.stg_customers
group by customer_id
having count(*) > 1;


-- Inspect specific customer records identified during duplicate analysis.
-- This was used to compare duplicate rows before the staging model
-- deduplication logic was applied.
select *
from analytics.stg_customers
where customer_id in ('C0050', 'C0200', 'C0350')
order by customer_id;


-- ============================================================
-- 2. SUBSCRIPTION STATUS QUALITY CHECK
-- Requirement:
-- Subscription status values should be standardized and valid.
--
-- Review the distribution of subscription statuses in staging.
-- ============================================================
select
    status,
    count(*) as row_count
from analytics.stg_subscriptions
group by status
order by status;


-- Inspect subscriptions classified as 'Unknown'.
-- This helps identify records where the original source status
-- could not be mapped confidently to a standard business status.
select *
from analytics.stg_subscriptions
where status = 'Unknown';


-- Compare the affected subscriptions with the raw source data.
-- This confirms whether the issue originated in the source data
-- rather than being introduced during transformation.
select
    subscription_id,
    status
from raw.subscriptions
where subscription_id in (
    'S00022',
    'S00268',
    'S00374',
    'S00630',
    'S00833',
    'S00835',
    'S01012',
    'S01429'
);


-- ============================================================
-- 3. MISSING SUBSCRIPTION SEATS CHECK
-- Requirement:
-- Subscription seat counts are required for analysing customer
-- subscription size and software usage.
--
-- Find subscriptions where the number of seats is missing.
-- ============================================================
select *
from analytics.stg_subscriptions
where seats is null;


-- Check the same subscription IDs directly in the raw table.
-- This verifies that the missing values existed in the source data
-- and were not introduced by dbt transformations.
select
    subscription_id,
    seats
from raw.subscriptions
where subscription_id in (
    'S00114',
    'S00329',
    'S00424',
    'S00663',
    'S00761',
    'S00859',
    'S00949'
);


-- ============================================================
-- 4. ORPHAN INVOICE / SUBSCRIPTION CHECK
-- Requirement:
-- Every invoice should reference a valid subscription.
--
-- A LEFT JOIN is used to find invoices whose subscription_id
-- does not exist in the subscription staging table.
-- These records are treated as orphan invoices.
-- ============================================================
select
    i.invoice_id,
    i.subscription_id
from analytics.stg_invoices i
left join analytics.stg_subscriptions s
    on i.subscription_id = s.subscription_id
where s.subscription_id is null;


-- Inspect the identified invoice records in the raw source data.
-- This verifies that the invalid subscription references came from
-- the original invoice dataset.
select
    invoice_id,
    subscription_id
from raw.invoices
where invoice_id in (
    'I004501',
    'I004502',
    'I004503',
    'I004504',
    'I004505'
);


-- ============================================================
-- 5. NEGATIVE INVOICE AMOUNT CHECK
-- Requirement:
-- Invoice amounts should not contain unexpected negative values.
--
-- This query was used during investigation to identify negative
-- invoice amounts before the staging transformation was corrected.
-- The dbt staging model was later updated to standardize amounts
-- using ABS(), so this check should return no negative staged rows.
-- ============================================================
select *
from analytics.stg_invoices
where amount < 0
order by amount;


-- Group negative invoices by payment status.
-- This helped determine whether the negative amounts were associated
-- with a particular payment category, such as refunds.
select
    payment_status,
    count(*) as negative_invoice_count
from analytics.stg_invoices
where amount < 0
group by payment_status
order by payment_status;


-- ============================================================
-- 6. SALES REPRESENTATIVE RELATIONSHIP CHECK
-- Requirement:
-- Every opportunity should reference a valid sales representative.
--
-- Identify opportunities whose sales_rep_id does not exist in the
-- sales representative staging table.
-- ============================================================
select
    o.opportunity_id,
    o.sales_rep_id
from analytics.stg_opportunities o
left join analytics.stg_sales_reps s
    on o.sales_rep_id = s.sales_rep_id
where s.sales_rep_id is null;


-- Summarise invalid sales representative IDs and count the number
-- of opportunity records affected by each invalid ID.
select
    sales_rep_id,
    count(*) as bad_opportunity_count
from analytics.stg_opportunities
where sales_rep_id not in (
    select sales_rep_id
    from analytics.stg_sales_reps
)
group by sales_rep_id;


-- Check the invalid sales representative directly in the raw source.
-- R999 has no matching sales representative record, confirming that
-- this is a source-data referential integrity issue.
select
    opportunity_id,
    sales_rep_id
from raw.opportunities
where sales_rep_id = 'R999';


-- ============================================================
-- 7. SUBSCRIPTION DATE VALIDITY CHECK
-- Requirement:
-- A subscription end date should not occur before its start date.
--
-- Identify logically invalid subscription date ranges in staging.
-- ============================================================
select
    subscription_id,
    start_date,
    end_date,
    status
from analytics.stg_subscriptions
where end_date < start_date
order by subscription_id;


-- Validate the same date issue directly against the raw source table.
-- Casting the source fields to DATE ensures the comparison is performed
-- using proper date values.
select
    subscription_id,
    start_date,
    end_date
from raw.subscriptions
where cast(end_date as date) < cast(start_date as date)
order by subscription_id;


-- ============================================================
-- CONNECTION TO DBT TESTING
-- ============================================================
--
-- The findings from these PostgreSQL checks were later validated
-- and automated through dbt tests.
--
-- Customer duplicates
--   -> dbt unique test
--
-- Missing required values
--   -> dbt not_null tests
--
-- Standard status / category values
--   -> dbt accepted_values tests
--
-- Invoice -> Subscription relationship
--   -> dbt relationships test
--
-- Opportunity -> Sales Representative relationship
--   -> dbt relationships test
--
-- Negative invoice amounts
--   -> custom dbt test: test_invoice_amount_non_negative.sql
--
-- Invalid subscription dates
--   -> custom dbt test: test_subscription_dates_valid.sql
--
-- Overall workflow:
-- PostgreSQL investigation
--          -> identify data-quality issue
--          -> build/configure dbt test
--          -> clean or flag the issue
--          -> create trusted analytics marts
--          -> report in Power BI
-- ============================================================
