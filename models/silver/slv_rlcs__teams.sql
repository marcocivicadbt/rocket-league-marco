select distinct
    {{ dbt_utils.generate_surrogate_key(['team_name']) }} as team_id,
    team_name
from {{ ref('int_rlcs__player_stats_filtered') }}