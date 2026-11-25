CREATE TABLE pf.customers (
    id   INT PRIMARY KEY,
    name TEXT NOT NULL
);

INSERT INTO pf.customers (id, name) VALUES
    (1, 'Ana'),
    (2, 'Luis'),
    (3, 'Marta');

CREATE TABLE pf.orders (
    id          INT PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES pf.customers(id),
    amount      NUMERIC,
    order_date  DATE
);

INSERT INTO pf.orders (id, customer_id, amount, order_date) VALUES
    (1, 1, 100, '2026-09-01'),
    (2, 1,  50, '2026-09-10'),
    (3, 2, 200, '2026-09-05'),
    (4, 1, 100, '2026-09-20'),
    (5, 2, 120, '2026-09-06');


WITH ranking AS (
    SELECT
        o.id AS customer_id,
        c.name AS customer_name,
        o.amount,
        DENSE_RANK() OVER (ORDER BY o.amount DESC NULLS LAST) AS rnk
    FROM pf.customers AS c
    LEFT JOIN pf.orders AS o
        ON c.id = o.customer_id
)
SELECT DISTINCT amount
FROM ranking
WHERE rnk = 2;


WITH ranking AS (
    SELECT
        o.id AS customer_id,
        c.name AS customer_name,
        o.amount,
        DENSE_RANK() OVER (PARTITION BY c.id ORDER BY o.amount DESC NULLS LAST) AS rnk
    FROM pf.customers AS c
    JOIN pf.orders AS o
        ON c.id = o.customer_id
)
SELECT DISTINCT
    customer_name,
    amount
FROM ranking
WHERE rnk = 2;


-- Compare global average with individual average
WITH total_amount AS (
    SELECT
        SUM(amount) AS total_spent,
        COUNT(amount) AS total_orders
    FROM pf.customers AS c
    LEFT JOIN pf.orders AS o
        ON c.id = o.customer_id
),
total_avg AS (
    SELECT total_spent / total_orders AS avg_spent
    FROM total_amount
),
customer_sum AS (
    SELECT
        c.name AS customer_name,
        AVG(o.amount) AS individual_sum
    FROM pf.customers AS c
    LEFT JOIN pf.orders AS o
        ON c.id = o.customer_id
    GROUP BY c.id, c.name
)
SELECT *
FROM customer_sum AS c
CROSS JOIN total_avg AS t
WHERE t.avg_spent < c.individual_sum;
-- Optimized version query:
SELECT 
    c.name AS customer_name,
    AVG(o.amount) AS individual_avg
FROM pf.customers AS c
JOIN pf.orders AS o 
    ON c.id = o.customer_id
GROUP BY c.id, c.name
HAVING AVG(o.amount) > (
    SELECT AVG(amount) 
    FROM pf.orders
);


-- Compare global average with total spent per customer
WITH total_amount AS (
    SELECT
        SUM(amount) AS total_spent,
        COUNT(amount) AS total_orders
    FROM pf.customers AS c
    LEFT JOIN pf.orders AS o
        ON c.id = o.customer_id
),
total_avg AS (
    SELECT total_spent / total_orders AS avg_spent
    FROM total_amount
),
customer_sum AS (
    SELECT
        c.name AS customer_name,
        SUM(o.amount) AS individual_sum
    FROM pf.customers AS c
    LEFT JOIN pf.orders AS o
        ON c.id = o.customer_id
    GROUP BY c.id, c.name
)
SELECT *
FROM customer_sum AS c
CROSS JOIN total_avg AS t
WHERE t.avg_spent < c.individual_sum;


SELECT 
    c.name AS customer,
    o.amount,
    ROUND((o.amount / SUM(o.amount) OVER (PARTITION BY c.id)) * 100, 2) AS pct_of_customer
FROM pf.customers AS c
JOIN pf.orders AS o 
    ON c.id = o.customer_id;
