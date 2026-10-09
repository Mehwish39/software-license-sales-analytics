{{ config(materialized='table') }}

select
    date_day::date as date,
    extract(year from date_day)::int as year,
    extract(quarter from date_day)::int as quarter,
    extract(month from date_day)::int as month_number,
    to_char(date_day, 'Month') as month_name,
    to_char(date_day, 'Mon') as month_short_name,
    extract(day from date_day)::int as day,
    extract(isodow from date_day)::int as day_of_week,
    to_char(date_day, 'Day') as day_name

from generate_series(
    '2023-01-01'::date,
    '2027-12-31'::date,
    interval '1 day'
) as date_day
