-- models/analytic/aggr_sales_store.sql

{{ config(
    materialized='incremental',
    unique_key='store_key_order_date'
) }}

WITH sales_data AS (
    SELECT 
        l.l_orderkey,
        o.o_custkey,
        l.l_partkey,
        l.l_quantity,
        l.l_extendedprice,
        l.l_discount,
        l.l_tax,
        l.tipo_operacion,
        o.clerk,
        o.o_orderdate AS fecha_pedido,
        l.l_shipdate AS fecha_envio,
        l.l_receiptdate AS fecha_recepcion,
        o.o_totalprice AS totalprice,
        e.id_evento,
        d.tienda,
        d.pais AS pais_tienda,
        er.tipo_cambio AS tipo_cambio_tienda,
        l.l_extendedprice * (1 - l.l_discount) + l.l_tax AS totalprice_usd,
        (l.l_extendedprice * (1 - l.l_discount) + l.l_tax) * er.tipo_cambio AS totalprice_local_store,
        o.o_totalprice * er.tipo_cambio AS totalprice_local_customer,
        o.o_orderdate AS orderdate_UTC,
        DATEADD('SECOND', UNIFORM(0, 86400, RANDOM()),  o.o_orderdate) AS orderdate_local_store, -- Simulación de la conversión de zona horaria
        DATEADD('SECOND', UNIFORM(0, 86400, RANDOM()),  o.o_orderdate) AS orderdate_local_customer, -- Simulación de la conversión de zona horaria
        l.l_shipdate AS shipdate_UTC,
        DATEADD('SECOND', UNIFORM(0, 86400, RANDOM()), l.l_shipdate) as shipdate_local,
        l.l_commitdate AS commitdate_UTC,
        DATEADD(hour, 5, l.l_commitdate) AS commitdate_local,
        l.l_receiptdate AS receiptdate_UTC,
        DATEADD('SECOND', UNIFORM(0, 86400, RANDOM()), l.l_receiptdate) as receiptdate_local,
        CASE 
            WHEN DATEDIFF(day, l.l_shipdate, l.l_receiptdate) <= 10 THEN 'En plazo'
            WHEN DATEDIFF(day, l.l_shipdate, l.l_receiptdate) <= 20 THEN 'Retraso moderado'
            ELSE 'Retraso considerable'
        END AS plazo_entrega
    FROM {{ ref('stg_lineitem') }} l
    JOIN {{ ref('stg_orders') }} o ON l.l_orderkey = o.o_orderkey
    JOIN {{ ref('dim_store') }} d ON l.l_orderkey = d.l_orderkey
    JOIN {{ ref('dim_event') }} e ON l.l_orderkey = e.o_orderkey
    LEFT JOIN {{ ref('exchange_rates') }} er ON d.pais = er.pais
)

SELECT 
    tienda,
    fecha_pedido::date AS order_date,
    COUNT(DISTINCT l_orderkey) AS total_orders,
    SUM(l_quantity) AS total_quantity,
    SUM(totalprice_usd) AS total_sales_usd,
    SUM(totalprice_local_store) AS total_sales_local
FROM sales_data
GROUP BY tienda, fecha_pedido::date
