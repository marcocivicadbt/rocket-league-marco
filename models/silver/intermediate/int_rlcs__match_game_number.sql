{{ config(materialized='view') }}

with partidas as (
    select distinct
        replay_id as match_id,
        leaf_group_id as group_id,
        match_date,
        title
    from {{ ref('int_rlcs__player_stats_filtered') }}
),

numerado as (
    select
        match_id,
        group_id,
        row_number() over (
            partition by group_id
            order by match_date, match_id
        ) as game_number,
        -- último "G/Game + número" del título (el primero puede ser un equipo: G1, G2, G6)
        regexp_substr(title, ' (G|Game) ?([1-7])', 1,
                      greatest(regexp_count(title, ' (G|Game) ?([1-7])', 1, 'i'), 1),
                      'ie', 2)::int as title_game_number
    from partidas
),

series as (
    select
        group_id,
        count(*) = count_if(title_game_number = game_number) as is_clean_series
    from numerado
    group by group_id
),

final as (
    select
        numerado.match_id,
        numerado.game_number,
        numerado.title_game_number,
        series.is_clean_series
    from numerado
    inner join series
        on numerado.group_id = series.group_id
)

select * from final