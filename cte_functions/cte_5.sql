CREATE TABLE IF NOT EXISTS pcte.product_sales (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category_name VARCHAR(50),
    total_revenue NUMERIC(10, 2)
);

INSERT INTO pcte.product_sales (product_id, product_name, category_name, total_revenue) VALUES 
(1, 'Laptop Pro', 'Electronics', 1500.00),
(2, 'Smart TV', 'Electronics', 1200.00),
(3, 'Wireless Mouse', 'Electronics', 1200.00),
(4, 'Running Shoes', 'Sports', 800.00),
(5, 'Yoga Mat', 'Sports', 300.00)
ON CONFLICT (product_id) DO NOTHING;


SELECT 
    product_name,
    category_name,
    total_revenue,
    RANK() OVER (
        PARTITION BY category_name 
        ORDER BY total_revenue DESC
    ) AS sales_rank,
    DENSE_RANK() OVER (
        PARTITION BY category_name 
        ORDER BY total_revenue DESC
    ) AS sales_dense_rank
FROM pcte.product_sales;
