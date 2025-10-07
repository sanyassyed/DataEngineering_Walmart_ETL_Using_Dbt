-- Type 1 SCD
select *
from {{ source('walmart', 'store') }}