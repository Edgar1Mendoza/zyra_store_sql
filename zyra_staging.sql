-- Borra el staging anterior (solo este schema, no toca oltp)
DROP SCHEMA IF EXISTS staging CASCADE;
CREATE SCHEMA staging;

CREATE TABLE staging.customers (
    id          INT,
    name        TEXT,
    email       TEXT,
    city        TEXT,
    signup_date DATE,
    updated_at  TIMESTAMP,
    ingested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE staging.products (
    id          INT,
    name        TEXT,
    category    TEXT,
    price       NUMERIC,
    sku         TEXT,
    updated_at  TIMESTAMP,
    ingested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE staging.orders (
    id          INT,
    customer_id INT,
    order_date  DATE,
    status      TEXT,
    updated_at  TIMESTAMP,
    ingested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE staging.order_items (
    id          INT,
    order_id    INT,
    product_id  INT,
    quantity    INT,
    unit_price  NUMERIC,
    updated_at  TIMESTAMP,
    ingested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- La libreta: una fila por tabla, con la marca en la primera página
CREATE TABLE staging.etl_control (
    table_name      TEXT PRIMARY KEY,
    high_watermark  TIMESTAMP NOT NULL,
    last_run_status TEXT,
    last_run_at     TIMESTAMP
);

INSERT INTO staging.etl_control (table_name, high_watermark) VALUES
    ('customers',   '1900-01-01'),
    ('products',    '1900-01-01'),
    ('orders',      '1900-01-01'),
    ('order_items', '1900-01-01');
