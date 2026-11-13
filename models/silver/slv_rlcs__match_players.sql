with filtered as (
    select * from {{ ref('int_rlcs__player_stats_filtered') }}
),

final as (
    select
        replay_id as match_id,
        {{ dbt_utils.generate_surrogate_key(['player_platform', 'player_platform_id']) }} as player_id,
        team_color,
        car_id,
        start_time,
        end_time
    from filtered
    qualify row_number() over (
        partition by replay_id, player_platform, player_platform_id
        order by end_time - start_time desc
    ) = 1
)

select * from final