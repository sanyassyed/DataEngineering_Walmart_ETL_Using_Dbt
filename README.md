# ETL on Walmart Data
Steps
1. Extraction from Relational DB using `Dbeaver`
1. Loading data into `Snowflake`
1. Transformation using `dbt` [DBT Project Checklist](./dbt_walmart/README.md)

## Transformation Notes:
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

## 🧩 dbt Model Flow Summary (Color-Coded)

> ✅ **Color Legend:**
> 🟩 **Staging layer** (source cleaning & standardization)
> 🟦 **Marts layer** (business-ready models, facts & dimensions)
> 🟧 **Snapshot layer** (slowly changing dimension tracking)
> ⚪ **Landing layer** (raw ingestion area)



| **Column Name** | **Option** | **Topic**                                        | **Step** | **Input**                     | **Folder**                  | **Model**                  | **Transformation**                                                                          | **Schema**             | **Notes**                                                                                                                                                                      |
| --------------- | ---------- | ------------------------------------------------ | -------- | ----------------------------- | --------------------------- | -------------------------- | ------------------------------------------------------------------------------------------- | ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **store** 🟩    | 1          | Type 1 SCD                                       | 1        | ⚪ `land.store`               | 🟩 `models/staging/walmart` | `stg_walmart__store.sql`   | —                                                                                           | `land` *(View)*        | —                                                                                                                                                                              |
| **store** 🟦    | 1          | Type 1 SCD                                       | 2        | 🟩 `stg_walmart__store.sql`   | 🟦 `models/mart`            | `dim_store.sql`            | `materialized='incremental'`, `strategy='merge'`, `unique_key` = primary key                | `enterprise` *(Table)* | —                                                                                                                                                                              |
| **product** 🟩  | 1          | Type 2 SCD *(Insert & Update — materialization)* | 1        | ⚪ `land.product`             | 🟩 `models/staging/walmart` | `stg_walmart__product.sql` | `materialized='incremental'`, `strategy='merge'`, `unique_key` = all columns + `start_date` | `land` *(Table)*       | Incremental models can only be **tables**. Matches on all columns and appends changes while keeping old records. Remove `unique` test on `prod_key` since we maintain history. |
| **product** 🟦  | 1          | Type 2 SCD *(Insert & Update — materialization)* | 2        | 🟩 `stg_walmart__product.sql` | 🟦 `models/mart`            | `dim_product.sql`          | Uses `lag()` + `deactivate_date` + `active_status`                                          | `enterprise` *(Table)* | Adds columns `deactivate_date` & `active_status`.                                                                                                                              |
| **product** 🟧  | 2          | Type 2 SCD *(with snapshot)*                     | 1        | ⚪ `land.product`             | 🟧 `snapshots`              | `stg_product_snapshot.sql` | Uses `snapshot` macro; `strategy='check'`, `unique_key=prod_key`, `check_cols='all'`        | `snapshots` *(Table)*  | Appends changes while keeping old records. dbt auto-generates `DBT_UPDATED_AT`, `DBT_VALID_FROM`, `DBT_VALID_TO`.                                                              |
| **product** 🟦  | 2          | Type 2 SCD *(with snapshot)*                     | 2        | 🟧 `stg_product_snapshot.sql` | 🟦 `models/mart`            | `dim_product_snapshot.sql` | Renames columns + derives active flag using `IFF(dbt_valid_to IS NULL, TRUE, FALSE)`        | `enterprise` *(Table)* | Renames `DBT_VALID_FROM` → `start_date`, `DBT_VALID_TO` → `deactivated_date`, adds `active_status`.                                                                            |
| **sales** 🟩    | 1          | Incremental *(delete + insert)*                  | 1        | ⚪ `land.sales`               | 🟩 `models/staging/walmart` | `stg_walmart__sales.sql`   | —                                                                                           | `land` *(View)*        | —                                                                                                                                                                              |
| **sales** 🟦    | 1          | Incremental *(delete + insert)*                  | 2        | 🟩 `stg_walmart__sales.sql`   | 🟦 `models/mart`            | `fact_daily_sales.sql`     | Aggregates only rows greater than max date in existing sales table                          | `enterprise` *(Table)* | —                                                                                                                                                                              |

