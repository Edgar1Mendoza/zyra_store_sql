CREATE SCHEMA dw;

CREATE TABLE dw.dim_product (
    product_key INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id  INT NOT NULL UNIQUE,
    name        TEXT NOT NULL,
    category    TEXT,
    price       NUMERIC NOT NULL,
    sku         TEXT NOT NULL
);

CREATE TABLE dw.dim_customer (
    customer_key INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id  INT NOT NULL,
    name         TEXT NOT NULL,
    email        TEXT NOT NULL,
    city         TEXT,
    valid_from   DATE NOT NULL DEFAULT CURRENT_DATE,
    valid_to     DATE NOT NULL DEFAULT '9999-12-31',
    is_current   BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE dw.dim_date (
    date_key   INT PRIMARY KEY,
    full_date  DATE NOT NULL UNIQUE,
    year       INT NOT NULL,
    month      INT NOT NULL,
    day        INT NOT NULL,
    day_name   TEXT NOT NULL,
    month_name TEXT NOT NULL
);

CREATE TABLE dw.fact_sales (
    sale_key      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_item_id  INT     NOT NULL UNIQUE,
    customer_key  INT     NOT NULL REFERENCES dw.dim_customer (customer_key),
    product_key   INT     NOT NULL REFERENCES dw.dim_product (product_key),
    date_key      INT     NOT NULL REFERENCES dw.dim_date (date_key),
    order_id      INT     NOT NULL,
    status        TEXT    NOT NULL,
    quantity      INT     NOT NULL,
    unit_price    NUMERIC NOT NULL,
    total_amount  NUMERIC NOT NULL
);
