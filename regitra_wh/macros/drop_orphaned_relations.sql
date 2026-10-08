{% macro drop_orphaned_relations(
        dry_run = true
    ) %}
    {% if execute %}
        {% set keep = [] %}
        {% for n in graph.nodes.values() if n.resource_type in ['model', 'seed', 'snapshot'] %}
            {% do keep.append(
                n.alias | lower
            ) %}
        {% endfor %}

        {% for s in graph.sources.values() %}
            {% do keep.append(
                s.identifier | lower
            ) %}
        {% endfor %}

        {% set rows = run_query(
            "select table_name, table_type from information_schema.tables " ~ "where table_schema = '" ~ target.schema ~ "'"
        ) %}
        {% for r in rows if r [0] | lower not in keep %}
            {% set kind = 'view' if r [1] == 'VIEW' else 'table' %}
            {% set stmt = 'drop ' ~ kind ~ ' ' ~ target.schema ~ '.' ~ r [0] %}
            {% if dry_run %}
                {{ log(
                    'would run: ' ~ stmt,
                    info = true
                ) }}
            {% else %}
                {{ log(
                    stmt,
                    info = true
                ) }}

                {% do run_query(stmt) %}
            {% endif %}
        {% endfor %}
    {% endif %}
{% endmacro %}

-- dbt run-operation drop_orphaned_relations
-- dbt run-operation drop_orphaned_relations --args '{dry_run: false}'
