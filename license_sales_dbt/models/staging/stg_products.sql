with source as (

    select *
    from {{ source('raw', 'products') }}

),

cleaned as (

    select
        trim(product_id) as product_id,
        trim(product_name) as product_name,
        initcap(trim(edition)) as edition,
        initcap(trim(billing_type)) as billing_type,
        cast(list_price as numeric(10,2)) as list_price

    from source

)

select distinct *
from cleaned
