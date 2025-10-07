select *
from {{ source("walmart", "inventory") }}