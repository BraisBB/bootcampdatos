{{ config(
    materialized='incremental',
    unique_key='T_Timekey'
) }}

WITH date_elements AS (
    SELECT DISTINCT
        TO_CHAR(O_ORDERDATE, 'YYYYMMDDHH24MISS')::INT AS tm_datekey,
        O_ORDERDATE AS tm_date,
        DATE(O_ORDERDATE) AS T_Date,
        EXTRACT(dayofweek FROM O_ORDERDATE) AS T_Day_Number_of_Week,
        EXTRACT(day FROM O_ORDERDATE) AS tm_day,
        MONTHNAME(O_ORDERDATE) AS tm_monthname
        EXTRACT(year FROM O_ORDERDATE) AS TM_Year,
    FROM {{ ref('stg_orders') }}
)
select * from date_elements