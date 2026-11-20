{{ config(materialized='view') }}

{% set stats_suma = [
    'core_shots', 'core_goals', 'core_saves', 'core_assists', 'core_score',
    'boost_bpm',
    'boost_amount_collected_big', 'boost_amount_stolen_big',
    'boost_amount_collected_small', 'boost_amount_stolen_small',
    'boost_count_collected_big', 'boost_count_stolen_big',
    'boost_count_collected_small', 'boost_count_stolen_small',
    'boost_amount_overfill', 'boost_amount_overfill_stolen', 'boost_amount_used_while_supersonic',
    'boost_time_zero_boost', 'boost_time_full_boost',
    'boost_time_boost_0_25', 'boost_time_boost_25_50', 'boost_time_boost_50_75', 'boost_time_boost_75_100',
    'mv_total_distance', 'mv_time_supersonic_speed', 'mv_time_boost_speed', 'mv_time_slow_speed',
    'mv_time_ground', 'mv_time_low_air', 'mv_time_high_air', 'mv_time_powerslide', 'mv_count_powerslide',
    'pos_time_defensive_third', 'pos_time_neutral_third', 'pos_time_offensive_third',
    'pos_time_defensive_half', 'pos_time_offensive_half',
    'pos_time_behind_ball', 'pos_time_infront_ball',
    'pos_time_most_back', 'pos_time_most_forward',
    'pos_time_closest_to_ball', 'pos_time_farthest_from_ball',
    'pos_goals_against_while_last_defender',
    'demo_inflicted', 'demo_taken'
] %}

{% set stats_media = [
    'boost_avg_amount', 'mv_avg_speed',
    'pos_avg_distance_to_ball', 'pos_avg_distance_to_ball_possession',
    'pos_avg_distance_to_ball_no_possession', 'pos_avg_distance_to_mates'
] %}

with match_players as (
    select * from {{ ref('slv_rlcs__match_players') }}
),

final as (
    select
        match_id,
        team_color
        {% for s in stats_suma %}, sum({{ s }}) as {{ s }}{% endfor %}
        {% for s in stats_media %}, avg({{ s }}) as {{ s }}{% endfor %}
    from match_players
    group by match_id, team_color
)

select * from final