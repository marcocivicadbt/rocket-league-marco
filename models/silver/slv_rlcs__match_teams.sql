select distinct
    replay_id as match_id,
    team_color,
    {{ dbt_utils.generate_surrogate_key(['team_name']) }} as team_id
from {{ ref('int_rlcs__player_stats_filtered') }}

