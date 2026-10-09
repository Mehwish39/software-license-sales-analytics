{{ config(materialized='table') }}

select
    i.invoice_id,
    i.subscription_id,

    s.customer_id,
    s.product_id,

    i.invoice_date,
    i.amount,
    i.discount_pct,
    i.payment_status,

    case
        when i.payment_status = 'Paid' then i.amount
        when i.payment_status = 'Refunded' then -i.amount
        else 0
    end as net_revenue,

    case
        when s.subscription_id is null then true
        else false
    end as is_orphan_invoice

from {{ ref('stg_invoices') }} i

left join {{ ref('stg_subscriptions') }} s
    on i.subscription_id = s.subscription_id