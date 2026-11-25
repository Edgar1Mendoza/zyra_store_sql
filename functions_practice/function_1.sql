CREATE SCHEMA pf; -- Practice Functions

CREATE TABLE pf.employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(100),
    hire_date DATE,
    base_salary DECIMAL(10, 2),
    email_contact VARCHAR(100),
    credit_card_number VARCHAR(30)
);

INSERT INTO pf.employees (employee_id, name, hire_date, base_salary, email_contact, credit_card_number) VALUES
(1, 'Charles Perez', '2018-03-15', 2500.00, 'Charles.Perez@GMAIL.COM', '4532-1111-2222-3333'),
(2, 'Anna Gomez', '2021-07-01', 2100.00, 'Anna.Gomez@YAHOO.COM ', '5412-4444-5555-6666'),
(3, 'Louis Torres', '2015-11-20', 3200.00, 'Louis_Torres@HOTMAIL.COM', '3782-7777-8888-9999'),
(4, 'Sophia Ramirez', '2023-01-10', 1900.00, ' Sophia.Ramirez@OUTLOOK.ES', '4532-9999-8888-7777'),
(5, 'Mary Rodriguez', '2019-06-05', 2750.00, 'Maria.Rodriguez@GMAIL.COM', '5412-3333-2222-1111'),
(6, 'Alice Smith', '2022-02-15', 2400.00, 'alice.smith@corporate.com  ', '4532-1234-5678-9012'),
(7, 'Bob Jones', '2020-09-10', 2800.00, 'bob.jones@gmail.com', '5412-7890-1234-5678'),
(8, 'Charlie Brown', '2021-05-20', 2650.00, 'charlie.brown@yahoo.com', '3782-5100-2345-678');


-- First Function: Calculate Antiquity
CREATE OR REPLACE FUNCTION pf.antiquity_calc(hire_date DATE)
RETURNS INT AS $$
BEGIN
    RETURN EXTRACT(YEAR FROM AGE(CURRENT_DATE, hire_date))::INT;
END;
$$ LANGUAGE plpgsql STABLE;

SELECT 
    name,
    hire_date,
    pf.antiquity_calc(hire_date) AS antiquity_years,
    CASE 
        WHEN pf.antiquity_calc(hire_date) >= 5 THEN 'Senior'
        WHEN pf.antiquity_calc(hire_date) >= 2 THEN 'Semi-Senior'
        ELSE 'Junior'
    END AS categoria_empleado
FROM pf.employees;
