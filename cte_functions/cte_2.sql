CREATE TABLE IF NOT EXISTS pcte.taxi_trips_raw (
    trip_id INT PRIMARY KEY,
    vendor_id VARCHAR(20),
    passenger_count INT,
    total_amount NUMERIC(10, 2)
);

INSERT INTO pcte.taxi_trips_raw (trip_id, vendor_id, passenger_count, total_amount) VALUES 
(1, 'VEND_A', 2, 25.00),
(2, 'VEND_B', 1, 10.00),
(3, 'VEND_A', 4, 45.00),
(4, 'VEND_C', 3, 15.00),
(5, 'VEND_B', 3, 65.00)
ON CONFLICT (trip_id) DO NOTHING;


WITH vendor_summary AS (
    SELECT 
        vendor_id,
        SUM(total_amount) AS total_vendor_revenue,
        COUNT(trip_id) AS total_trips
    FROM pcte.taxi_trips_raw
    GROUP BY vendor_id
),
top_vendors AS (
    SELECT vendor_id, total_vendor_revenue
    FROM vendor_summary
    WHERE total_vendor_revenue > 30.00
)
SELECT 
    t.trip_id,
    t.vendor_id,
    t.total_amount,
    tv.total_vendor_revenue
FROM pcte.taxi_trips_raw t
INNER JOIN top_vendors tv ON t.vendor_id = tv.vendor_id;
