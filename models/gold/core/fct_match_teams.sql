with team_stats as (
    select * from {{ ref('int_match_team_stats') }}
),

match_teams as (
    select match_id, team_color, team_id from {{ ref('slv_rlcs__match_teams') }}
),

matches as (
    select match_id, match_date from {{ ref('slv_rlcs__matches') }}
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
        {{ dbt_utils.generate_surrogate_key(['ts.match_id', 'ts.team_color']) }} as match_team_id,
        ts.match_id,
        mt.team_id,
        m.match_date::date   as date_day,
        ts.team_color,
        res.won,
        ts.* exclude (match_id, team_color)
    from team_stats as ts
    inner join matches    as m   on ts.match_id = m.match_id
    left join match_teams as mt  on ts.match_id = mt.match_id  and ts.team_color = mt.team_color
    left join resultado   as res on ts.match_id = res.match_id and ts.team_color = res.team_color
)

select * from final