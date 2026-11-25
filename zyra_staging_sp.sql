CREATE OR REPLACE PROCEDURE staging.sp_load_orders()
LANGUAGE plpgsql
AS $$
DECLARE
    v_watermark     TIMESTAMP;  -- last watermark stored in the control table
    v_new_watermark TIMESTAMP;  -- newest updated_at found in the source
    v_rows          INT;        -- number of rows loaded in this run
BEGIN
    -- 1. Read the current high watermark for this table
    SELECT high_watermark INTO v_watermark
    FROM staging.etl_control
    WHERE table_name = 'orders';

    -- 2. Empty staging: it must only hold the current batch
    TRUNCATE TABLE staging.orders;

    -- 3. Find the newest change in the source since the last watermark
    SELECT MAX(updated_at) INTO v_new_watermark
    FROM oltp.orders
    WHERE updated_at > v_watermark;

    -- 4. Nothing new: log the run and exit without moving the watermark
    IF v_new_watermark IS NULL THEN
        UPDATE staging.etl_control
        SET last_run_status = 'NO_CHANGES',
            last_run_at     = CURRENT_TIMESTAMP
        WHERE table_name = 'orders';

        RAISE NOTICE 'orders: no changes';
        RETURN;
    END IF;

    -- 5. Load only new or modified rows. The upper bound keeps the load
    --    consistent with the watermark even if the source changes meanwhile
    INSERT INTO staging.orders (id, customer_id, order_date, status, updated_at)
    SELECT id, customer_id, order_date, status, updated_at
    FROM oltp.orders
    WHERE updated_at >  v_watermark
      AND updated_at <= v_new_watermark;

    -- Capture how many rows the INSERT above affected
    GET DIAGNOSTICS v_rows = ROW_COUNT;

    -- 6. Move the watermark forward (last step, so a failure leaves it untouched)
    UPDATE staging.etl_control
    SET high_watermark  = v_new_watermark,
        last_run_status = 'SUCCESS',
        last_run_at     = CURRENT_TIMESTAMP
    WHERE table_name = 'orders';

    RAISE NOTICE 'orders: % rows loaded', v_rows;
END;
$$;

CALL staging.sp_load_orders();


CREATE OR REPLACE PROCEDURE staging.sp_load_customers()
LANGUAGE plpgsql
AS $$
DECLARE
    v_watermark TIMESTAMP;
    v_new_watermark TIMESTAMP;
    v_row_count INT;
BEGIN
    SELECT high_watermark INTO v_watermark
    FROM staging.etl_control
    WHERE table_name = 'customers';

    TRUNCATE TABLE staging.customers;

    SELECT MAX(updated_at) INTO v_new_watermark
    FROM oltp.customers
    WHERE updated_at > v_watermark;

    IF v_new_watermark IS NULL THEN
        UPDATE staging.etl_control
        SET last_run_status = 'NO CHANGES',
            last_run_at = CURRENT_TIMESTAMP
        WHERE table_name = 'customers';

        RAISE NOTICE 'customers: no changes';
        RETURN;
    END IF;

    INSERT INTO staging.customers (id, name, email, city, signup_date, updated_at)
    SELECT id, name, email, city, signup_date, updated_at
    FROM oltp.customers
    WHERE updated_at > v_watermark
    AND updated_at <= v_new_watermark;

    GET DIAGNOSTICS v_row_count = ROW_COUNT;

    UPDATE staging.etl_control
    SET high_watermark = v_new_watermark,
        last_run_status = 'SUCCESS',
        last_run_at = CURRENT_TIMESTAMP
    WHERE table_name = 'customers';

    RAISE NOTICE 'customers: % rows loaded', v_row_count;
END;
$$;

CALL staging.sp_load_customers();
SELECT * FROM staging.customers;


CREATE OR REPLACE PROCEDURE staging.sp_load_products()
LANGUAGE plpgsql
AS $$
DECLARE
    v_watermark TIMESTAMP;
    v_new_watermark TIMESTAMP;
    v_rows INT;
BEGIN
    SELECT high_watermark INTO v_watermark
    FROM staging.etl_control
    WHERE table_name = 'products';

    TRUNCATE TABLE staging.products;

    SELECT MAX(updated_at) INTO v_new_watermark
    FROM oltp.products
    WHERE updated_at > v_watermark;

    IF v_new_watermark IS NULL THEN
        UPDATE staging.etl_control SET
            last_run_status = 'NO CHANGES',
            last_run_at = CURRENT_TIMESTAMP
        WHERE table_name = 'products';

        RAISE NOTICE 'products: no changes';
        RETURN;
    END IF;

    INSERT INTO staging.products(id, name, category, price, sku, updated_at)
        SELECT id, name, category, price, sku, updated_at
        FROM oltp.products
        WHERE updated_at > v_watermark
        AND updated_at <= v_new_watermark;
    
    GET DIAGNOSTICS v_rows = ROW_COUNT;

    UPDATE staging.etl_control SET
        high_watermark = v_new_watermark,
        last_run_status = 'SUCESS',
        last_run_at = CURRENT_TIMESTAMP
    WHERE table_name = 'products';

    RAISE NOTICE 'products: % rows loaded', v_rows;
END;
$$;

CALL staging.sp_load_products();
SELECT * FROM staging.products;
