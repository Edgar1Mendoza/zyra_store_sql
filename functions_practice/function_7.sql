CREATE TABLE orders (
    order_id      INT PRIMARY KEY,
    customer_id   INT,
    order_date    DATE,
    status        VARCHAR(20),
    shipping_fee  DECIMAL(10,2),
    total_amount  DECIMAL(10,2)   -- item_total + shipping_fee
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id      INT,
    product_id    INT,
    product_name  VARCHAR(50),
    quantity      INT,
    unit_price    DECIMAL(10,2)
);

INSERT INTO orders VALUES
(1001, 10, '2026-10-01', 'delivered', 10.00, 260.00),
(1002, 10, '2026-10-05', 'delivered', 10.00,  55.00),
(1003, 20, '2026-10-07', 'delivered', 10.00,  85.00),
(1004, 30, '2026-10-09', 'cancelled', 10.00,  90.00),
(1005, 20, '2026-10-12', 'shipped',    0.00, 300.00);

INSERT INTO order_items VALUES
(1, 1001, 1, 'Teclado',    1,  50.00),
(2, 1001, 2, 'Mouse',      2,  25.00),
(3, 1001, 3, 'Monitor',    1, 150.00),
(4, 1002, 4, 'Cable HDMI', 3,  15.00),
(5, 1003, 2, 'Mouse',      1,  25.00),
(6, 1003, 1, 'Teclado',    1,  50.00),
(7, 1004, 5, 'Webcam',     1,  80.00),
(8, 1005, 3, 'Monitor',    2, 150.00);

SELECT * FROM orders;
SELECT * FROM order_items;

INSERT INTO orders VALUES
(1006, 40, '2026-10-12', 'shipped',    0.00, 100.00);

INSERT INTO order_items VALUES
(9, 1006, 3, 'Monitor',    2, 50.00);


-- VIEW
CREATE VIEW order_item_summary AS
SELECT
    order_id,
    SUM(quantity) AS total_items
FROM order_items
GROUP BY order_id;

SELECT
    o.customer_id,
    SUM(o.total_amount) AS total_amount,
    SUM(oi.total_items) AS total_items
FROM orders AS o
JOIN order_item_summary AS oi
    ON o.order_id = oi.order_id
WHERE status <> 'cancelled'
GROUP BY o.customer_id;


-- TEMPORARY TABLE
DROP TABLE IF EXISTS temp_total_quantity_per_order;

CREATE TEMP TABLE temp_total_quantity_per_order AS
SELECT
    order_id,
    SUM(quantity) AS total_items
FROM order_items
GROUP BY order_id;

SELECT
    o.customer_id,
    SUM(o.total_amount) AS total_amount,
    SUM(oi.total_items) AS total_items
FROM orders AS o
JOIN temp_total_quantity_per_order AS oi
    ON o.order_id = oi.order_id
WHERE status <> 'cancelled'
GROUP BY o.customer_id;


-- SUBQUERY
SELECT
    o.customer_id,
    SUM(o.total_amount) AS total_amount,
    SUM(oi.total_items) AS total_items
FROM orders AS o
JOIN (SELECT
    order_id,
    SUM(quantity) AS total_items
FROM order_items
GROUP BY order_id) AS oi
    ON o.order_id = oi.order_id
WHERE status <> 'cancelled'
GROUP BY o.customer_id
HAVING SUM(oi.total_quantity) > 3;


-- CTE
WITH order_item_summary AS (
    SELECT
        order_id,
        SUM(quantity) AS total_quantity
    FROM order_items
    GROUP BY order_id
)
SELECT
    o.customer_id,
    SUM(o.total_amount) AS total_amount,
    SUM(oi.total_quantity) AS total_items
FROM orders AS o
JOIN order_item_summary AS oi
    ON o.order_id = oi.order_id
WHERE status <> 'cancelled'
GROUP BY o.customer_id
HAVING SUM(oi.total_quantity) > 3
;
