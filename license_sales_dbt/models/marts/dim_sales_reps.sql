{{ config(materialized='table') }}

select
    sales_rep_id,
    sales_rep_name,
    region,
    sales_team,
    hire_date
from {{ ref('stg_sales_reps') }}