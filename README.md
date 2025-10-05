# ETL on Walmart Data
## Extraction from Relational DB using `Dbeaver`
## Loading data into `Snowflake`
## Transformation using `dbt`

## Notes:
* Move the profiles.yml to the project root directory `mv /home/codespace/.dbt/profiles.yml .`
* Use the following command from the project root directory `dbt debug --project-dir dbt_walmart`
* Load Data from the csv files [here](https://s3.amazonaws.com/weclouddata/data/data/walmart%20raw%20data.zip) into Snowflake database `WALMART` in the schema `LAND`
* Use the scripts [here](./scripts/loading_and_eda.sql)
* Data Structure
    * `calendar` -> `dim_calendar`
    * `store` -> `dim_store`
    * `product` -> `dim_product`
    * `sales` + `inventory` -> `fact_daily_sales`, `fact_weekly_sales`