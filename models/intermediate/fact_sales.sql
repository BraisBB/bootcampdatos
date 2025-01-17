{{ config(
    materialized='incremental',
    unique_key= ['linenumber', 'orderkey']
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
        s.st_storekey AS storekey,
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
        s_suppname,
        s_address,
        s_nationkey,
        s_phone,
        s_acctbal
    FROM {{ ref('stg_supplier') }}
),
part_source AS (
    SELECT 
        p_partkey,
        p_partname,
        p_mfgr,
        p_brand,
        p_type,
        p_size,
        p_container,
        p_retailprice
    FROM {{ ref('stg_part') }}
),
partsupp_source AS (
    SELECT 
        ps_partkey,
        ps_suppkey,
        ps_availqty,
        ps_supplycost
    FROM {{ ref('stg_partsupp') }}
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
timechange_source AS (
    SELECT 
        N_NATIONKEY AS tc_nationkey,
        N_NAME AS tc_nationname,
        adjusted_time AS tc_adjustedtime
    FROM {{ source('adrian_brais_samuel__schema', 'raw_timechange') }}
),
sales_data AS (
SELECT 
    l.l_linenumber AS linenumber,
    l.l_orderkey AS orderkey,
    o.clerk AS clerk,
    o.o_totalprice AS totalprice,
    o.o_totalprice * er.tipo_cambio AS totalprice_local_customer,
    (l.l_extendedprice * (1 - l.l_discount) + l.l_tax) * er.tipo_cambio AS totalprice_local_store,
    o.o_orderdate AS orderdate_UTC,
    DATEADD('SECOND', UNIFORM(0, 86400, RANDOM()),  o.o_orderdate) AS orderdate_local,
    tc.tc_adjustedtime,
    o.o_orderpriority AS orderpriority,
    o.o_orderstatus AS orderstatus,
    l.l_partkey AS partkey,
    l.l_suppkey AS suppkey,
    o.o_custkey AS custkey,
    l.l_quantity AS quantity,
    l.l_extendedprice AS extendedprice,
    l.l_discount AS discount,
    l.l_tax AS tax,
    l.tipo_operacion,
    l.l_returnflag AS returnflag,
    l.l_linestatus AS linestatus,
    l.l_shipdate AS shipdate_UTC,
    DATEADD('SECOND', UNIFORM(0, 86400, RANDOM()), l.l_shipdate) AS shipdate_local,
    l.l_commitdate AS commitdate_UTC,
    DATEADD(hour, 5, l.l_commitdate) AS commitdate_local,
    l.l_receiptdate AS receiptdate_UTC,
    DATEADD('SECOND', UNIFORM(0, 86400, RANDOM()), l.l_receiptdate) AS receiptdate_local,
   CASE 
    WHEN DATEDIFF(day, l.l_commitdate, l.l_receiptdate) > 30 THEN '0 Fuera de plazo'
    WHEN DATEDIFF(day, l.l_commitdate, l.l_receiptdate) <= 0 THEN '1 En plazo'
    WHEN DATEDIFF(day, l.l_commitdate, l.l_receiptdate) <= 10 THEN '2 Entrega tardía'
    WHEN DATEDIFF(day, l.l_commitdate, l.l_receiptdate) <= 30 THEN '3 Entrega crítica'
    ELSE 'Desconocido'
    END AS deliverytime,
    e.id_evento AS eventkey,
    d.storekey AS storekey
FROM cleaned_lineitems l
JOIN cleaned_orders o ON l.l_orderkey = o.o_orderkey
JOIN dim_store d ON l.l_orderkey = d.l_orderkey
JOIN dim_event e ON l.l_orderkey = e.o_orderkey
LEFT JOIN exchange_rates er ON d.pais = er.pais
LEFT JOIN timechange_source tc ON d.storekey = tc.tc_nationkey
    {% if is_incremental() %}
    where orderkey not in (select orderkey from {{ this }})
    {% endif %}
)
SELECT * FROM sales_data
