select distinct
    playlist_id,
    match_type
from {{ ref('int_rlcs__player_stats_filtered') }}