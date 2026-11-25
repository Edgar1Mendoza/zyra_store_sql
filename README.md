# Zyra Store SQL Exercises

This repository contains PostgreSQL scripts for practicing store data modeling,
PL/pgSQL procedures, incremental staging loads, data cleaning, and dimensional
warehousing. It is a collection of SQL exercises, not an application or a
single migration-managed project.

## Requirements

- PostgreSQL 11 or later (the scripts use procedures and PL/pgSQL)
- `psql` for the command-line examples below

## Main Zyra warehouse flow

Run the core scripts in order against a **disposable database**:

```sh
createdb zyra_store
psql -d zyra_store -v ON_ERROR_STOP=1 -f zyra_store_oltp.sql
psql -d zyra_store -v ON_ERROR_STOP=1 -f zyra_staging.sql
psql -d zyra_store -v ON_ERROR_STOP=1 -f zyra_staging_sp.sql
psql -d zyra_store -v ON_ERROR_STOP=1 -f zyra_dw_schemas.sql
psql -d zyra_store -v ON_ERROR_STOP=1 -f zyra_dw_procedures.sql
psql -d zyra_store -v ON_ERROR_STOP=1 -f zyra_dw_orchestration.sql
```

The orchestration procedure is defined but its call is commented out in the
script. After loading the source data into staging, run it with:

```sh
psql -d zyra_store -v ON_ERROR_STOP=1 -c "CALL dw.load_all();"
```

**Important:** `zyra_staging.sql` drops and recreates the `staging` schema,
cascading to objects in that schema. The staging procedures currently load
customers, products, and orders, but do not load `staging.order_items`; populate
that table before expecting sales rows in the fact table. The fact validation
can pass when both staging and the fact table are empty.

These scripts include seed data and are not all safe to rerun. Start with a
fresh database rather than running them against data you need to keep.

## Script guide

| File | Purpose |
| --- | --- |
| `zyra_store_oltp.sql` | Creates the `oltp` schema, store tables, update triggers, and sample data. |
| `zyra_staging.sql` | Recreates the `staging` schema and defines staging tables and ETL watermarks. |
| `zyra_staging_sp.sql` | Defines and calls incremental loaders for orders, customers, and products. |
| `zyra_silver_sp.sql` | Creates the `silver` tables and upsert procedures; expects staging data. |
| `zyra_clean.sql` | Demonstrates order validation and rejected-row capture; expects staging orders and the `silver` schema. |
| `zyra_dw_schemas.sql` | Creates the `dw` dimensions and sales fact table. |
| `zyra_dw_procedures.sql` | Defines warehouse dimension/fact loaders and validation queries. |
| `zyra_dw_orchestration.sql` | Defines `dw.load_all()` to run the warehouse loaders in sequence. |
| `zyra_dw_queries.sql` | Example customer and product sales-ranking queries. The final query's `ORDER BY` references an alias that is not in scope and needs correction before running. |
| `zyra_dim_sp.sql` | Separate `dim` schema example for product upserts and customer dimensions; expects `silver` and other pipeline schemas/data. |
| `bag_store.sql` | Standalone inventory and sales procedure exercise; inserts 100,000 generated bag rows. |
| `stored_procedure.sql` | Standalone daily transaction summary procedure exercise. |

## Running an individual example

Use a separate empty database for standalone examples, such as:

```sh
createdb bag_store_demo
psql -d bag_store_demo -v ON_ERROR_STOP=1 -f bag_store.sql
```

Review a script before running it: some contain destructive DDL, large sample
inserts, or statements that assume earlier scripts have already created their
schemas and tables.
