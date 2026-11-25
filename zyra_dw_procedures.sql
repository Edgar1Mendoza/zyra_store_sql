CREATE OR REPLACE PROCEDURE dw.load_dim_product()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO dw.dim_product (product_id, name, category, price, sku)
    SELECT id, name, category, price, sku
    FROM staging.products
    ON CONFLICT (product_id) DO UPDATE
    SET name     = EXCLUDED.name,
        category = EXCLUDED.category,
        price    = EXCLUDED.price,
        sku      = EXCLUDED.sku
    WHERE dw.dim_product.name     IS DISTINCT FROM EXCLUDED.name
       OR dw.dim_product.category IS DISTINCT FROM EXCLUDED.category
       OR dw.dim_product.price    IS DISTINCT FROM EXCLUDED.price
       OR dw.dim_product.sku      IS DISTINCT FROM EXCLUDED.sku;
END;
$$;


CREATE OR REPLACE PROCEDURE dw.load_dim_customer()
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE dw.dim_customer dc
    SET valid_to   = CURRENT_DATE,
        is_current = FALSE
    FROM staging.customers s
    WHERE dc.customer_id = s.id
      AND dc.is_current = TRUE
      AND (
          dc.name  IS DISTINCT FROM s.name
          OR dc.email IS DISTINCT FROM s.email
          OR dc.city  IS DISTINCT FROM s.city
      );

    INSERT INTO dw.dim_customer (customer_id, name, email, city)
    SELECT s.id, s.name, s.email, s.city
    FROM staging.customers s
    LEFT JOIN dw.dim_customer dc
        ON dc.customer_id = s.id AND dc.is_current = TRUE
    WHERE dc.customer_key IS NULL;
END;
$$;


CREATE OR REPLACE PROCEDURE dw.load_dim_date()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO dw.dim_date (date_key, full_date, year, month, day, day_name, month_name)
    SELECT
        TO_CHAR(d, 'YYYYMMDD')::INT,
        d,
        EXTRACT(YEAR FROM d)::INT,
        EXTRACT(MONTH FROM d)::INT,
        EXTRACT(DAY FROM d)::INT,
        TO_CHAR(d, 'Day'),
        TO_CHAR(d, 'Month')
    FROM generate_series('2026-01-01'::DATE, '2026-12-31'::DATE, '1 day'::INTERVAL) AS d
    ON CONFLICT (date_key) DO NOTHING;
END;
$$;


CREATE OR REPLACE PROCEDURE dw.load_fact_sales()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO dw.fact_sales (
        order_item_id, 
        customer_key, 
        product_key, 
        date_key,
        order_id, 
        status, 
        quantity, 
        unit_price, 
        total_amount
    )
    SELECT
        oi.id,
        dc.customer_key,
        dp.product_key,
        dd.date_key,
        o.id,
        o.status,
        oi.quantity,
        oi.unit_price,
        oi.quantity * oi.unit_price
    FROM staging.order_items oi
    JOIN staging.orders o 
        ON oi.order_id = o.id
    JOIN dw.dim_customer dc 
        ON dc.customer_id = o.customer_id 
       AND dc.is_current = TRUE
    JOIN dw.dim_product dp 
        ON dp.product_id = oi.product_id
    JOIN dw.dim_date dd 
        ON dd.full_date = o.order_date
    ON CONFLICT (order_item_id) DO NOTHING;
END;
$$;


CREATE OR REPLACE PROCEDURE dw.validate_fact_sales()
LANGUAGE plpgsql
AS $$
DECLARE
    v_src INT;
    v_dst INT;
    v_missing TEXT;
BEGIN
    SELECT COUNT(*) INTO v_src FROM staging.order_items;
    SELECT COUNT(*) INTO v_dst FROM dw.fact_sales;
    IF v_src = v_dst THEN
        RAISE NOTICE 'validate_fact_sales loaded: % rows', v_dst;
    ELSE
        SELECT string_agg(oi.id::TEXT, ', ') INTO v_missing
        FROM staging.order_items AS oi
        JOIN staging.orders AS o
            ON oi.order_id = o.id
        LEFT JOIN dw.fact_sales AS f
            ON oi.id = f.order_item_id
        WHERE f.order_item_id IS NULL;
        RAISE EXCEPTION 'Count is not right. Staging: % & Fact: %. Missing items in row(s): %', v_src, v_dst, COALESCE(v_missing, 'Nothing');
    END IF;
END;
$$;


SELECT 
    oi.id AS order_item_id,
    oi.order_id,
    o.customer_id,
    oi.product_id,
    o.order_date
FROM staging.order_items AS oi
JOIN staging.orders AS o
    ON oi.order_id = o.id
LEFT JOIN dw.fact_sales AS f
    ON oi.id = f.order_item_id
WHERE f.order_item_id IS NULL;

SELECT 
    oi.order_id,
    o.id,
    oi.id,
    f.order_item_id
FROM staging.order_items AS oi
JOIN staging.orders AS o
    ON oi.order_id = o.id
LEFT JOIN dw.fact_sales AS f
    ON oi.id = f.order_item_id
WHERE f.order_item_id IS NULL;

SELECT STRING_AGG(oi.id::TEXT, ', ')
FROM staging.order_items AS oi
JOIN staging.orders AS o
    ON oi.order_id = o.id
LEFT JOIN dw.fact_sales AS f
    ON oi.id = f.order_item_id
WHERE f.order_item_id IS NULL;

DO $$
DECLARE
    v_missing TEXT;
BEGIN
    SELECT string_agg(oi.id::TEXT, ', ')
    INTO v_missing
    FROM staging.order_items oi
    JOIN staging.orders o ON oi.order_id = o.id
    LEFT JOIN dw.fact_sales f ON oi.id = f.order_item_id
    WHERE f.order_item_id IS NULL;

    RAISE NOTICE 'items missing in row(s): %', v_missing;
END;
$$;
