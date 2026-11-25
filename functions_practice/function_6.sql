CREATE TABLE IF NOT EXISTS pf.fact_trip_metrics (
    trip_id INT PRIMARY KEY,
    trip_distance NUMERIC(10, 2),
    total_amount NUMERIC(10, 2),
    trip_duration_minutes INT
);

INSERT INTO pf.fact_trip_metrics (trip_id, trip_distance, total_amount, trip_duration_minutes) VALUES  
(1, 2.50, 12.00, 8),
(2, 15.00, 45.00, 60),
(3, 8.00, 25.00, 15)
ON CONFLICT (trip_id) DO NOTHING;


-- Trip Performance Function
CREATE OR REPLACE FUNCTION pf.evaluate_trip_performance(
    p_distance NUMERIC,
    p_amount NUMERIC,
    p_duration INT
)
RETURNS VARCHAR AS $$
DECLARE
    v_avg_speed NUMERIC;
    v_performance_status VARCHAR(50);
BEGIN
    IF p_duration IS NULL OR p_duration <= 0 THEN
        RETURN 'UNKNOWN';
    END IF;

    v_avg_speed := p_distance / (p_duration / 60.0);

    IF v_avg_speed > 30.0 AND p_amount >= 20.0 THEN
        v_performance_status := 'HIGH_EFFICIENCY_HIGH_REVENUE';
    ELSIF v_avg_speed <= 15.0 THEN
        v_performance_status := 'CONGESTED_SLOW_TRIP';
    ELSE
        v_performance_status := 'STANDARD_TRIP';
    END IF;

    RETURN v_performance_status;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

SELECT 
    trip_id,
    trip_distance,
    total_amount,
    trip_duration_minutes,
    pf.evaluate_trip_performance(trip_distance, total_amount, trip_duration_minutes) AS performance_status
FROM pf.fact_trip_metrics;
