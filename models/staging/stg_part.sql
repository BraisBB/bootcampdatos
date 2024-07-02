WITH part_source AS (
    SELECT 
        p_partkey,
        p_name AS p_partname,
        p_mfgr,
        p_brand,
        p_type,
        p_size,
        p_container,
        p_retailprice
    FROM {{ source('adrian_brais_samuel__schema', 'raw_part') }}
)
SELECT * FROM part_source
