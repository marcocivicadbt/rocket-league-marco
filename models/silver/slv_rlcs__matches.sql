with partidas as (
select distinct
    replay_id as match_id,
    leaf_group_id as group_id,
    playlist_id,
    season,
    map_code,
    title,
    match_date,
    date_has_timezone,
    duration,
    overtime_seconds,
    visibility
from {{ ref('int_rlcs__player_stats_filtered') }}
),

validez as (

    select * from {{ ref('int_rlcs__match_validity') }}     

)

select
    p.*,
    v.is_valid                                     
from partidas p
left join validez v
    on p.match_id = v.match_id                     