CREATE TABLE IF NOT EXISTS pcte.customer_lifetime_value (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    total_spent NUMERIC(10, 2)
);

INSERT INTO pcte.customer_lifetime_value (customer_id, customer_name, total_spent) VALUES 
(1, 'Alice Smith', 1200.00),
(2, 'Bob Jones', 950.00),
(3, 'Charlie Brown', 800.00),
(4, 'Diana Prince', 600.00),
(5, 'Ethan Hunt', 400.00),
(6, 'Fiona Glenanne', 150.00)
ON CONFLICT (customer_id) DO NOTHING;


SELECT 
    customer_id,
    customer_name,
    total_spent,
    NTILE(4) OVER (
        ORDER BY total_spent DESC
    ) AS spending_quartile,
    CASE 
        WHEN NTILE(4) OVER (ORDER BY total_spent DESC) = 1 THEN 'VIP_TIER'
        WHEN NTILE(4) OVER (ORDER BY total_spent DESC) = 2 THEN 'GOLD_TIER'
        WHEN NTILE(4) OVER (ORDER BY total_spent DESC) = 3 THEN 'SILVER_TIER'
        ELSE 'BRONZE_TIER'
    END AS customer_tier
FROM pcte.customer_lifetime_value;
