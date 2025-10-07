{{ config(
    materialized='table',
    transient=false,
    schema='"ENTERPRISE"'
) }}

{{ generate_dim_calendar('2020-01-01', '2030-12-31') }}

