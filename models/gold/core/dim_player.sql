with players as (
    select * from {{ ref('slv_rlcs__players') }}
),

final as (
    select
        player_id,
        player_name,
        player_platform
    from players
)

select * from final