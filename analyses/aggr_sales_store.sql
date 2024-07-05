-- models/analytic/aggr_sales_store.sql
WITH sales_data AS (
    SELECT *
    FROM {{ ref('fact_sales') }} 
)

SELECT 
    storekey,
    orderdate_UTC::date AS order_date,
    COUNT(DISTINCT orderkey) AS total_orders,
    SUM(quantity) AS total_quantity,
    SUM(totalprice) AS total_sales_usd,
    SUM(totalprice_local_store) AS total_sales_local
FROM sales_data
GROUP BY storekey, order_date
