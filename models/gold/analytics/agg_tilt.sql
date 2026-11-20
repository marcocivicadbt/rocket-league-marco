with partidas as (
    select
        d.series_id,
        d.game_number,
        d.has_overtime,
        t.team_id,
        t.won
    from {{ ref('fct_match_teams') }} as t
    inner join {{ ref('dim_match') }} as d
        on t.match_id = d.match_id
    where d.is_clean_series
      and d.series_id is not null
),

-- series fiables: todas sus partidas válidas, al menos 2 partidas y exactamente 2 equipos
series_ok as (
    select d.series_id
    from {{ ref('dim_match') }} as d
    inner join {{ ref('fct_match_teams') }} as t
        on d.match_id = t.match_id
    where d.is_clean_series
      and d.series_id is not null
    group by d.series_id
    having count_if(not d.is_valid) = 0
       and count(distinct d.match_id) >= 2
       and count(distinct t.team_id) = 2
),

-- para cada equipo y partida: ¿ganó la siguiente partida de la serie?
secuencia as (
    select
        p.*,
        lead(p.won) over (
            partition by p.series_id, p.team_id
            order by p.game_number
        ) as won_next
    from partidas as p
    inner join series_ok as s
        on p.series_id = s.series_id
),

-- solo las derrotas que tienen una partida después
derrotas as (
    select *
    from secuencia
    where not won
      and won_next is not null
),

final as (
    select
        iff(has_overtime, 'Perdió en la prórroga', 'Perdió en tiempo normal') as previous_loss,
        count(*)                                                              as losses,
        round(avg(iff(won_next, 1, 0)) * 100, 1)                              as pct_wins_next
    from derrotas
    group by 1
)

select * from final