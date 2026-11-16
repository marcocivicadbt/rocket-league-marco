with goles_por_equipo as (
    select
        mp.match_id,
        mp.team_color,
        sum(mp.core_goals) as goles
    from {{ ref('slv_rlcs__match_players') }} as mp
    inner join {{ ref('slv_rlcs__matches') }} as m
        on mp.match_id = m.match_id
    where m.is_valid
    group by mp.match_id, mp.team_color
)

select match_id
from goles_por_equipo
group by match_id
having min(goles) = max(goles)