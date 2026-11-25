CREATE SCHEMA IF NOT EXISTS oltp;

CREATE TABLE oltp.customers (
    id          SERIAL PRIMARY KEY,
    name        TEXT      NOT NULL,
    email       TEXT      NOT NULL,
    city        TEXT,
    signup_date DATE      NOT NULL DEFAULT CURRENT_DATE,
    updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE oltp.products (
    id         SERIAL PRIMARY KEY,
    name       TEXT    NOT NULL,
    category   TEXT,
    price      NUMERIC NOT NULL,
    sku        TEXT    NOT NULL UNIQUE,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE oltp.orders (
    id          SERIAL PRIMARY KEY,
    customer_id INT      NOT NULL REFERENCES oltp.customers (id),
    order_date  DATE     NOT NULL DEFAULT CURRENT_DATE,
    status      TEXT     NOT NULL DEFAULT 'pending',
    updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE oltp.order_items (
    id         SERIAL PRIMARY KEY,
    order_id   INT     NOT NULL REFERENCES oltp.orders (id),
    product_id INT     NOT NULL REFERENCES oltp.products (id),
    quantity   INT     NOT NULL,
    unit_price NUMERIC NOT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Una sola función de trigger, reutilizada por las 4 tablas
CREATE OR REPLACE FUNCTION oltp.set_updated_at()
RETURNS trigger AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_customers_updated_at BEFORE UPDATE ON oltp.customers
    FOR EACH ROW EXECUTE FUNCTION oltp.set_updated_at();

CREATE TRIGGER trg_products_updated_at BEFORE UPDATE ON oltp.products
    FOR EACH ROW EXECUTE FUNCTION oltp.set_updated_at();

CREATE TRIGGER trg_orders_updated_at BEFORE UPDATE ON oltp.orders
    FOR EACH ROW EXECUTE FUNCTION oltp.set_updated_at();

CREATE TRIGGER trg_order_items_updated_at BEFORE UPDATE ON oltp.order_items
    FOR EACH ROW EXECUTE FUNCTION oltp.set_updated_at();

-- Datos
INSERT INTO oltp.customers (name, email, city) VALUES
    ('Ana Torres',   'ana@example.com',   'Monterrey'),
    ('Luis Ramirez', 'luis@example.com',  'CDMX'),
    ('Marta Gomez',  'marta@example.com', 'Guadalajara'),
    ('Jorge Diaz',   'jorge@example.com', 'Monterrey'),
    ('Sofia Lopez',  'sofia@example.com', 'CDMX');

INSERT INTO oltp.products (name, category, price, sku) VALUES
    ('Wireless Mouse',      'Electronics', 25.99, 'SKU-001'),
    ('Mechanical Keyboard', 'Electronics', 79.99, 'SKU-002'),
    ('USB-C Cable',         'Electronics',  9.99, 'SKU-003'),
    ('Yoga Mat',            'Sports',      19.99, 'SKU-004'),
    ('Water Bottle',        'Sports',      14.99, 'SKU-005'),
    ('Running Shoes',       'Sports',      89.99, 'SKU-006');

INSERT INTO oltp.orders (customer_id, order_date, status) VALUES
    (1, '2026-09-01', 'delivered'),
    (2, '2026-09-03', 'shipped'),
    (3, '2026-09-05', 'paid'),
    (1, '2026-09-10', 'pending'),
    (4, '2026-09-12', 'cancelled'),
    (5, '2026-09-15', 'delivered');

INSERT INTO oltp.order_items (order_id, product_id, quantity, unit_price) VALUES
    (1, 1, 2, 25.99),
    (1, 3, 1,  9.99),
    (2, 2, 1, 79.99),
    (3, 4, 1, 19.99),
    (3, 5, 2, 14.99),
    (4, 6, 1, 89.99),
    (5, 3, 3,  9.99),
    (6, 1, 1, 25.99),
    (6, 2, 1, 79.99);


SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema IN ('oltp', 'staging')
ORDER BY table_schema, table_name;
