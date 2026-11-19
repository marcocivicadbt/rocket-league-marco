with teams as (
    select * from {{ ref('slv_rlcs__teams') }}
),

final as (
    select
        team_id,
        team_name
    from teams
)

select * from final