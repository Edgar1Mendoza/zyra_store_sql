CREATE TABLE IF NOT EXISTS pcte.order_distribution (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_amount NUMERIC(10, 2)
);

INSERT INTO pcte.order_distribution (order_id, customer_id, order_amount) VALUES 
(1, 101, 50.00),
(2, 102, 100.00),
(3, 103, 100.00),
(4, 104, 250.00),
(5, 105, 500.00)
ON CONFLICT (order_id) DO NOTHING;


SELECT 
    order_id,
    customer_id,
    order_amount,
    CUME_DIST() OVER (
        ORDER BY order_amount ASC
    ) AS cumulative_distribution,
    PERCENT_RANK() OVER (
        ORDER BY order_amount ASC
    ) AS percentage_rank
FROM pcte.order_distribution;
