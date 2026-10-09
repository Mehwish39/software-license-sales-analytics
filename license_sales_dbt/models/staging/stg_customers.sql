with source as (

    select *
    from {{ source('raw', 'customers') }}

),

cleaned as (

    select
        trim(customer_id) as customer_id,
        trim(company_name) as company_name,

        nullif(trim(industry), '') as industry,

        case
            when lower(trim(country)) in ('uk', 'united kingdom')
                then 'United Kingdom'
            when lower(trim(country)) in ('usa', 'us', 'united states')
                then 'United States'
            else initcap(trim(country))
        end as country,

        initcap(trim(company_size)) as company_size,

        cast(signup_date as date) as signup_date

    from source

)

select distinct *
from cleaned