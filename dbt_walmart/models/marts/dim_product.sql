select 
    *,
    lag(start_date, 1) over(partition by prod_key order by start_date desc) as deactivate_date,
    iff(deactivate_date is null, true, false) as active_status
from 
    {{ ref('stg_walmart__product')}}