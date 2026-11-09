select distinct
    stg.map_code,
    mn.map_name
from {{ ref('stg_rlcs__player_stats') }} as stg
left join {{ ref('map_names') }} as mn
    on stg.map_code = mn.map_code