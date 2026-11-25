CREATE TABLE IF NOT EXISTS pcte.daily_metrics (
    metric_id INT PRIMARY KEY,
    metric_date DATE,
    active_users INT
);

INSERT INTO pcte.daily_metrics (metric_id, metric_date, active_users) VALUES 
(1, '2026-10-01', 100),
(2, '2026-10-02', 200),
(3, '2026-10-03', 150),
(4, '2026-10-04', 300),
(5, '2026-10-05', 250)
ON CONFLICT (metric_id) DO NOTHING;


SELECT 
    metric_id,
    metric_date,
    active_users,
    AVG(active_users) OVER (
        ORDER BY metric_date ASC
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) AS rolling_3day_avg_users
FROM pcte.daily_metrics;
