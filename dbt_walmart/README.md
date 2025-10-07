# DBT Project Checklist

## **1️⃣ Install dbt and initialize a project**

1. **Install dbt** (if not done already):

```bash
pip install dbt-core dbt-postgres  # or dbt-[your adapter]
```

2. **Initialize a new dbt project**:

```bash
dbt init my_dbt_project
cd my_dbt_project
```

* This creates a **default folder structure**.

---

## **2️⃣ Folder Structure (Best Practices)**

```
my_dbt_project/
│
├── dbt_project.yml                 ← main dbt configuration file
├── packages.yml                    ← optional: manage dbt packages
├── README.md                       ← optional: project overview
│
├── models/
│   │
│   ├── staging/
│   │   ├── tpcds/
│   │   │   ├── _tpcds_sources.yml       ← defines raw data sources (source tables)
│   │   │   ├── stg_customers.sql        ← staging model for customers
│   │   │   ├── stg_orders.sql           ← staging model for orders
│   │   │   └── _tpcds_models.yml        ← docs/tests for staging models
│   │   │
│   │   └── <other_source_system>/       ← optional: more sources (e.g., jaffle_shop)
│   │       ├── _<source>_sources.yml
│   │       └── stg_<source>_*.sql
│   │
│   ├── intermediate/
│   │   ├── int_customer_orders.sql      ← joins or aggregations between staging and marts
│   │   └── _intermediate_models.yml     ← docs/tests for intermediate models
│   │
│   ├── marts/
│   │   ├── core/
│   │   │   ├── dim_customers.sql
│   │   │   ├── fct_orders.sql
│   │   │   └── _core_models.yml         ← docs/tests for core marts
│   │   │
│   │   ├── operational/
│   │   │   ├── dim_inventory.sql
│   │   │   ├── fct_sales.sql
│   │   │   └── _operational_models.yml  ← docs/tests for operational marts
│   │   │
│   │   └── finance/
│   │       ├── fct_revenue.sql
│   │       └── _finance_models.yml      ← optional additional mart area
│   │
│   └── _project_docs.yml                ← optional project-level documentation or metadata
│
├── snapshots/
│   ├── customer_snapshot.sql
│   └── _snapshots.yml                   ← docs/tests for snapshot models
│
├── seeds/                               ← static CSV data for lookups or reference tables
│   └── lookup_countries.csv
│
├── macros/                              ← reusable macros and custom tests
│   └── my_macro.sql
│
├── analyses/                            ← optional: exploratory SQL analysis
│   └── ad_hoc_query.sql
│
└── tests/                               ← optional: additional test definitions (custom .sql tests)
    └── my_custom_test.sql

```

✅ **Checklist**:

* [ ] `dbt_project.yml` configured with correct `source-paths` and `target-paths`
* [ ] Connection profile exists in `profiles.yml`
* [ ] Models organized by **layer** (`stg_`, `int_`, `fct_/dim_`)
* [ ] Source YAML (`sources.yml`) created
* [ ] Model YAML (`<source>_models.yml`) created
* [ ] Docs YAML (`<source>_docs.yml`) created

---

## **3️⃣ Create your first source**

1. Create **sources.yml**:

```yaml
version: 2

sources:
  - name: jaffle_shop
    tables:
      - name: customers
      - name: orders
```

* Place in `yaml_files/` or alongside the relevant folder in `models/`.

---

## **4️⃣ Create your first model**

1. Create SQL file in the **staging layer**:

```
models/staging/stg_jaffle_shop_customers.sql
```

```sql
select *
from {{ source('jaffle_shop', 'customers') }}
```

2. Create corresponding YAML for the model:

```yaml
version: 2

models:
  - name: stg_jaffle_shop_customers
    description: "Staging table for customers"
    columns:
      - name: id
        description: "Customer ID"
      - name: first_name
        description: "Customer first name"
```

---

## **5️⃣ Optional docs and properties**

1. **Docs YAML** (`jaffle_shop_docs.yml`) for documentation:

```yaml
version: 2

docs:
  - name: customer_doc
    description: "Documentation about customers table"
```

2. **Properties YAML** (optional):

```yaml
tags:
  - layer: staging
owners:
  - team: analytics
```

* Place in `yaml_files/` or relevant model folder.

---

## **6️⃣ Run dbt commands**

1. **Compile models** (check SQL generation):

```bash
dbt compile
```

2. **Run models** (execute SQL in your warehouse):

```bash
dbt run
```

3. **Test models** (run built-in tests):

```bash
dbt test
```

4. **Generate docs site**:

```bash
dbt docs generate
dbt docs serve
```

5. **Optional snapshot** (if using snapshots):

```bash
dbt snapshot
```

---

## **7️⃣ Optional: Use seeds**

1. Place CSV in `seeds/`
2. Reference in SQL:

```sql
select *
from {{ ref('my_seed_file') }}
```

3. Run:

```bash
dbt seed
```

---

## **8️⃣ Best Practices Checklist**

* [ ] Use **layered model naming**: `stg_`, `int_`, `fct_`, `dim_`
* [ ] Keep YAMLs **one per source/system**: `sources.yml`, `models.yml`, `docs.yml`
* [ ] Use **single underscores** for filenames (`stg_jaffle_shop_customers.sql`)
* [ ] Keep **properties.yml optional** for metadata
* [ ] Use **dbt tests** (`unique`, `not_null`, `relationships`)
* [ ] Organize **folders logically by domain or layer**
* [ ] Version control all YAMLs and SQL files

---


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
