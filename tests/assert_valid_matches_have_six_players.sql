select
    mp.match_id,
    count(*) as jugadores,
    count_if(mp.team_color = 'blue') as jugadores_azul
from {{ ref('slv_rlcs__match_players') }} as mp
inner join {{ ref('slv_rlcs__matches') }} as m
    on mp.match_id = m.match_id
where m.is_valid
group by mp.match_id
having count(*) <> 6
    or count_if(mp.team_color = 'blue') <> 3