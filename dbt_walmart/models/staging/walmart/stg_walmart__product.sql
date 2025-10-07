SELECT *
FROM {{ source("walmart", "product") }}