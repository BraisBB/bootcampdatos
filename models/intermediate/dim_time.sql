{{ config(
    materialized='incremental',
    unique_key='T_Timekey'
) }}

WITH date_elements AS (
    SELECT DISTINCT
        TO_CHAR(O_ORDERDATE, 'YYYYMMDDHH24MISS')::INT AS T_Timekey,
        O_ORDERDATE AS T_SQL_Date_Stamp,
        DATE(O_ORDERDATE) AS T_Date,
        EXTRACT(dayofweek FROM O_ORDERDATE) AS T_Day_Number_of_Week,
        EXTRACT(day FROM O_ORDERDATE) AS T_Day_Number_of_Month,
        EXTRACT(dayofyear FROM O_ORDERDATE) AS T_Day_Number_of_Year,
        EXTRACT(weekofyear FROM O_ORDERDATE) AS T_Calendar_Week_Number_in_Year,
        MONTHNAME(O_ORDERDATE) AS T_Calendar_Month_Name,
        MONTH(O_ORDERDATE) AS T_Calendar_Month_Number_In_Year,
        TO_CHAR(O_ORDERDATE, 'YYYY-MM') AS T_Calendar_Year_Month,
        DATE_PART(quarter, O_ORDERDATE) AS T_Calendar_Quarter,
        CASE
            WHEN  T_Calendar_Quarter IN (1, 2) THEN 'First Half'
            ELSE 'Second Half'
        END AS T_Calendar_Half_Year,
        EXTRACT(year FROM O_ORDERDATE) AS T_Calendar_Year,
        CASE
            WHEN T_Day_Number_of_Week IN (1, 5) THEN 'Weekday'
            ELSE 'Weekend'
        END AS T_Weekday_Indicator
    FROM {{ ref('stg_orders') }}
),

date_elements_customer AS (
    SELECT DISTINCT
        TO_CHAR(CONVERT_TIMEZONE('UTC', N_TIMEZONE, O_ORDERDATE), 'YYYYMMDDHH24MISS')::INT AS T_Timekey,
        CONVERT_TIMEZONE('UTC', N_TIMEZONE, O_ORDERDATE) AS T_SQL_Date_Stamp,
        DATE(CONVERT_TIMEZONE('UTC', N_TIMEZONE, O_ORDERDATE)) AS T_Date,
        EXTRACT(dayofweek FROM CONVERT_TIMEZONE('UTC', N_TIMEZONE, O_ORDERDATE)) AS T_Day_Number_of_Week,
        EXTRACT(day FROM CONVERT_TIMEZONE('UTC', N_TIMEZONE, O_ORDERDATE)) AS T_Day_Number_of_Month,
        EXTRACT(dayofyear FROM CONVERT_TIMEZONE('UTC', N_TIMEZONE, O_ORDERDATE)) AS T_Day_Number_of_Year,
        EXTRACT(weekofyear FROM CONVERT_TIMEZONE('UTC', N_TIMEZONE, O_ORDERDATE)) AS T_Calendar_Week_Number_in_Year,
        MONTHNAME(CONVERT_TIMEZONE('UTC', N_TIMEZONE, O_ORDERDATE)) AS T_Calendar_Month_Name,
        MONTH(CONVERT_TIMEZONE('UTC', N_TIMEZONE, O_ORDERDATE)) AS T_Calendar_Month_Number_In_Year,
        TO_CHAR(CONVERT_TIMEZONE('UTC', N_TIMEZONE, O_ORDERDATE), 'YYYY-MM') AS T_Calendar_Year_Month,
        DATE_PART(quarter, CONVERT_TIMEZONE('UTC', N_TIMEZONE, O_ORDERDATE)) AS T_Calendar_Quarter,
        CASE
            WHEN  T_Calendar_Quarter IN (1, 2) THEN 'First Half'
            ELSE 'Second Half'
        END AS T_Calendar_Half_Year,
        EXTRACT(year FROM CONVERT_TIMEZONE('UTC', N_TIMEZONE, O_ORDERDATE)) AS T_Calendar_Year,
        CASE
            WHEN T_Day_Number_of_Week IN (1, 5) THEN 'Weekday'
            ELSE 'Weekend'
        END AS T_Weekday_Indicator
    FROM {{ ref('stg_orders') }}
    JOIN {{ ref('stg_customer') }} ON O_CUSTKEY = C_CUSTKEY
    JOIN {{ ref('stg_nation') }} ON C_NATIONKEY = N_NATIONKEY
    WHERE T_Timekey
    NOT IN (SELECT T_Timekey FROM date_elements)
),

date_elements_store AS (
    SELECT DISTINCT
        TO_CHAR(CONVERT_TIMEZONE('UTC', N_TIMEZONE, O_ORDERDATE), 'YYYYMMDDHH24MISS')::INT AS T_Timekey,
        CONVERT_TIMEZONE('UTC', N_TIMEZONE, O_ORDERDATE) AS T_SQL_Date_Stamp,
        DATE(CONVERT_TIMEZONE('UTC', N_TIMEZONE, O_ORDERDATE)) AS T_Date,
        EXTRACT(dayofweek FROM CONVERT_TIMEZONE('UTC', N_TIMEZONE, O_ORDERDATE)) AS T_Day_Number_of_Week,
        EXTRACT(day FROM CONVERT_TIMEZONE('UTC', N_TIMEZONE, O_ORDERDATE)) AS T_Day_Number_of_Month,
        EXTRACT(dayofyear FROM CONVERT_TIMEZONE('UTC', N_TIMEZONE, O_ORDERDATE)) AS T_Day_Number_of_Year,
        EXTRACT(weekofyear FROM CONVERT_TIMEZONE('UTC', N_TIMEZONE, O_ORDERDATE)) AS T_Calendar_Week_Number_in_Year,
        MONTHNAME(CONVERT_TIMEZONE('UTC', N_TIMEZONE, O_ORDERDATE)) AS T_Calendar_Month_Name,
        MONTH(CONVERT_TIMEZONE('UTC', N_TIMEZONE, O_ORDERDATE)) AS T_Calendar_Month_Number_In_Year,
        TO_CHAR(CONVERT_TIMEZONE('UTC', N_TIMEZONE, O_ORDERDATE), 'YYYY-MM') AS T_Calendar_Year_Month,
        DATE_PART(quarter, CONVERT_TIMEZONE('UTC', N_TIMEZONE, O_ORDERDATE)) AS T_Calendar_Quarter,
        CASE
            WHEN  T_Calendar_Quarter IN (1, 2) THEN 'First Half'
            ELSE 'Second Half'
        END AS T_Calendar_Half_Year,
        EXTRACT(year FROM CONVERT_TIMEZONE('UTC', N_TIMEZONE, O_ORDERDATE)) AS T_Calendar_Year,
        CASE
            WHEN T_Day_Number_of_Week IN (1, 5) THEN 'Weekday'
            ELSE 'Weekend'
        END AS T_Weekday_Indicator
    FROM {{ ref('stg_orders') }}
    JOIN {{ ref('stg_store') }} ON O_STOREKEY = ST_STOREKEY
    JOIN {{ ref('stg_nation') }} ON ST_NATIONKEY = N_NATIONKEY
    WHERE T_TIMEKEY
    NOT IN (SELECT T_TIMEKEY FROM date_elements UNION SELECT T_TIMEKEY FROM date_elements_customer)
)

SELECT *
FROM date_elements
UNION ALL
SELECT *
FROM date_elements_customer
UNION ALL
SELECT *
FROM date_elements_store 
