-- models/analytic/aggr_sales_store.sql
WITH sales_data AS (
    SELECT *
    FROM {{ ref('fact_sales') }} 
)

SELECT 
    tienda,
    fecha_pedido::date AS order_date,
    COUNT(DISTINCT l_orderkey) AS total_orders,
    SUM(l_quantity) AS total_quantity,
    SUM(totalprice_usd) AS total_sales_usd,
    SUM(totalprice_local_store) AS total_sales_local
FROM sales_data
GROUP BY tienda, fecha_pedido::date;
