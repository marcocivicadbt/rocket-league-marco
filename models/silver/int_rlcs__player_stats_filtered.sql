with stg as (

    select * from {{ ref('stg_rlcs__player_stats') }}

),

jugadores_por_equipo as (

    select
        replay_id,
        team_color,
        count(distinct player_platform || '-' || player_platform_id) as num_jugadores
    from stg
    group by replay_id, team_color

),

partidas_3v3 as (

    select replay_id
    from jugadores_por_equipo
    group by replay_id
    having count(*) = 2                -- dos equipos
       and min(num_jugadores) = 3      -- y los dos con 3 jugadores
       and max(num_jugadores) = 3

),

final as (

    select stg.*
    from stg
    inner join partidas_3v3
        on stg.replay_id = partidas_3v3.replay_id
    where coalesce(stg.playlist_id, '') not ilike 'ranked%'
      and stg.replay_id not in (
          select replay_id from {{ ref('duplicate_replays') }}
      )

)

select * from final