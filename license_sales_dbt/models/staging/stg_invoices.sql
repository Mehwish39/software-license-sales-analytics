with source as (

    select *
    from {{ source('raw', 'invoices') }}

),

cleaned as (

    select
        trim(invoice_id) as invoice_id,
        trim(subscription_id) as subscription_id,

        cast(invoice_date as date) as invoice_date,
        abs(cast(amount as numeric(12,2))) as amount,
        cast(discount_pct as numeric(5,2)) as discount_pct,

        initcap(trim(payment_status)) as payment_status

    from source

)

select distinct *
from cleaned