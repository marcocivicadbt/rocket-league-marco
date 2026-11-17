select
    mp.match_id,
    mp.team_color,
    mp.player_id
from {{ ref('slv_rlcs__match_players') }} as mp
left join {{ ref('slv_rlcs__match_teams') }} as mt
    on  mp.match_id   = mt.match_id
    and mp.team_color = mt.team_color
where mt.match_id is null