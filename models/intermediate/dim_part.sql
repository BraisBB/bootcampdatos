{{ config(
    materialized='incremental',
    unique_key=['p_partkey', ' ps_suppkey']
) }}
WITH dim_part AS (
    SELECT 
        p_partkey, 
        ps_suppkey,
        p_partname,
        p_mfgr,
        p_brand,
        p_type,
        p_size,
        p_container,
        p_retailprice,
        ps_availqty,
        ps_supplycost
        FROM {{ ref ('stg_part') }}
        JOIN {{ ref('stg_partsupp') }} n ON p_partkey = ps_partkey
        
)

SELECT * FROM dim_part
