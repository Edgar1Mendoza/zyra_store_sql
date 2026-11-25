CREATE TABLE IF NOT EXISTS pcte.company_employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100),
    manager_id INT,
    job_title VARCHAR(50)
);

INSERT INTO pcte.company_employees (employee_id, employee_name, manager_id, job_title) VALUES 
(1, 'Alice CEO', NULL, 'Chief Executive Officer'),
(2, 'Bob Director', 1, 'Engineering Director'),
(3, 'Charlie Manager', 2, 'Data Engineering Manager'),
(4, 'Diana Lead', 3, 'Senior Data Engineer'),
(5, 'Ethan Junior', 4, 'Junior Data Engineer')
ON CONFLICT (employee_id) DO NOTHING;


WITH RECURSIVE employee_hierarchy AS (
    SELECT 
        employee_id,
        employee_name,
        manager_id,
        job_title,
        1 AS hierarchy_level,
        CAST(employee_name AS VARCHAR(255)) AS management_path
    FROM pcte.company_employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT 
        e.employee_id,
        e.employee_name,
        e.manager_id,
        e.job_title,
        eh.hierarchy_level + 1,
        CAST(eh.management_path || ' -> ' || e.employee_name AS VARCHAR(255))
    FROM pcte.company_employees AS e
    INNER JOIN employee_hierarchy AS eh 
        ON e.manager_id = eh.employee_id
)

SELECT 
    employee_id,
    employee_name,
    job_title,
    hierarchy_level,
    management_path
FROM employee_hierarchy
ORDER BY hierarchy_level;
