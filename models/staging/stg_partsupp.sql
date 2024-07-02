WITH partsupp_source AS (
    SELECT 
        ps_partkey,
        ps_suppkey,
        ps_availqty,
        ps_supplycost
    FROM {{ source('adrian_brais_samuel__schema', 'raw_partsupp') }}
)
SELECT * FROM partsupp_source
