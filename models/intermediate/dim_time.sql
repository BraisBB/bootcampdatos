{{ config(
    materialized='incremental',
    unique_key='tm_datekey'
) }}

WITH dim_time AS (
    SELECT DISTINCT
        TO_CHAR(O_ORDERDATE, 'YYYYMMDDHH24MISS')::INT AS tm_datekey,
        O_ORDERDATE AS tm_date,
        EXTRACT(day FROM O_ORDERDATE) AS tm_day,
        CASE
            WHEN EXTRACT(dayofweek FROM O_ORDERDATE) = 0 THEN 'Sunday'
            WHEN EXTRACT(dayofweek FROM O_ORDERDATE) = 1 THEN 'Monday'
            WHEN EXTRACT(dayofweek FROM O_ORDERDATE) = 2 THEN 'Tuesday'
            WHEN EXTRACT(dayofweek FROM O_ORDERDATE) = 3 THEN 'Wednesday'
            WHEN EXTRACT(dayofweek FROM O_ORDERDATE) = 4 THEN 'Thursday'
            WHEN EXTRACT(dayofweek FROM O_ORDERDATE) = 5 THEN 'Friday'
            WHEN EXTRACT(dayofweek FROM O_ORDERDATE) = 6 THEN 'Saturday'
        END AS tm_dayname,
        EXTRACT(month FROM O_ORDERDATE) AS tm_month,
        MONTHNAME(O_ORDERDATE) AS tm_monthname,
        EXTRACT(year FROM O_ORDERDATE) AS tm_year
    FROM {{ ref('stg_orders') }}
)
select * from dim_time