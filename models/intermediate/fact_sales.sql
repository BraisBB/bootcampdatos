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
store_transformation AS (
    SELECT 
        st_storekey,
        st_storename,
        st_storenationname
    FROM {{ ref('stg_store') }}
),
dim_store AS (
    SELECT 
        l.l_orderkey,
        s.st_storename AS tienda,
        s.st_storenationname AS pais
    FROM {{ ref('stg_lineitem') }} l
    JOIN store_transformation s ON MOD(ABS(l.l_orderkey), 100) + 1 = s.st_storekey
),
event_source AS (
    SELECT 
        ev_eventkey,
        ev_eventname,
        ev_eventnationame,
        ev_startdate,
        ev_enddate
    FROM {{ source('adrian_brais_samuel__schema', 'raw_event') }}
),
dim_event AS (
    SELECT 
        e.ev_eventkey,
        e.ev_eventname,
        e.ev_eventnationame,
        e.ev_startdate,
        e.ev_enddate,
        o.o_orderkey,
        CASE 
            WHEN o.o_orderdate BETWEEN e.ev_startdate AND e.ev_enddate THEN e.ev_eventkey
            ELSE NULL
        END AS id_evento
    FROM event_source e
    JOIN cleaned_orders o ON o.o_orderdate BETWEEN e.ev_startdate AND e.ev_enddate
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
    FROM cleaned_lineitems l
    JOIN cleaned_orders o ON l.l_orderkey = o.o_orderkey
    JOIN dim_store d ON l.l_orderkey = d.l_orderkey
    JOIN dim_event e ON l.l_orderkey = e.o_orderkey
    LEFT JOIN exchange_rates er ON d.pais = er.pais
)
SELECT * FROM sales_data
