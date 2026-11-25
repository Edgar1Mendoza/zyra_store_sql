CREATE TABLE bags (
    id       SERIAL  PRIMARY KEY,
    name     TEXT    NOT NULL,
    price    NUMERIC NOT NULL,
    discount NUMERIC DEFAULT 0 NOT NULL,
    stock    INT     DEFAULT 0 NOT NULL
);

CREATE TABLE sales (
    id        SERIAL PRIMARY KEY,
    bag_id    INT    NOT NULL REFERENCES bags (id),
    sale_date DATE   DEFAULT CURRENT_DATE NOT NULL
);

INSERT INTO bags (name, price, discount, stock) VALUES
('Bag 1', 500, 0.1, 10),
('Bag 2', 20, 0.2, 20),
('Bag 3', 30, 0.3, 30);

UPDATE bags SET stock = 0 WHERE id = 1;

INSERT INTO bags (name, price, discount, stock)
SELECT 'Bag ' || i, (random() * 1000)::numeric, 0, (random() * 100)::int
FROM generate_series(1, 100000) AS i;


CREATE FUNCTION calculate_final_price(price NUMERIC, discount NUMERIC)
RETURNS NUMERIC AS $$
BEGIN
    RETURN price - (price - discount);
END;
$$ LANGUAGE plpgsql;

SELECT name, calculate_final_price(price, discount) AS final_price
FROM bags
WHERE id = 2;


CREATE OR REPLACE PROCEDURE process_sale(bag_id_param INT)
LANGUAGE plpgsql
AS $$
DECLARE
    current_stock INT;
BEGIN
    SELECT stock INTO current_stock FROM bags WHERE id = bag_id_param;

    IF current_stock <= 0 THEN
        RAISE EXCEPTION 'Bag % has no stock available', bag_id_param;
    END IF;

    INSERT INTO sales (bag_id) VALUES (bag_id_param);
    UPDATE bags SET stock = stock - 1 WHERE id = bag_id_param;
END;
$$;

CALL process_sale(1);

CREATE INDEX idx_bags_name ON bags (name);

#-- EXPLAIN ANALYZE SELECT * FROM bags WHERE name = 'Bag 50000';


CREATE OR REPLACE PROCEDURE process_sale_batch(bag_ids INT[])
LANGUAGE plpgsql
AS $$
DECLARE
    bag_id_param INT;
    current_stock INT;
BEGIN
    FOREACH bag_id_param IN ARRAY bag_ids LOOP
        BEGIN
            -- Check stock level
            SELECT stock INTO current_stock 
            FROM bags 
            WHERE id = bag_id_param;

            IF current_stock IS NULL OR current_stock <= 0 THEN
                RAISE EXCEPTION 'Bag % has no stock available', bag_id_param;
            END IF;

            -- Record sale and reduce inventory
            INSERT INTO sales (bag_id) VALUES (bag_id_param);
            UPDATE bags SET stock = stock - 1 WHERE id = bag_id_param;

        EXCEPTION WHEN OTHERS THEN
            -- Automatic rollback to savepoint happens here
            RAISE NOTICE 'Skipped bag %: %', bag_id_param, SQLERRM;
        END;
    END LOOP;
END;
$$;

CALL process_sale_batch(ARRAY[2,1]);
