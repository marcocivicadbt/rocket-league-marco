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

grupos as (
    select distinct
        group_id,
        group_name,
        parent_group_id,
        group_level
    from trozos
),

-- grupos que son padre de alguien (los que tienen hijos)
padres as (
    select distinct parent_group_id
    from grupos
    where parent_group_id is not null
),

final as (
    select
        grupos.group_id,
        grupos.group_name,
        grupos.parent_group_id,
        grupos.group_level,
        case
            when grupos.group_level = 0 then 1                 -- season: la raíz
            when padres.parent_group_id is null then 7         -- series: no tiene hijos (hoja)
            when regexp_replace(grupos.group_name, '^\\[\\d+\\] ', '') in (
                'Europe', 'North America', 'South America', 'Oceania',
                'Middle East & North Africa', 'Sub-Saharan Africa',
                'Asia-Pacific', 'Asia-Pacific North', 'Asia-Pacific South'
            ) then 4                                           -- region: lista cerrada
        end as group_type_id                                   -- resto: vacío (no identificable con seguridad)
    from grupos
    left join padres
        on grupos.group_id = padres.parent_group_id
)

select * from final