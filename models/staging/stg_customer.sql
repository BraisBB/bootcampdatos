WITH customer_source AS (
    SELECT 
        c_custkey,
        c_name AS c_custname,
        c_address,
        c_nationkey,
        c_phone,
        c_acctbal,
        c_mktsegment
    FROM {{ source('adrian_brais_samuel__schema', 'raw_customer') }}
)
SELECT * FROM customer_source