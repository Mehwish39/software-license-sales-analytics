{{ config(materialized='table') }}

select
    product_id,
    product_name,
    edition,
    billing_type,
    list_price
from {{ ref('stg_products') }}