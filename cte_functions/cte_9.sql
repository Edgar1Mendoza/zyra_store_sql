CREATE TABLE IF NOT EXISTS pcte.customer_purchases (
    purchase_id INT PRIMARY KEY,
    customer_id INT,
    purchase_amount NUMERIC(10, 2),
    purchase_timestamp TIMESTAMP
);

INSERT INTO pcte.customer_purchases (purchase_id, customer_id, purchase_amount, purchase_timestamp) VALUES 
(1, 101, 100.00, '2026-10-01 10:00:00'),
(2, 101, 250.00, '2026-10-05 14:30:00'),
(3, 101, 400.00, '2026-10-10 09:15:00'),
(4, 102, 50.00,  '2026-10-02 11:00:00'),
(5, 102, 150.00, '2026-10-08 16:45:00')
ON CONFLICT (purchase_id) DO NOTHING;


SELECT 
    customer_id,
    purchase_id,
    purchase_timestamp,
    purchase_amount,
    FIRST_VALUE(purchase_amount) OVER (
        PARTITION BY customer_id 
        ORDER BY purchase_timestamp ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS first_purchase_amount,
    LAST_VALUE(purchase_amount) OVER (
        PARTITION BY customer_id 
        ORDER BY purchase_timestamp ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_purchase_amount
FROM pcte.customer_purchases;
