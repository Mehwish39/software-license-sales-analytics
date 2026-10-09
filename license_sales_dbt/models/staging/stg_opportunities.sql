with source as (

    select *
    from {{ source('raw', 'opportunities') }}

),

cleaned as (

    select
        trim(opportunity_id) as opportunity_id,
        trim(customer_id) as customer_id,
        trim(sales_rep_id) as sales_rep_id,

        cast(created_date as date) as created_date,
        cast(expected_close_date as date) as expected_close_date,

        case
            when lower(trim(stage)) = 'won' then 'Closed Won'
            when lower(trim(stage)) = 'closed' then 'Closed Won'
            when lower(trim(stage)) = 'in review' then 'Proposal'
            else initcap(trim(stage))
        end as stage,

        abs(cast(deal_value as numeric(12,2))) as deal_value,

        cast(probability_pct as integer) as probability_pct

    from source

)

select distinct *
from cleaned