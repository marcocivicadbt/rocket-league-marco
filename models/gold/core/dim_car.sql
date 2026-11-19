with cars as (
    select * from {{ ref('slv_rlcs__cars') }}
),

final as (
    select
        car_id,
        coalesce(car_name, 'Desconocido (id ' || car_id || ')') as car_name
    from cars
)

select * from final