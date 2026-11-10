select
    {{ dbt_utils.generate_surrogate_key(['player_platform', 'player_platform_id']) }} as player_id,
    player_platform,
    player_platform_id,
    player_name
from {{ ref('int_rlcs__player_stats_filtered') }}

qualify row_number() over (
    partition by player_platform, player_platform_id
    order by player_name is null,match_date desc, replay_id desc
) = 1