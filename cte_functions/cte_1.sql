CREATE SCHEMA pcte; -- Practice CTE Functions


CREATE TABLE IF NOT EXISTS pcte.customer_orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_amount NUMERIC(10, 2)
);

INSERT INTO pcte.customer_orders (order_id, customer_id, order_amount) VALUES 
(1, 101, 150.00),
(2, 102, 450.00),
(3, 103, 80.00),
(4, 101, 320.00),
(5, 104, 600.00)
ON CONFLICT (order_id) DO NOTHING;


WITH average_company_sales AS (
    SELECT AVG(order_amount) AS overall_avg_amount
    FROM pcte.customer_orders
)

SELECT 
    o.customer_id,
    SUM(o.order_amount) AS total_customer_spent,
    ROUND(a.overall_avg_amount, 2) AS overall_average
FROM pcte.customer_orders AS o
CROSS JOIN average_company_sales AS a
GROUP BY o.customer_id, a.overall_avg_amount
HAVING SUM(o.order_amount) > a.overall_avg_amount;
