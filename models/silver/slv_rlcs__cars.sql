select distinct
    car_id,
    car_name
from {{ ref('stg_rlcs__player_stats') }}
where car_id is not null