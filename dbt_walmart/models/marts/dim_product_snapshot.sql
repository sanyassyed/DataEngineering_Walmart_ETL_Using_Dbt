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
    dbt_valid_from as start_date,
    dbt_valid_to as deactivate_date,
    iff(dbt_valid_to is null, true, false) as active_status
from 
    {{ ref('stg_product_snapshot') }}