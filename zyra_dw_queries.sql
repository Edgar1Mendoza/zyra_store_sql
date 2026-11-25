SELECT
    fs.customer_key,
    c.name,
    SUM(fs.total_amount) AS total_sales,
    RANK() OVER (ORDER BY SUM(fs.total_amount)DESC) as spending_rank
FROM dw.fact_sales AS fs
LEFT JOIN dw.dim_customer AS c
    ON fs.customer_key = c.customer_key
GROUP BY fs.customer_key, c.name
ORDER BY spending_rank;


WITH customer_spending AS (
    SELECT
        fs.customer_key,
        c.name,
        SUM(fs.total_amount) AS total_sales,
        RANK() OVER (ORDER BY SUM(fs.total_amount)DESC) as spending_rank
    FROM dw.fact_sales AS fs
    LEFT JOIN dw.dim_customer AS c
        ON fs.customer_key = c.customer_key
    GROUP BY fs.customer_key, c.name
)
SELECT
    *
FROM customer_spending
WHERE spending_rank <= 3
ORDER BY spending_rank;


WITH category_rank AS (
    SELECT
        p.name,
        p.category,
        SUM(fs.total_amount) AS total_sales,
        RANK() OVER (PARTITION BY p.category ORDER BY SUM(fs.total_amount)DESC) as rank_in_category
    FROM dw.fact_sales AS fs
    LEFT JOIN dw.dim_product AS p
        ON fs.product_key = p.product_key
    GROUP BY p.name, p.category
)
SELECT * FROM category_rank
WHERE rank_in_category <= 2
ORDER BY p.category, total_sales DESC;
