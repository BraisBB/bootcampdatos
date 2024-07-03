WITH supplier_source AS (
    SELECT 
        s_suppkey,
        s_name AS s_suppname,
        s_address,
        s_nationkey,
        s_phone,
        s_acctbal
    FROM {{ source('adrian_brais_samuel__schema', 'raw_supplier') }} 
)
SELECT * FROM supplier_source