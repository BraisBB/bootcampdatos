WITH customer_source AS (
    SELECT 
        c.c_custkey,
        c.c_name AS c_custname,
        c.c_address,
        c.c_nationkey AS c_custnationregion,
        c.c_phone,
        c.c_acctbal,
        c.c_mktsegment,
        n.nationname AS c_custnationname
    FROM {{ ref('stg_customer') }} c
    LEFT JOIN {{ ref('stg_nation') }} n ON c.c_nationkey = n.nationkey
)
SELECT * FROM customer_source;