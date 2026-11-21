{% macro simular_datos_pendientes(desde='2026-01-01') %}
    {#- Aparta las partidas desde la fecha indicada a PLAYER_STATS_PENDIENTES y las quita de bronze -#}

    {% if target.name == 'pro' %}
        {{ exceptions.raise_compiler_error("Esta macro es solo para la demostración en DEV, nunca en PRO") }}
    {% endif %}

    {% set bronze = source('rlcs', 'player_stats') %}
    {% set pendientes = bronze.database ~ '.' ~ bronze.schema ~ '.PLAYER_STATS_PENDIENTES' %}

    {% do run_query("create table " ~ pendientes ~ " as select * from " ~ bronze ~ " where date >= '" ~ desde ~ "'") %}
    {% do run_query("delete from " ~ bronze ~ " where date >= '" ~ desde ~ "'") %}

    {% set filas = run_query("select count(*) from " ~ pendientes).columns[0].values()[0] %}
    {{ log("Apartadas " ~ filas ~ " filas desde " ~ desde ~ " a " ~ pendientes, info=True) }}
{% endmacro %}


{% macro simular_llegada() %}
    {#- Devuelve a bronze las filas apartadas ("llegan" los datos nuevos) y borra la tabla temporal -#}

    {% if target.name == 'pro' %}
        {{ exceptions.raise_compiler_error("Esta macro es solo para la demostración en DEV, nunca en PRO") }}
    {% endif %}

    {% set bronze = source('rlcs', 'player_stats') %}
    {% set pendientes = bronze.database ~ '.' ~ bronze.schema ~ '.PLAYER_STATS_PENDIENTES' %}

    {% set filas = run_query("select count(*) from " ~ pendientes).columns[0].values()[0] %}
    {% do run_query("insert into " ~ bronze ~ " select * from " ~ pendientes) %}
    {% do run_query("drop table " ~ pendientes) %}

    {{ log("Llegan " ~ filas ~ " filas nuevas a " ~ bronze, info=True) }}
{% endmacro %}