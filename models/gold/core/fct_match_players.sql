{{
    config(
        materialized='incremental',
        unique_key='match_player_id',
        incremental_strategy='merge',
        on_schema_change='fail'
    )
}}

with match_players as (
    select * from {{ ref('slv_rlcs__match_players') }}
    {% if is_incremental() %}
    -- solo partidas que todavía no están en la tabla
    where match_id not in (select match_id from {{ this }})
    {% endif %}
),

matches as (
    select match_id, match_date from {{ ref('slv_rlcs__matches') }}
),

match_teams as (
    select match_id, team_color, team_id from {{ ref('slv_rlcs__match_teams') }}
),

team_stats as (
    select match_id, team_color, core_goals from {{ ref('int_match_team_stats') }}
),

-- cada equipo frente a su rival: ¿marcó más goles?
resultado as (
    select
        t.match_id,
        t.team_color,
        t.core_goals > r.core_goals as won
    from team_stats as t
    inner join team_stats as r
        on  t.match_id   = r.match_id
        and t.team_color <> r.team_color
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['mp.match_id', 'mp.player_id']) }} as match_player_id,
        mp.match_id,
        mp.player_id,
        mt.team_id,
        mp.car_id,
        m.match_date::date               as date_day,
        mp.team_color,
        res.won,
        mp.end_time - mp.start_time      as seconds_played,
        mp.* exclude (match_id, player_id, team_color, car_id)
    from match_players as mp
    inner join matches     as m   on mp.match_id = m.match_id
    left join match_teams  as mt  on mp.match_id = mt.match_id  and mp.team_color = mt.team_color
    left join resultado    as res on mp.match_id = res.match_id and mp.team_color = res.team_color
)

select * from final