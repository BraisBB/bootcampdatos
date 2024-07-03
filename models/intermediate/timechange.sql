WITH timechange AS (
    SELECT 
        tc_nationkey,
        tc_nationname,
        tc_adjustedtime
    FROM {{ ref('stg_timechange') }}
)

select * from timechange