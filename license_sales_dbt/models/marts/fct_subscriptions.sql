{{ config(materialized='table') }}

select
    subscription_id,
    customer_id,
    product_id,
    start_date,
    end_date,
    seats,
    status,

    case
        when end_date >= start_date then true
        else false
    end as is_valid_date_range,

    case
        when seats is null then true
        else false
    end as is_seats_missing

from {{ ref('stg_subscriptions') }}