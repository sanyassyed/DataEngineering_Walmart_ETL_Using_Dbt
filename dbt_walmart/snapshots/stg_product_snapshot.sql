{% snapshot stg_product_snapshot %}

    {{
        config(
            target_schema='snapshots',
            strategy='check',
            unique_key='prod_key',
            check_cols='all',
        )
    }}

    select 
        * 
    from 
        {{ source('raw', 'product') }}
    order by
        prod_key

{% endsnapshot %}