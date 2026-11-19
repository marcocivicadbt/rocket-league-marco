with dias as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2021-10-01' as date)",
        end_date="cast('2026-03-01' as date)"
    ) }}
),

final as (
    select
        date_day::date                        as date_day,
        year(date_day)                        as year,
        quarter(date_day)                     as quarter,
        month(date_day)                       as month,
        monthname(date_day)                   as month_name,
        to_char(date_day, 'YYYY-MM')          as year_month,
        weekofyear(date_day)                  as week_of_year,
        dayofweekiso(date_day)                as day_of_week,
        dayname(date_day)                     as day_name,
        dayofweekiso(date_day) in (6, 7)      as is_weekend
    from dias
)

select * from final