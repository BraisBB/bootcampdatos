WITH orders_source AS (
    SELECT 
        o_orderkey,
        o_custkey,
        o_orderstatus,
        o_totalprice,
        o_orderdate,
        o_clerk,
        o_orderpriority,
        o_shippriority
    FROM {{ source('adrian_brais_samuel__schema', 'raw_orders') }}
)
SELECT * FROM orders_source
