-- models/facts/fact_sales.sql
WITH cleaned_orders AS (
    SELECT 
        o_orderkey,
        o_custkey,
        CAST(REGEXP_REPLACE(o_clerk, '[^0-9]', '') AS NUMBER) AS clerk,
        o_orderstatus,
        o_totalprice,
        o_orderdate,
        o_orderpriority,
        o_shippriority
    FROM {{ ref('stg_orders') }}
),
cleaned_lineitems AS (
    SELECT 
        l_orderkey,
        l_partkey,
        l_suppkey,
        l_quantity,
        l_extendedprice,
        l_discount,
        l_tax,
        l_returnflag,
        l_linestatus,
        l_shipdate,
        l_commitdate,
        l_receiptdate,
        CASE 
            WHEN l_returnflag = 'R' THEN 'Devolución'
            ELSE 'Venta'
        END AS tipo_operacion
    FROM {{ ref('stg_lineitem') }}
    WHERE l_linestatus != 'C' -- Excluir artículos anulados
),
dimension_store AS (
    SELECT 
        l_orderkey,
        'Store_' || CAST(ABS(MOD(l_orderkey, 100)) AS STRING) AS tienda,
        CASE 
            WHEN ABS(MOD(l_orderkey, 5)) = 0 THEN 'UNITED STATES'
            WHEN ABS(MOD(l_orderkey, 5)) = 1 THEN 'CANADA'
            WHEN ABS(MOD(l_orderkey, 5)) = 2 THEN 'MEXICO'
            WHEN ABS(MOD(l_orderkey, 5)) = 3 THEN 'UNITED KINGDOM'
            ELSE 'GERMANY'
        END AS pais
    FROM {{ ref('stg_lineitem') }}
),
dimension_event AS (
    SELECT 
        l_orderkey,
        CASE 
            WHEN l_shipdate BETWEEN '2023-11-01' AND '2023-11-30' THEN 'Black Friday'
            WHEN l_shipdate BETWEEN '2023-12-01' AND '2023-12-31' THEN 'Holiday Sale'
            ELSE 'Regular'
        END AS id_evento
    FROM {{ ref('stg_lineitem') }}
),
exchange_rates AS (
    SELECT 
        pais,
        tipo_cambio,
        fecha
    FROM {{ ref('exchange_rates') }}
),
sales_data AS (
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
        DATEADD(hour, 5, o.o_orderdate) AS orderdate_local_store, -- Simulación de la conversión de zona horaria
        DATEADD(hour, 5, o.o_orderdate) AS orderdate_local_customer, -- Simulación de la conversión de zona horaria
        l.l_shipdate AS shipdate_UTC,
        DATEADD(hour, 5, l.l_shipdate) AS shipdate_local,
        l.l_commitdate AS commitdate_UTC,
        DATEADD(hour, 5, l.l_commitdate) AS commitdate_local,
        l.l_receiptdate AS receiptdate_UTC,
        DATEADD(hour, 5, l.l_receiptdate) AS receiptdate_local,
        CASE 
            WHEN DATEDIFF(day, l.l_shipdate, l.l_receiptdate) <= 10 THEN 'En plazo'
            WHEN DATEDIFF(day, l.l_shipdate, l.l_receiptdate) <= 20 THEN 'Retraso moderado'
            ELSE 'Retraso considerable'
        END AS plazo_entrega
    FROM cleaned_lineitems l
    JOIN cleaned_orders o ON l.l_orderkey = o.o_orderkey
    JOIN dimension_store d ON l.l_orderkey = d.l_orderkey
    JOIN dimension_event e ON l.l_orderkey = e.l_orderkey
    LEFT JOIN exchange_rates er ON d.pais = er.pais
)
SELECT * FROM sales_data
