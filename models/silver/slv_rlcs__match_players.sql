{{
    config(
        materialized='incremental',
        unique_key=['match_id', 'player_id'],
        incremental_strategy='merge',
        on_schema_change='fail'
    )
}}


with filtered as (
    select * from {{ ref('int_rlcs__player_stats_filtered') }}


    {% if is_incremental() %}
    -- solo partidas que todavía no están en la tabla
    where replay_id not in (select match_id from {{ this }})
    {% endif %}

),

final as (
    select
        replay_id as match_id,
        {{ dbt_utils.generate_surrogate_key(['player_platform', 'player_platform_id']) }} as player_id,
        team_color,
        car_id,
        start_time,
        end_time,

        -- core
        core_shots,
        core_goals,
        core_saves,
        core_assists,
        core_score,
        core_mvp,

        -- boost
        boost_bpm,
        boost_avg_amount,
        boost_amount_collected,
        boost_amount_stolen,
        boost_amount_collected_big,
        boost_amount_stolen_big,
        boost_amount_collected_small,
        boost_amount_stolen_small,
        boost_count_collected_big,
        boost_count_stolen_big,
        boost_count_collected_small,
        boost_count_stolen_small,
        boost_amount_overfill,
        boost_amount_overfill_stolen,
        boost_amount_used_while_supersonic,
        boost_time_zero_boost,
        boost_time_full_boost,
        boost_time_boost_0_25,
        boost_time_boost_25_50,
        boost_time_boost_50_75,
        boost_time_boost_75_100,

        -- movimiento
        mv_avg_speed,
        mv_total_distance,
        mv_time_supersonic_speed,
        mv_time_boost_speed,
        mv_time_slow_speed,
        mv_time_ground,
        mv_time_low_air,
        mv_time_high_air,
        mv_time_powerslide,
        mv_count_powerslide,

        -- posicionamiento
        pos_avg_distance_to_ball,
        pos_avg_distance_to_ball_possession,
        pos_avg_distance_to_ball_no_possession,
        pos_avg_distance_to_mates,
        pos_time_defensive_third,
        pos_time_neutral_third,
        pos_time_offensive_third,
        pos_time_defensive_half,
        pos_time_offensive_half,
        pos_time_behind_ball,
        pos_time_infront_ball,
        pos_time_most_back,
        pos_time_most_forward,
        pos_time_closest_to_ball,
        pos_time_farthest_from_ball,
        pos_goals_against_while_last_defender,

        -- demoliciones
        demo_inflicted,
        demo_taken

    from filtered
    qualify row_number() over (
        partition by replay_id, player_platform, player_platform_id
        order by end_time - start_time desc
    ) = 1
)

select * from final