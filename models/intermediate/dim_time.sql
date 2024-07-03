CREATE TABLE dim_time (
    tm_datekey INT PRIMARY KEY,
    tm_date DATE,
    tm_day TINYINT,
    tm_dayname VARCHAR(10),
    tm_month TINYINT,
    tm_monthname VARCHAR(10),
    tm_year SMALLINT,
    tm_hour TINYINT
);

INSERT INTO dim_time (tm_datekey, tm_date, tm_day, tm_dayname, tm_month, tm_monthname, tm_year, tm_hour)
WITH dates AS (
    SELECT orderdate AS date
    FROM {{ ref('stg_orders') }}
)
SELECT 
    EXTRACT(EPOCH FROM date)::INT AS tm_datekey,
    date,
    EXTRACT(DAY FROM date)::TINYINT AS tm_day,
    TO_CHAR(date, 'Day') AS tm_dayname,
    EXTRACT(MONTH FROM date)::TINYINT AS tm_month,
    TO_CHAR(date, 'Month') AS tm_monthname,
    EXTRACT(YEAR FROM date)::SMALLINT AS tm_year,
    EXTRACT(HOUR FROM date)::TINYINT AS tm_hour
FROM dates;
