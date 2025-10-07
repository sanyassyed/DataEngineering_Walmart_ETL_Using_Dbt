{{ 
    config(
        materialized='incremental',
        unique_key= ['trans_dt', 'prod_key', 'store_key', 'trans_dt', 'trans_time'] 
    )
}}

select * from {{ref('stg_walmart__sales')}}

{% if is_incremental() %}
    where
        trans_dt > (select NVL(max(trans_dt), '1900-01-01') from {{this}})

{% endif %}