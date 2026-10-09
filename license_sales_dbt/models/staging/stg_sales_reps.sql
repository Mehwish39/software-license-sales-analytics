with source as (

    select *
    from {{ source('raw', 'sales_reps') }}

),

cleaned as (

    select
        trim(sales_rep_id) as sales_rep_id,
        trim(sales_rep_name) as sales_rep_name,
        trim(region) as region,
        trim(sales_team) as sales_team,
        cast(hire_date as date) as hire_date

    from source

)

select distinct *
from cleaned