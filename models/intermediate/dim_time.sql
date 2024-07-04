{{ config(
    materialized='incremental',
    unique_key='T_Timekey'
) }}

WITH dim_time AS (
    SELECT DISTINCT
        TO_CHAR(O_ORDERDATE, 'YYYYMMDDHH24MISS')::INT AS tm_datekey,
        O_ORDERDATE AS tm_date,
        EXTRACT(dayofweek FROM O_ORDERDATE) AS TM_Day_Number_of_Week,
        EXTRACT(day FROM O_ORDERDATE) AS tm_day,
        EXTRACT(month FROM O_ORDERDATE) AS tm_year,
        MONTHNAME(O_ORDERDATE) AS tm_monthname,
        EXTRACT(year FROM O_ORDERDATE) AS tm_year
    FROM {{ ref('stg_orders') }}
)
select * from dim_time