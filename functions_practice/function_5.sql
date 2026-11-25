CREATE TABLE pf.trips (
    trip_id INT PRIMARY KEY,
    vendor_id VARCHAR(50),
    trip_distance NUMERIC(10, 2),
    total_amount NUMERIC(10, 2),
    payment_type VARCHAR(50)
);

INSERT INTO pf.trips (trip_id, vendor_id, trip_distance, total_amount, payment_type) VALUES
(101, 'VEND_A', 12.5, 45.00, 'CREDIT'),
(102, NULL, -2.0, 15.50, 'CASH'),
(103, 'VEND_B', NULL, -5.00, NULL),
(104, 'VEND_C', 5.0, 22.10, 'DEBIT');


-- Function to clean and transform trip data
CREATE OR REPLACE FUNCTION pf.clean_and_transform_trip(
    p_trip_id INT,
    p_vendor_id VARCHAR,
    p_distance NUMERIC,
    p_amount NUMERIC,
    p_payment VARCHAR
)
RETURNS TABLE (
    out_trip_id INT,
    out_vendor_id VARCHAR,
    out_trip_distance NUMERIC,
    out_total_amount NUMERIC,
    out_payment_type VARCHAR,
    out_is_valid BOOLEAN
) AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        p_trip_id,
        COALESCE(p_vendor_id, 'UNKNOWN') AS out_vendor_id,
        CASE WHEN p_distance IS NULL OR p_distance < 0 THEN 0.0 ELSE p_distance END AS out_trip_distance,
        CASE WHEN p_amount IS NULL OR p_amount < 0 THEN 0.0 ELSE p_amount END AS out_total_amount,
        COALESCE(p_payment, 'NOT_SPECIFIED') AS out_payment_type,
        CASE 
            WHEN p_distance >= 0 AND p_amount >= 0 AND p_distance IS NOT NULL THEN TRUE
            ELSE FALSE
        END AS out_is_valid;
END;
$$ LANGUAGE plpgsql IMMUTABLE;


SELECT t.*
FROM pf.trips AS stt,
LATERAL pf.clean_and_transform_trip(
    stt.trip_id,
    stt.vendor_id,
    stt.trip_distance,
    stt.total_amount,
    stt.payment_type
) t;
