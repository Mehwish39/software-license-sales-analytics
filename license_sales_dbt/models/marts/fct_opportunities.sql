{{ config(materialized='table') }}

select
    o.opportunity_id,
    o.customer_id,
    o.sales_rep_id,
    o.created_date,
    o.expected_close_date,
    o.stage,
    o.deal_value,
    o.probability_pct,

    round(
        o.deal_value * o.probability_pct / 100.0,
        2
    ) as weighted_pipeline_value,

    case
        when o.stage = 'Closed Won' then true
        else false
    end as is_closed_won,

    case
        when o.stage in ('Closed Won', 'Closed Lost') then true
        else false
    end as is_closed,

    case
        when r.sales_rep_id is null then true
        else false
    end as is_orphan_sales_rep

from {{ ref('stg_opportunities') }} o

left join {{ ref('stg_sales_reps') }} r
    on o.sales_rep_id = r.sales_rep_id