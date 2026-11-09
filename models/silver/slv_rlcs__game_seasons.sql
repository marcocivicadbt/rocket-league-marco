select distinct
    season,
    season_type
from {{ ref('int_rlcs__player_stats_filtered') }}