select distinct
    stg.map_code,
    mn.map_name
from {{ ref ('int_rlcs__player_stats_filtered') }} as stg
left join {{ ref('map_names') }} as mn
    on stg.map_code = mn.map_code