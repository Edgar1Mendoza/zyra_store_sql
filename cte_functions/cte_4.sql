CREATE TABLE IF NOT EXISTS pcte.stg_transactions_raw (
    transaction_id INT,
    customer_id INT,
    transaction_amount NUMERIC(10, 2),
    transaction_timestamp TIMESTAMP
);

INSERT INTO pcte.stg_transactions_raw (transaction_id, customer_id, transaction_amount, transaction_timestamp) VALUES 
(1, 101, 50.00, '2026-10-19 10:00:00'),
(2, 101, 50.00, '2026-10-19 10:05:00'),
(3, 102, 120.00, '2026-10-19 09:30:00'),
(4, 103, 45.50, '2026-10-19 11:15:00')
ON CONFLICT DO NOTHING;


WITH ranked_transactions AS (
    SELECT 
        transaction_id,
        customer_id,
        transaction_amount,
        transaction_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id 
            ORDER BY transaction_timestamp DESC
        ) AS row_num
    FROM pcte.stg_transactions_raw
)

SELECT 
    transaction_id,
    customer_id,
    transaction_amount,
    transaction_timestamp
FROM ranked_transactions
WHERE row_num = 1;
