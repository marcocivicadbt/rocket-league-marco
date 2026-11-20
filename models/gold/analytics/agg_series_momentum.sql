with partidas as (
    select
        d.series_id,
        d.game_number,
        t.team_id,
        t.won
    from {{ ref('fct_match_teams') }} as t
    inner join {{ ref('dim_match') }} as d
        on t.match_id = d.match_id
    where d.is_clean_series
      and d.series_id is not null
),

-- series que se pueden usar: todas sus partidas válidas, al menos 3 partidas
-- y exactamente 2 equipos (descarta variantes de nombre, TBD/TBA y equipos sin nombre)
series_ok as (
    select d.series_id
    from {{ ref('dim_match') }} as d
    inner join {{ ref('fct_match_teams') }} as t
        on d.match_id = t.match_id
    where d.is_clean_series
      and d.series_id is not null
    group by d.series_id
    having count_if(not d.is_valid) = 0
       and count(distinct d.match_id) >= 3
       and count(distinct t.team_id) = 2
),

-- por cada equipo en cada serie: victorias y si ganó la G1 y la G2
por_equipo as (
    select
        p.series_id,
        p.team_id,
        count_if(p.won)                              as wins,
        max(iff(p.game_number = 1, p.won, null))     as won_g1,
        max(iff(p.game_number = 2, p.won, null))     as won_g2
    from partidas as p
    inner join series_ok as s
        on p.series_id = s.series_id
    group by p.series_id, p.team_id
),

-- cada equipo frente a su rival en la serie: ¿ganó la serie?
series as (
    select
        a.series_id,
        a.won_g1,
        a.won_g2,
        a.wins > b.wins as won_series
    from por_equipo as a
    inner join por_equipo as b
        on  a.series_id = b.series_id
        and a.team_id  <> b.team_id
    where a.wins <> b.wins
),

final as (
    select 'Gana la G1' as scenario,
           count(*) as series,
           round(avg(iff(won_series, 1, 0)) * 100, 1) as pct_wins_series
    from series where won_g1

    union all
    select 'Pierde la G1',
           count(*), round(avg(iff(won_series, 1, 0)) * 100, 1)
    from series where not won_g1

    union all
    select 'Gana la G1 y la G2 (2-0)',
           count(*), round(avg(iff(won_series, 1, 0)) * 100, 1)
    from series where won_g1 and won_g2

    union all
    select 'Pierde la G1 y la G2 (0-2)',
           count(*), round(avg(iff(won_series, 1, 0)) * 100, 1)
    from series where not won_g1 and not won_g2
)

select * from final