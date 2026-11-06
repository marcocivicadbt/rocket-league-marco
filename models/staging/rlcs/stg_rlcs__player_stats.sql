-- stg_rlcs__player_stats
-- Staging 1:1 con bronze: una fila = un jugador en una partida.
-- Solo renombra y castea. No filtra, no deduplica (eso se hace en silver).

with source as (

    select * from {{ source('rlcs', 'player_stats') }}

),

renamed as (

    select
        -- partida
        replay_id,
        title,
        map_code,
        match_type,
        playlist_id,
        team_size,
        duration,
        overtime,
        overtime_seconds::int                       as overtime_seconds,   -- llegaba como 23.0
        season,
        season_type,
        date                                        as match_date,         -- ya es timestamp
        date_has_timezone,
        date_parsed,
        visibility,

        -- grupos (torneo / serie)
        root_group_id,
        root_group_name,
        leaf_group_id,
        leaf_group_name,
        group_path,
        group_id_path,

        -- equipo
        team_color,
        upper(trim(team_name))                      as team_name,          -- unifica mayúsculas y espacios
        team_goals,

        -- jugador
        player_name,
        player_platform,
        player_platform_id,
        car_id::int                                 as car_id,             -- llegaba como 23.0
        car_name,
        start_time,
        end_time,

        -- configuración (no se usa en casos de uso; se descarta en silver)
        steering_sensitivity,
        camera_fov,
        camera_height,
        camera_pitch,
        camera_distance,
        camera_stiffness,
        camera_swivel_speed,
        camera_transition_speed,

        -- core
        core_shots,
        core_shots_against,
        core_goals,
        core_goals_against,
        core_saves,
        core_assists,
        core_score,
        core_mvp,
        core_shooting_percentage,

        -- boost
        boost_bpm,
        boost_bcpm,
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
        boost_percent_zero_boost,
        boost_time_full_boost,
        boost_percent_full_boost,
        boost_time_boost_0_25,
        boost_time_boost_25_50,
        boost_time_boost_50_75,
        boost_time_boost_75_100,
        boost_percent_boost_0_25,
        boost_percent_boost_25_50,
        boost_percent_boost_50_75,
        boost_percent_boost_75_100,

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
        mv_avg_powerslide_duration,
        mv_avg_speed_percentage,
        mv_percent_slow_speed,
        mv_percent_boost_speed,
        mv_percent_supersonic_speed,
        mv_percent_ground,
        mv_percent_low_air,
        mv_percent_high_air,

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
        coalesce(pos_goals_against_while_last_defender, 0)::int
                                                    as pos_goals_against_while_last_defender,  -- vacío = 0
        pos_time_closest_to_ball,
        pos_time_farthest_from_ball,
        pos_percent_defensive_third,
        pos_percent_offensive_third,
        pos_percent_neutral_third,
        pos_percent_defensive_half,
        pos_percent_offensive_half,
        pos_percent_behind_ball,
        pos_percent_infront_ball,
        pos_percent_most_back,
        pos_percent_most_forward,
        pos_percent_closest_to_ball,
        pos_percent_farthest_from_ball,

        -- demoliciones
        demo_inflicted,
        demo_taken

    from source

)

select * from renamed