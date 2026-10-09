{{ config(materialized='table') }}

select
    customer_id,
    company_name,
    industry,
    country,
    company_size,
    signup_date
from {{ ref('stg_customers') }}