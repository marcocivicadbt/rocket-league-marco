{{ config(materialized='view') }}

with equipos as (

    select
        replay_id,
        team_color,
        max(team_goals) as goles_equipo,
        sum(core_goals) as goles_jugadores
    from {{ ref('int_rlcs__player_stats_filtered') }}
    group by replay_id, team_color

),

partidas as (

    select
        replay_id,
        max(duration)   as duracion,
        max(start_time) as entrada_mas_tardia,
        min(end_time)   as salida_mas_temprana,
        max(overtime_seconds) as segundos_prorroga
    from {{ ref('int_rlcs__player_stats_filtered') }}
    group by replay_id

),

goles as (

    select
        replay_id,
        max(iff(team_color = 'blue',   goles_equipo, null)) as goles_azul,
        max(iff(team_color = 'orange', goles_equipo, null)) as goles_naranja,
        count_if(goles_equipo <> goles_jugadores) > 0       as goles_no_cuadran
    from equipos
    group by replay_id

),

final as (

    select
        p.replay_id                                       as match_id,
        p.duracion < {{ var('min_match_seconds') }}       as is_short,
        p.entrada_mas_tardia > {{ var('abandonment_seconds') }}
            or p.salida_mas_temprana < p.duracion - {{ var('abandonment_seconds') }}    as has_abandonment,
        g.goles_no_cuadran                                as has_goal_mismatch,
        g.goles_azul = g.goles_naranja                    as is_tie,
        p.segundos_prorroga is not null and abs(g.goles_azul - g.goles_naranja) <> 1  as has_overtime_mismatch
    from partidas p
    inner join goles g
        on p.replay_id = g.replay_id

)

select
    *,
    not (is_short or has_abandonment or has_goal_mismatch or is_tie or has_overtime_mismatch) as is_valid
from final