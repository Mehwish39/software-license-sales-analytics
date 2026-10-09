{{ config(severity='warn') }}

select *
from {{ ref('stg_subscriptions') }}
where end_date < start_date