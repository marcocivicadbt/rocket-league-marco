{{ config(severity='warn') }}

-- Posibles duplicadas que no están en la seed: replays distintos con la misma fecha,
-- la misma duración y los mismos equipos. Si aparece alguna, revisarla a mano y,
-- si se confirma, añadirla a la seed duplicate_replays.
with por_replay as (
    select
        replay_id,
        match_date,
        duration,
        listagg(distinct team_name, ' vs ') within group (order by team_name) as equipos
    from {{ ref('int_rlcs__player_stats_filtered') }}
    group by replay_id, match_date, duration
)

select
    match_date,
    duration,
    equipos,
    count(*)                    as replays,
    listagg(replay_id, ', ')    as replay_ids
from por_replay
group by match_date, duration, equipos
having count(*) > 1