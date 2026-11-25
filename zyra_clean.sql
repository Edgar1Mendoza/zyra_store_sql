INSERT INTO staging.orders (id, customer_id, order_date, status, updated_at) VALUES
 (10, 1,    '2026-10-28', 'delivered', now()),
 (11, 2,    '2026-10-28', ' Paid ',    now()),
 (12, NULL, '2026-10-28', 'pending',   now()),
 (13, 3,    '2027-05-01', 'shipped',   now()),
 (14, 4,    '2026-10-28', 'entregado', now());

CREATE TABLE IF NOT EXISTS silver.orders_rejected (
    reject_id         INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id                INT,
    customer_id       INT,
    order_date        DATE,
    status            TEXT,
    source_updated_at TIMESTAMP,
    reject_reason     TEXT NOT NULL,
    rejected_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


SELECT
    id,
    customer_id,
    order_date,
    lower(trim(status)) AS status,
    CASE
        WHEN id IS NULL THEN 'id_null'
        WHEN customer_id IS NULL THEN 'customer_id_null'
        WHEN order_date IS NULL OR order_date > CURRENT_DATE THEN 'invalid_order_date'
        WHEN status IS NULL OR lower(trim(status)) NOT IN
            ('delivered', 'paid', 'pending', 'shipped', 'cancelled') THEN 'invalid_status'
    END AS reject_reason
FROM staging.orders;


--------------------------------------TEMP TABLE--------------------------------------
CREATE TEMP TABLE tmp_orders_classified AS
SELECT
    id,
    customer_id,
    order_date,
    status AS raw_status,
    lower(trim(status)) AS clean_status,
    updated_at,
    CASE
        WHEN id IS NULL THEN 'null_id'
        WHEN customer_id IS NULL THEN 'null_customer_id'
        WHEN order_date IS NULL OR order_date > CURRENT_DATE THEN 'invalid_order_date'
        WHEN status IS NULL OR lower(trim(status)) NOT IN
            ('delivered', 'paid', 'pending', 'shipped', 'cancelled') THEN 'invalid_status'
    END AS reject_reason
FROM staging.orders;

SELECT id, clean_status, reject_reason
FROM tmp_orders_classified
ORDER BY id;


-------------------------------------IDEPENDENT INSERT--------------------------------------
-- Índice único funcional: Evita duplicados exactos en la DLQ, manejando IDs nulos de forma segura con COALESCE
CREATE UNIQUE INDEX IF NOT EXISTS uq_orders_rejected
ON silver.orders_rejected (COALESCE(id, -1), source_updated_at, reject_reason);

INSERT INTO silver.orders_rejected
    (id, customer_id, order_date, status, source_updated_at, reject_reason)
SELECT id, customer_id, order_date, raw_status, updated_at, reject_reason
FROM tmp_orders_classified
WHERE reject_reason IS NOT NULL;
SELECT * FROM silver.orders_rejected;

INSERT INTO staging.orders (id, customer_id, order_date, status, updated_at) VALUES
 (NULL, 1, '2026-10-28', 'shipped', now()),
 (NULL, 2, '2026-10-28', 'delivered', now()),
 (NULL, 3, '2026-10-27', 'delivered', now());
