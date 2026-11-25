CREATE TABLE IF NOT EXISTS pf.shipments (
    shipment_id INT PRIMARY KEY,
    package_weight NUMERIC(6, 2),
    shipping_distance NUMERIC(6, 2),
    base_rate NUMERIC(4, 2)
);

INSERT INTO pf.shipments (shipment_id, package_weight, shipping_distance, base_rate) VALUES  
(1, 2.5, 45, 0.00),
(2, 12.0, 350, 0.00),
(3, 25.5, 1200, 0.00)
ON CONFLICT (shipment_id) DO NOTHING;


-- Function to calculate the shipping rate
CREATE OR REPLACE FUNCTION pf.calculate_shipping_rate(p_weight NUMERIC, p_distance NUMERIC)
RETURNS NUMERIC AS $$
DECLARE
    v_rate NUMERIC(10, 2);
BEGIN
    IF p_weight <= 5.0 AND p_distance <= 100 THEN
        v_rate := 15.00;
    ELSIF p_weight <= 15.0 AND p_distance <= 500 THEN
        v_rate := 45.00;
    ELSIF p_weight > 15.0 OR p_distance > 500 THEN
        v_rate := 95.00;
    ELSE
        v_rate := 120.00;
    END IF;

    RETURN v_rate;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

SELECT 
    shipment_id,
    package_weight,
    shipping_distance,
    pf.calculate_shipping_rate(package_weight, shipping_distance) AS calculated_shipping_rate
FROM pf.shipments;
