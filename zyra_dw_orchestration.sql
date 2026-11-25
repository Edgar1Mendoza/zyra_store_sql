CREATE OR REPLACE PROCEDURE dw.load_all()
LANGUAGE plpgsql
AS $$
BEGIN
    CALL dw.load_dim_product();
    RAISE NOTICE 'dim_product loaded';

    CALL dw.load_dim_customer();
    RAISE NOTICE 'dim_customer loaded';

    CALL dw.load_dim_date();
    RAISE NOTICE 'dim_date loaded';

    CALL dw.load_fact_sales();
    RAISE NOTICE 'fact_sales loaded';

    CALL dw.validate_fact_sales();

    RAISE NOTICE 'Warehouse load completed successfully';
END;
$$;

-- CALL dw.load_all(); SELECT COUNT(*) FROM dw.fact_sales;
