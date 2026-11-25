CREATE TABLE IF NOT EXISTS pcte.user_sessions (
    session_id INT PRIMARY KEY,
    user_id INT,
    session_timestamp TIMESTAMP,
    device_type VARCHAR(20)
);

INSERT INTO pcte.user_sessions (session_id, user_id, session_timestamp, device_type) VALUES 
(101, 1, '2026-10-19 08:00:00', 'MOBILE'),
(102, 1, '2026-10-19 14:30:00', 'DESKTOP'),
(103, 2, '2026-10-19 09:15:00', 'TABLET'),
(104, 3, '2026-10-19 10:00:00', 'MOBILE'),
(105, 3, '2026-10-19 16:45:00', 'DESKTOP')
ON CONFLICT (session_id) DO NOTHING;


WITH ranked_sessions AS (
    SELECT 
        session_id,
        user_id,
        session_timestamp,
        device_type,
        ROW_NUMBER() OVER (
            PARTITION BY user_id 
            ORDER BY session_timestamp DESC
        ) AS row_num
    FROM pcte.user_sessions
)

SELECT 
    session_id,
    user_id,
    session_timestamp,
    device_type
FROM ranked_sessions
WHERE row_num = 1;
