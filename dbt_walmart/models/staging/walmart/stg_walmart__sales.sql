select *
from {{ source('walmart', 'sales') }}