-- Function to mask credit card numbers
CREATE OR REPLACE FUNCTION pf.mask_credit_card(p_cc_number TEXT)
RETURNS TEXT AS $$
BEGIN
    IF p_cc_number IS NULL OR LENGTH(p_cc_number) < 4 THEN
        RETURN '****-****-****-****';
    END IF;
    
    RETURN '****-****-****-' || RIGHT(p_cc_number, 4);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function to mask email addresses
CREATE OR REPLACE FUNCTION pf.mask_email(p_email TEXT)
RETURNS TEXT AS $$
DECLARE
    v_username TEXT;
    v_domain TEXT;
BEGIN
    IF p_email IS NULL OR POSITION('@' IN p_email) = 0 THEN
        RETURN '***@***.com';
    END IF;
    
    v_username := SPLIT_PART(p_email, '@', 1);
    v_domain := SPLIT_PART(p_email, '@', 2);
    
    RETURN LEFT(v_username, 1) || '***@' || v_domain;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

SELECT 
    employee_id,
    name,
    pf.mask_credit_card(credit_card_number) AS masked_credit_card,
    pf.mask_email(email_contact) AS masked_email
FROM pf.employees;
