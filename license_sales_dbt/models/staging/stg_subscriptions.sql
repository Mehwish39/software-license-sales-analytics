with source as (

    select *
    from {{ source('raw', 'subscriptions') }}

),

cleaned as (

    select
        trim(subscription_id) as subscription_id,
        trim(customer_id) as customer_id,
        trim(product_id) as product_id,

        cast(start_date as date) as start_date,
        cast(end_date as date) as end_date,

        cast(seats as integer) as seats,

        case
            when lower(trim(status)) = 'actve' then 'Active'
            when lower(trim(status)) = 'canceled' then 'Cancelled'
            else initcap(trim(status))
        end as status

    from source

)

select distinct *
from cleaned