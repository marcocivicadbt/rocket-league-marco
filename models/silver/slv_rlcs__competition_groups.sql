with filtered as (
    select * from {{ ref('int_rlcs__player_stats_filtered') }}
),

rutas as (
    select distinct group_id_path, group_path
    from filtered
),

trozos as (
    select
        f.index as group_level,
        f.value::string as group_id,
        split(rutas.group_path, ' / ')[f.index]::string as group_name,
        iff(f.index = 0, null,
            split(rutas.group_id_path, ' / ')[f.index - 1]::string) as parent_group_id
    from rutas,
        lateral flatten(input => split(rutas.group_id_path, ' / ')) as f
),

final as (
    select distinct
        group_id,
        group_name,
        parent_group_id,
        group_level
    from trozos
)

select * from final