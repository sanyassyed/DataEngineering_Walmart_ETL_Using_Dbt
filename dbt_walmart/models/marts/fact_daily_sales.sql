{{
    config(
        materialized = 'incremental',
        unique_key = ['CAL_DT', 'PROD_KEY', 'STORE_KEY'],
        incremental_strategy='delete+insert'
    )
}}

{% if is_incremental() %}

  {% set MAX_CAL_DATE_query %}
    select ifnull(max(cal_dt), '1900-01-01') from {{this}} as MAX_CAL_DT
  {% endset %}

  {% if execute %}
    {% set MAX_CAL_DT = run_query(MAX_CAL_DATE_query).columns[0][0] %}
  {% endif %}

{% endif %}


select
  trans_dt as cal_dt,
  store_key as store_key,
  prod_key as prod_key,
  sum(sales_qty ) as sales_qty,
  sum(sales_amt ) as sales_amt,
  avg(sales_price ) as sales_price,
  sum(sales_cost) as sales_cost,
  sum(sales_mgrn) as sales_mgrn,
  avg(discount) as discount,
  sum(ship_cost) as ship_cost,
  current_date() as UPDATE_TIME
from
    {{ ref('stg_walmart__sales') }}
where 1=1
    {% if is_incremental() %}
        and trans_dt >= '{{ MAX_CAL_DT }}'
    {% endif %}
group by 
    1,2,3