# ETL on Walmart Data
## Extraction from Relational DB using `Dbeaver`
## Loading data into `Snowflake`
## Transformation using `dbt`

## Notes:
* Instruction [here](./instructions.pdf)
* Run this everytime `source .venv/bin/activate`
* Move the profiles.yml to the project root directory `mv /home/codespace/.dbt/profiles.yml .`
* Use the following command from the project root directory `dbt debug --project-dir dbt_walmart`
* Load Data from the csv files [here](https://s3.amazonaws.com/weclouddata/data/data/walmart%20raw%20data.zip) into Snowflake database `WALMART` in the schema `LAND`
* Use the scripts [here](./scripts/loading_and_eda.sql)
* Data Structure
    * `calendar` -> `dim_calendar`
    * `store` -> `dim_store`
    * `product` -> `dim_product`
    * `sales` + `inventory` -> `fact_daily_sales`, `fact_weekly_sales`


Column Name | Topic                                         |Step  |Input                    | folder            | model                   | transformation                                                                        | Schema             | Notes
store       |Type 1 SCD                                     |1     |land.store               | models/staging    |stg_walmart__store.sql   |                                                                                       |land (View)         |
store       |Type 1 SCD                                     |2     |stg_walmart__store.sql   | models/mart       |dim__store.sql           | materialization = incremental, strategy = merge, unique_key(primary_key)              |enterprise (Table)  |
product     |Type 2 SCD Insert & Update with materialization|1     |land.product             | models/staging    |stg_walmart__product.sql | materialization = incremental, strategy = merge, unique_key(all columns) + start_date |land (View)         |Matches 
product     |Type 2 SCD Insert & Update with materialization|2     |stg_product__product.sql | models/mart       |dim_product__stg.sql     | lag() + deactivate_date + active_status                                               |enterprise (Table)  |
