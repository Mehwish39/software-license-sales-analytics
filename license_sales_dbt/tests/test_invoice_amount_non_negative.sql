select *
from {{ ref('stg_invoices') }}
where amount < 0