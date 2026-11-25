CREATE TABLE IF NOT EXISTS pcte.daily_sales (
    sale_id INT PRIMARY KEY,
    sale_date DATE,
    sale_amount NUMERIC(10, 2)
);

INSERT INTO pcte.daily_sales (sale_id, sale_date, sale_amount) VALUES 
(1, '2026-10-01', 100.00),
(2, '2026-10-02', 250.00),
(3, '2026-10-03', 150.00),
(4, '2026-10-04', 500.00)
ON CONFLICT (sale_id) DO NOTHING;


SELECT 
    sale_id,
    sale_date,
    sale_amount,
    SUM(sale_amount) OVER (
        ORDER BY sale_date ASC 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_revenue,
    AVG(sale_amount) OVER (
        ORDER BY sale_date ASC 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS moving_average_revenue
FROM pcte.daily_sales;
