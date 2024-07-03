WITH timechange_source AS (
    SELECT 
        N_NATIONKEY AS tc_nationkey,
        N_NAME AS tc_nationname,
        adjusted_time AS tc_adjustedtime
    FROM {{ source('adrian_brais_samuel__schema', 'raw_timechange') }}
)
SELECT * FROM timechange_source