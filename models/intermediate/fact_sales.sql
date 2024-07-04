{{ config(
    materialized='incremental',
    unique_key= ['l.l_linenumber', 'l.l_orderkey']
) }}

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
        l_linenumber,
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
    FROM cleaned_lineitems l
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
customer_transformation AS (
    SELECT 
        c.c_custkey,
        c.c_custname,
        c.c_address,
        n.n_name AS c_custnationname,
        r.r_regionkey AS c_custregionname,
        c.c_phone,
        c.c_acctbal,
        c.c_mktsegment
    FROM {{ ref('stg_customer') }} c
    LEFT JOIN {{ ref('stg_nation') }} n ON c.c_nationkey = n.n_nationkey
    LEFT JOIN {{ ref('stg_region') }} r ON n.n_regionkey = r.r_regionkey
),
dim_customer AS (
    SELECT
        c.c_custkey,
        c.c_custname,
        c.c_address,
        c.c_custnationname,
        c.c_custregionname,
        c.c_phone,
        c.c_acctbal,
        c.c_mktsegment
    FROM customer_transformation c
),
supplier_source AS (
    SELECT 
        s_suppkey,
        s_name AS s_suppname,
        s_address,
        s_nationkey,
        s_phone,
        s_acctbal
    FROM {{ source('adrian_brais_samuel__schema', 'raw_supplier') }}
),
part_source AS (
    SELECT 
        p_partkey,
        p_name AS p_partname,
        p_mfgr,
        p_brand,
        p_type,
        p_size,
        p_container,
        p_retailprice
    FROM {{ source('adrian_brais_samuel__schema', 'raw_part') }}
),
partsupp_source AS (
    SELECT 
        ps_partkey,
        ps_suppkey,
        ps_availqty,
        ps_supplycost
    FROM {{ source('adrian_brais_samuel__schema', 'raw_partsupp') }}
),
dim_supplier AS (
    SELECT
        ps.ps_partkey,
        ps.ps_suppkey,
        p.p_partname,
        p.p_mfgr,
        p.p_brand,
        p.p_type,
        p.p_size,
        p.p_container,
        p.p_retailprice,
        s.s_suppname,
        s.s_address AS s_supplier_address,
        n.n_name AS s_supplier_nationname,
        r.r_regionkey AS s_supplier_regionname,
        s.s_phone,
        s.s_acctbal,
        ps.ps_availqty,
        ps.ps_supplycost
    FROM partsupp_source ps
    JOIN supplier_source s ON ps.ps_suppkey = s.s_suppkey
    JOIN part_source p ON ps.ps_partkey = p.p_partkey
    LEFT JOIN {{ ref('stg_nation') }} n ON s.s_nationkey = n.n_nationkey
    LEFT JOIN {{ ref('stg_region') }} r ON n.n_regionkey = r.r_regionkey
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
        l.l_linenumber,
        o.o_custkey,
        c.c_custname,
        c.c_address,
        c.c_custnationname,
        c.c_custregionname,
        c.c_phone,
        c.c_acctbal,
        c.c_mktsegment,
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
        END AS plazo_entrega,
        s.p_partname,
        s.p_mfgr,
        s.p_brand,
        s.p_type,
        s.p_size,
        s.p_container,
        s.p_retailprice,
        s.s_suppname,
        s.s_supplier_address,
        s.s_supplier_nationname,
        s.s_supplier_regionname,
        s.s_phone,
        s.s_acctbal,
        s.ps_availqty,
        s.ps_supplycost
    FROM cleaned_lineitems l
    JOIN cleaned_orders o ON l.l_orderkey = o.o_orderkey
    JOIN dim_store d ON l.l_orderkey = d.l_orderkey
    JOIN dim_event e ON l.l_orderkey = e.o_orderkey
    JOIN dim_customer c ON o.o_custkey = c.c_custkey
    JOIN dim_supplier s ON l.l_partkey = s.ps_partkey AND l.l_suppkey = s.ps_suppkey
    LEFT JOIN exchange_rates er ON d.pais = er.pais
)
SELECT * FROM sales_data
