CREATE TABLE IF NOT EXISTS pcte.driver_trips (
    trip_id INT PRIMARY KEY,
    driver_id INT,
    trip_amount NUMERIC(10, 2),
    trip_timestamp TIMESTAMP
);

INSERT INTO pcte.driver_trips (trip_id, driver_id, trip_amount, trip_timestamp) VALUES 
(1, 501, 20.00, '2026-10-19 08:00:00'),
(2, 501, 35.00, '2026-10-19 09:30:00'),
(3, 501, 30.00, '2026-10-19 11:00:00'),
(4, 502, 50.00, '2026-10-19 08:30:00'),
(5, 502, 40.00, '2026-10-19 10:00:00')
ON CONFLICT (trip_id) DO NOTHING;


SELECT 
    driver_id,
    trip_id,
    trip_timestamp,
    trip_amount,
    LAG(trip_amount, 1, 0.00) OVER (
        PARTITION BY driver_id 
        ORDER BY trip_timestamp ASC
    ) AS previous_trip_amount,
    LEAD(trip_amount, 1, 0.00) OVER (
        PARTITION BY driver_id 
        ORDER BY trip_timestamp ASC
    ) AS next_trip_amount,
    trip_amount - LAG(trip_amount, 1, trip_amount) OVER (
        PARTITION BY driver_id 
        ORDER BY trip_timestamp ASC
    ) AS revenue_difference
FROM pcte.driver_trips;
