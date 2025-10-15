# ETL on Walmart Data
## Extraction from Relational DB using `Dbeaver`
## Loading data into `Snowflake`
## Transformation using `dbt`

## Notes:
* Instructions [here](./instructions.ipynb)
* Run this everytime `source .venv/bin/activate`
* Move the profiles.yml to the project root directory `mv /home/codespace/.dbt/profiles.yml .`
* Use the following command from the project root directory `dbt debug --project-dir dbt_walmart`
* Load Data from the csv files [here](https://s3.amazonaws.com/weclouddata/data/data/walmart%20raw%20data.zip) into Snowflake database `WALMART` in the schema `LAND`
* Use the scripts [here](./scripts/loading_and_eda.sql)
* Data Structure
    * `calendar` -> `dim_calendar`
    * `store`    -> `dim_store`
    * `product`  -> `dim_product` & `dim_product_snapshot`
    * `sales` + `inventory` -> `fact_daily_sales`, `fact_weekly_sales`
* Add test in _walmart_models.yml to check if three columns together are unique using dbt_utils package 
* Snowflake:
    * WHEN `MATCHED` -> `Update`
    * WHEN `NOT MATCHED` -> `Insert`



| Column Name |Option  | Topic                                          |Step  |Input                    | folder                    | model                    | transformation                                                                        | Schema             | Notes
| store       |1       | Type 1 SCD                                     |1     |land.store               | models/staging/walmart    |stg_walmart__store.sql    |                                                                                       |land (View)         |
| store       |1       | Type 1 SCD                                     |2     |stg_walmart__store.sql   | models/mart               |dim_store.sql             | materialization = incremental, strategy = merge, unique_key(primary_key)              |enterprise (Table)  |
| product     |1       | Type 2 SCD Insert & Update with materialization|1     |land.product             | models/staging/walmart    |stg_walmart__product.sql  | materialization = incremental, strategy = merge, unique_key(all columns) + start_date |land (Table)        |`incremental materializations` can only be tables, Matches on all columns and only appends the changes while keeping the old records, remove unique key test for prod_key as we are maintaining history
| product     |1       | Type 2 SCD Insert & Update with materialization|2     |stg_walmart__product.sql | models/mart               |dim_product.sql           | lag() + deactivate_date + active_status                                               |enterprise (Table)  |Adds new columns `deactivate_date` & `active_status`
| product     |2       | Type 2 SCD with snapshot                       |1     |land.product             | snapshots                 |stg_product_snapshot.sql  | snapshot macro, strategy = check, unique_key(prod_key) + check_cols = 'all'           |snapshots (Table)   |Matches on all columns and only appends the changes while keeping the old records and generated new dbt columns `DBT_UPDATED_AT`, `DBT_VALID_FROM`, `DBT_VALID_TO`
| product     |2       | Type 2 SCD with snapshot                       |2     |stg_product_snapshot.sql | models/mart               |dim_product_snapshot.sql  | column rename and iff(dbt_valid_to is null, true, false) as active_status             |enterprise (Table)  |Renames the columns `DBT_VALID_FROM`, DBT_VALID_TO` to `start_date` & `deactivated_date` respectively and adds new column `acive_status`
| sales       |1       | Incremental with delete + insert               |1     |land.sales.sql           | models/staging/walmart    |stg_walmart__sales.sql    |                                                                                       |land (View)         |
| sales       |1       | Incremental with delete + insert               |2     |stg_walmart__sales.sql   | models/mart               |fact_daily_sales.sql      | Perform aggregations only on rows greater than the max date in the sales table in ent |enterprise (Table)  |