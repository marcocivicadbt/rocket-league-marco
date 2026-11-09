select distinct
    car_id,
    car_name
from {{ ref('int_rlcs__player_stats_filtered') }}
where car_id is not null