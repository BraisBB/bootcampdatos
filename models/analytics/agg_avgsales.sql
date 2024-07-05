WITH total_sales_per_store AS (
    SELECT 
        storekey,
        SUM(totalprice_local_store) AS total_sales
    FROM 
        {{ ref('fact_sales') }}
    GROUP BY 
        storekey
)
SELECT 
    AVG(total_sales) AS average_sales
FROM 
    total_sales_per_store;
