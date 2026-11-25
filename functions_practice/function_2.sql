CREATE OR REPLACE FUNCTION pf.normalize_email(email_contact TEXT)
RETURNS TEXT AS $$
BEGIN
    IF email_contact IS NULL THEN
        RETURN NULL;
    END IF;
    
    RETURN LOWER(TRIM(email_contact));
END;
$$ LANGUAGE plpgsql IMMUTABLE;

SELECT 
    employee_id,
    name,
    pf.normalize_email(email_contact) AS clean_email
FROM pf.employees;
