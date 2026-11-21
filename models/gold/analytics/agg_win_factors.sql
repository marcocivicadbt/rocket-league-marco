{% set stats = [
    ('pos_time_behind_ball',        'Colocación',  'Tiempo detrás de la bola'),
    ('pos_time_defensive_third',    'Colocación',  'Tiempo en tercio defensivo'),
    ('pos_time_offensive_third',    'Colocación',  'Tiempo en tercio ofensivo'),
    ('pos_time_most_back',          'Colocación',  'Tiempo como último hombre'),
    ('pos_avg_distance_to_mates',   'Colocación',  'Distancia entre compañeros'),
    ('pos_avg_distance_to_ball',    'Colocación',  'Distancia a la bola'),
    ('boost_count_collected_small', 'Colocación',  'Pads pequeños recogidos'),
    ('mv_time_high_air',            'Mecánicas',   'Tiempo en aire alto'),
    ('mv_time_low_air',             'Mecánicas',   'Tiempo en aire bajo'),
    ('mv_count_powerslide',         'Mecánicas',   'Derrapes'),
    ('demo_inflicted',              'Agresividad', 'Demoliciones'),
    ('mv_time_supersonic_speed',    'Velocidad',   'Tiempo en supersónico'),
    ('mv_avg_speed',                'Velocidad',   'Velocidad media'),
    ('boost_amount_stolen',         'Boost',       'Boost robado'),
    ('boost_time_zero_boost',       'Boost',       'Tiempo sin boost'),
    ('core_saves',                  'Core',        'Paradas'),
    ('core_shots',                  'Core',        'Tiros')
] %}

with equipos as (
    select
        t.*,
        t.boost_amount_stolen_big + t.boost_amount_stolen_small as boost_amount_stolen,
        d.is_close_match
    from {{ ref('fct_match_teams') }} as t
    inner join {{ ref('dim_match') }} as d
        on t.match_id = d.match_id
    where d.is_valid
),

-- azul y naranja de la misma partida en una fila: diferencia azul - naranja
cruce as (
    select
        a.match_id,
        a.is_close_match,
        a.won as gana_azul
        {% for s in stats %}, a.{{ s[0] }} - b.{{ s[0] }} as {{ s[0] }}{% endfor %}
    from equipos as a
    inner join equipos as b
        on  a.match_id   = b.match_id
        and a.team_color = 'blue'
        and b.team_color = 'orange'
),

-- una fila por estadística: % de partidas en que ganó el que tuvo más
final as (
    {% for s in stats %}
    select
        '{{ s[0] }}' as stat_name,
        '{{ s[1] }}' as stat_group,
        '{{ s[2] }}' as stat_label,
        round(avg(iff({{ s[0] }} = 0, null,
                      iff(({{ s[0] }} > 0) = gana_azul, 1, 0))) * 100, 1) as pct_all_matches,
        round(avg(iff(not is_close_match or {{ s[0] }} = 0, null,
                      iff(({{ s[0] }} > 0) = gana_azul, 1, 0))) * 100, 1) as pct_close_matches,
        count(nullif({{ s[0] }}, 0))                                         as matches_compared
    from cruce
    {% if not loop.last %}union all{% endif %}
    {% endfor %}
)

select * from final