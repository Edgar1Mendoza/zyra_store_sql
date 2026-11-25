CREATE SCHEMA IF NOT EXISTS dim;

-- SCD 1
CREATE TABLE IF NOT EXISTS dim.products (
    product_key INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id INT NOT NULL UNIQUE,
    name TEXT,
    category TEXT,
    price NUMERIC,
    sku TEXT,
    loaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- SCD 2
CREATE TABLE IF NOT EXISTS dim.customers (
    customer_key INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INT NOT NULL,
    name TEXT,
    email TEXT,
    city TEXT,
    signup_date DATE,
    valid_from DATE NOT NULL,
    valid_to DATE NOT NULL DEFAULT '9999-12-31',
    is_current BOOLEAN NOT NULL DEFAULT TRUE
);
CREATE UNIQUE INDEX IF NOT EXISTS uq_dim_customers_current
ON dim.customers (customer_id) WHERE is_current;

INSERT INTO dim.customers (customer_id, name, email, city, signup_date, valid_from)
SELECT id, name, email, city, signup_date, DATE '1900-01-01'
FROM silver.customers;


CREATE OR REPLACE PROCEDURE dim.sp_load_dim_products()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows INT;
BEGIN
    INSERT INTO dim.products (product_id, name, category, price, sku)
    SELECT id, name, category, price, sku
    FROM silver.products
    ON CONFLICT (product_id) DO UPDATE SET
        name      = EXCLUDED.name,
        category  = EXCLUDED.category,
        price     = EXCLUDED.price,
        sku       = EXCLUDED.sku,
        loaded_at = CURRENT_TIMESTAMP
    WHERE dim.products.name IS DISTINCT FROM EXCLUDED.name
        OR dim.products.category IS DISTINCT FROM EXCLUDED.category
        OR dim.products.price IS DISTINCT FROM EXCLUDED.price
        OR dim.products.sku IS DISTINCT FROM EXCLUDED.sku;

    GET DIAGNOSTICS v_rows = ROW_COUNT;
    RAISE NOTICE 'Inserted or updated % rows', v_rows;
END;
$$;

CALL dim.sp_load_dim_products();
SELECT * FROM dim.products;

UPDATE oltp.products SET price = 100.99 WHERE id = 1;
CALL staging.sp_load_products(); 
CALL silver.sp_load_products();
CALL dim.sp_load_dim_products();
SELECT * FROM dim.products;
