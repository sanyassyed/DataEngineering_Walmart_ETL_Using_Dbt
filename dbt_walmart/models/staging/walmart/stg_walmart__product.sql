  {{
      config(
          materialized = 'incremental',
          incremental_strategy='merge',
          unique_key = ['prod_key', 'prod_name', 'vol', 'wgt', 'brand_name', 'status_code', 'status_code_name', 'category_key', 'category_name', 'subcategory_key', 'subcategory_name']
      )
  }}

  {% if is_incremental() %}

    {% set MAX_START_DATE_query %}
      select ifnull(max(start_date), '1900-01-01') from {{this}} as MAX_START_DT
    {% endset %}

    {% if execute %}
      {% set MAX_START_DT = run_query(MAX_START_DATE_query).columns[0][0] %}
    {% endif %}

  {% endif %}

  select 
      prod_key,
      prod_name,
      vol,
      wgt,
      brand_name,
      status_code,
      status_code_name,
      category_key,
      category_name,
      subcategory_key,
      subcategory_name,
      sysdate() as start_date
  from 
      {{ source('walmart', 'product') }}
  where 1=1
      {% if is_incremental() %}
          and start_date >= '{{ MAX_START_DT }}'
      {% endif %}

-- we are not checking the start_date column in the unique keys so when all other columns match the start_date column will be updated
-- and when any one of the those columns don't match the whole new row will be inserted
-- Eg: if the product data remains the same only the start_date will be updated
-- and if for example the product name changes a new record will be inserted with the new start_date and the old record for the same product will have the old start_date
-- thus maintaining historical data Type 2 SCD