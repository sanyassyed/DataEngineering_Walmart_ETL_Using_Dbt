SELECT *,
      sysdate() as updated_at
FROM {{ref('stg_walmart__store')}}