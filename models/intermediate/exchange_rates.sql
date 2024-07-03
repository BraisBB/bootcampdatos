-- models/staging/stg_exchange_rates.sql

WITH nation AS (
    SELECT 
        N_NATIONKEY,
        N_NAME
    FROM {{ source('adrian_brais_samuel__schema', 'raw_nation') }}
)
SELECT 
    N_NAME AS pais,
    CASE 
        WHEN N_NAME = 'ALGERIA' THEN 1.0
        WHEN N_NAME = 'ARGENTINA' THEN 250.0
        WHEN N_NAME = 'BRAZIL' THEN 5.0
        WHEN N_NAME = 'CANADA' THEN 1.25
        WHEN N_NAME = 'EGYPT' THEN 15.7
        WHEN N_NAME = 'ETHIOPIA' THEN 45.0
        WHEN N_NAME = 'FRANCE' THEN 0.85
        WHEN N_NAME = 'GERMANY' THEN 0.85
        WHEN N_NAME = 'INDIA' THEN 75.0
        WHEN N_NAME = 'INDONESIA' THEN 14500.0
        WHEN N_NAME = 'IRAN' THEN 42000.0
        WHEN N_NAME = 'IRAQ' THEN 1450.0
        WHEN N_NAME = 'JAPAN' THEN 110.0
        WHEN N_NAME = 'JORDAN' THEN 0.71
        WHEN N_NAME = 'KENYA' THEN 110.0
        WHEN N_NAME = 'MOROCCO' THEN 9.0
        WHEN N_NAME = 'MOZAMBIQUE' THEN 63.0
        WHEN N_NAME = 'PERU' THEN 4.0
        WHEN N_NAME = 'CHINA' THEN 6.5
        WHEN N_NAME = 'ROMANIA' THEN 4.1
        WHEN N_NAME = 'SAUDI ARABIA' THEN 3.75
        WHEN N_NAME = 'VIETNAM' THEN 23000.0
        WHEN N_NAME = 'RUSSIA' THEN 74.0
        WHEN N_NAME = 'UNITED KINGDOM' THEN 0.75
        WHEN N_NAME = 'UNITED STATES' THEN 1.0
        ELSE 1.0 -- Default exchange rate if not matched
    END AS tipo_cambio,
    current_date() AS fecha
FROM nation
