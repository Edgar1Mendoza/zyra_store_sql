CREATE SCHEMA IF NOT EXISTS silver;

CREATE TABLE IF NOT EXISTS silver.orders (
    id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    status TEXT NOT NULL,
    source_updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    first_loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS silver.customers (
    id INT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    city TEXT NOT NULL,
    signup_date  DATE NOT NULL,
    source_updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    first_loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS silver.products (
    id INT PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    price NUMERIC NOT NULL,
    sku TEXT NOT NULL,
    source_updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    first_loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


CREATE OR REPLACE PROCEDURE silver.sp_load_orders()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows INT;
BEGIN
    INSERT INTO silver.orders(id, customer_id, order_date, status, source_updated_at)
        SELECT id, customer_id, order_date, status, updated_at
        FROM staging.orders
        ON CONFLICT (id) DO UPDATE SET
            customer_id       = EXCLUDED.customer_id,
            order_date        = EXCLUDED.order_date,
            status            = EXCLUDED.status,
            source_updated_at = EXCLUDED.source_updated_at,
            last_loaded_at    = CURRENT_TIMESTAMP
        WHERE silver.orders.source_updated_at < EXCLUDED.source_updated_at;

    GET DIAGNOSTICS v_rows = ROW_COUNT;
    RAISE NOTICE 'Inserted % row(s)', v_rows;
END;
$$;

CALL silver.sp_load_orders();
SELECT * FROM silver.orders;


CREATE OR REPLACE PROCEDURE silver.sp_load_customers()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows INT;
BEGIN
    INSERT INTO silver.customers (id, name, email, city, signup_date, source_updated_at)
        SELECT id, name, email, city, signup_date, updated_at
        FROM staging.customers
        ON CONFLICT (id) DO UPDATE SET
            name              = EXCLUDED.name,
            email             = EXCLUDED.email,
            city              = EXCLUDED.city,
            signup_date       = EXCLUDED.signup_date,
            source_updated_at = EXCLUDED.source_updated_at,
            last_loaded_at    = CURRENT_TIMESTAMP
        WHERE silver.customers.source_updated_at < EXCLUDED.source_updated_at;
        
    GET DIAGNOSTICS v_rows = ROW_COUNT;
    RAISE NOTICE 'Inserted % row(s)', v_rows;
END;
$$;

CALL silver.sp_load_customers();
SELECT * FROM silver.customers;


CREATE OR REPLACE PROCEDURE silver.sp_load_products()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows INT;
BEGIN
    INSERT INTO silver.products (id, name, category, price, sku, source_updated_at)
        SELECT id, name, category, price, sku, updated_at
        FROM staging.products
        ON CONFLICT (id) DO UPDATE SET
            name              = EXCLUDED.name,
            category          = EXCLUDED.category,
            price             = EXCLUDED.price,
            sku               = EXCLUDED.sku,
            source_updated_at = EXCLUDED.source_updated_at
        WHERE silver.products.source_updated_at < EXCLUDED.source_updated_at;

    GET DIAGNOSTICS v_rows = ROW_COUNT;
    RAISE NOTICE 'Inserted % row(s)', v_rows;
END;
$$;

CALL silver.sp_load_products();
SELECT * FROM silver.products;
