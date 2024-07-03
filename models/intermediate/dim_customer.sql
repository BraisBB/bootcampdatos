WITH customer_transformation AS (
    SELECT 
        c.c_custkey,
        c.c_name AS c_custname,
        c.c_address,
        n.n_name AS c_custnationname,
        r.r_regionkey AS c_custregionname,
        c.c_phone,
        c.c_acctbal,
        c.c_mktsegment
    FROM {{ ref('stg_customer') }} c
    LEFT JOIN {{ ref('stg_nation') }} n ON c.c_nationkey = n.n_nationkey
    LEFT JOIN {{ ref('stg_region') }} r ON n.n_regionkey = r.r_regionkey
)
SELECT * FROM customer_transformation;