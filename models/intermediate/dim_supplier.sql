WITH supplier_transformation AS (
    SELECT 
        s.s_suppkey,
        s.s_suppname,
        s.s_address,
        n.n_name AS s_suppnationname,
        r.r_regionkey AS s_suppregionname,
        s.s_phone,
        s.s_acctbal
    FROM {{ ref('stg_supplier') }} s
    LEFT JOIN {{ ref('stg_nation') }} n ON s.s_nationkey = n.n_nationkey
    LEFT JOIN {{ ref('stg_region') }} r ON n.n_regionkey = r.r_regionkey
)
SELECT * FROM supplier_transformation