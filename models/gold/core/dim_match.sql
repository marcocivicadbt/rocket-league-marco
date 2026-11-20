with recursive

matches as (
    select * from {{ ref('slv_rlcs__matches') }}
),

maps as (
    select * from {{ ref('slv_rlcs__maps') }}
),

playlists as (
    select * from {{ ref('slv_rlcs__playlists') }}
),

game_seasons as (
    select * from {{ ref('slv_rlcs__game_seasons') }}
),

grupos as (
    select * from {{ ref('slv_rlcs__competition_groups') }}
),

team_stats as (
    select * from {{ ref('int_match_team_stats') }}
),

-- sube por el árbol desde la serie de cada partida hasta la temporada
ancestros (match_id, group_id, parent_group_id, group_name, group_type_id) as (
    select m.match_id, g.group_id, g.parent_group_id, g.group_name, g.group_type_id
    from matches as m
    inner join grupos as g on m.group_id = g.group_id

    union all

    select a.match_id, p.group_id, p.parent_group_id, p.group_name, p.group_type_id
    from ancestros as a
    inner join grupos as p on a.parent_group_id = p.group_id
),

competicion as (
    select
        match_id,
        max(iff(group_type_id = 1, group_name, null)) as rlcs_season,
        max(iff(group_type_id = 4,
                replace(regexp_replace(group_name, '^\\[\\d+\\] ', ''),
                        'Middle East and North Africa', 'Middle East & North Africa'),
                null)) as region
    from ancestros
    group by match_id
),

goles as (
    select
        match_id,
        abs(max(iff(team_color = 'blue',   core_goals, null))
          - max(iff(team_color = 'orange', core_goals, null))) = 1 as is_close_match
    from team_stats
    group by match_id
),

final as (
    select
        m.match_id,
        m.match_date,
        m.title,
        m.duration,
        m.overtime_seconds,
        m.overtime_seconds is not null              as has_overtime,
        mp.map_name,
        pl.match_type,
        m.season,
        gs.season_type,
        c.rlcs_season,
        c.region,
        iff(g.group_type_id = 7, g.group_id, null)   as series_id,
        iff(g.group_type_id = 7, g.group_name, null) as series_name,
        m.game_number,
        m.is_clean_series,
        m.is_valid,
        gl.is_close_match
    from matches as m
    left join maps         as mp on m.map_code    = mp.map_code
    left join playlists    as pl on m.playlist_id = pl.playlist_id
    left join game_seasons as gs on m.season      = gs.season
    left join grupos       as g  on m.group_id    = g.group_id
    left join competicion  as c  on m.match_id    = c.match_id
    left join goles        as gl on m.match_id    = gl.match_id
)

select * from final