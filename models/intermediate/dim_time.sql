CREATE TABLE dim_time (
    datekey INT PRIMARY KEY,
    date DATE,
    day TINYINT,
    dayname VARCHAR(10),
    month TINYINT,
    monthname VARCHAR(10),
    year SMALLINT,
    hour TINYINT
);

INSERT INTO dim_time (datekey, date, day, dayname, month, monthname, year, hour)
WITH dates AS (
    SELECT orderdate AS date
    FROM {{ ref('stg_orders') }}
)
SELECT 
    EXTRACT(EPOCH FROM date)::INT AS datekey,
    date,
    EXTRACT(DAY FROM date)::TINYINT AS day,
    TO_CHAR(date, 'Day') AS dayname,
    EXTRACT(MONTH FROM date)::TINYINT AS month,
    TO_CHAR(date, 'Month') AS monthname,
    EXTRACT(YEAR FROM date)::SMALLINT AS year,
    EXTRACT(HOUR FROM date)::TINYINT AS hour
FROM dates;