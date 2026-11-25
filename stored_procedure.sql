-- 1. Crear la tabla de staging con transacciones del día
CREATE TABLE IF NOT EXISTS stg_daily_transactions (
    txn_id INT PRIMARY KEY,
    store_id INT,
    txn_amount NUMERIC(10, 2),
    txn_status VARCHAR(20)
);

-- 2. Crear la tabla de resumen histórico
CREATE TABLE IF NOT EXISTS fact_daily_summary (
    summary_id SERIAL PRIMARY KEY,
    store_id INT,
    total_transactions INT,
    total_revenue NUMERIC(10, 2),
    processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Insertar datos de prueba en Staging
INSERT INTO stg_daily_transactions (txn_id, store_id, txn_amount, txn_status) VALUES 
(1, 10, 150.00, 'SUCCESS'),
(2, 10, 250.00, 'SUCCESS'),
(3, 20, 500.00, 'SUCCESS'),
(4, 10, 100.00, 'FAILED')
ON CONFLICT (txn_id) DO NOTHING;


CREATE OR REPLACE PROCEDURE sp_process_store_batch(
    IN p_store_id INT,
    OUT p_total_rows INT,
    OUT p_total_revenue NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO fact_daily_summary(store_id, total_transactions, total_revenue)
    SELECT
        store_id,
        COUNT(txn_id) AS total_transactions,
        SUM(txn_amount) AS total_revenue
    FROM stg_daily_transactions
    WHERE store_id = p_store_id AND txn_status = 'SUCCESS'
    GROUP BY store_id;

    SELECT
        COALESCE(COUNT(txn_id), 0),
        COALESCE(SUM(txn_amount), 0.00)
    INTO p_total_rows, p_total_revenue
    FROM stg_daily_transactions
    WHERE store_id = p_store_id AND txn_status = 'SUCCESS';

    COMMIT;
END;
$$;

DO $$
DECLARE
    v_rows INT;
    v_revenue NUMERIC;
BEGIN
    CALL sp_process_store_batch(10, v_rows, v_revenue);
    RAISE NOTICE 'Rows: %, Revenue: %', v_rows, v_revenue;
END $$;
