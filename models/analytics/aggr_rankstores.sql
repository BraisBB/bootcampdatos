WITH total_sales_per_store AS (
    SELECT 
        storekey,
        SUM(totalprice_local_store) AS total_sales,
        d.pais AS region
    FROM 
        FROM {{ ref('fact_sales') }} 
    GROUP BY 
        storekey, d.pais
),
ranked_sales AS (
    SELECT 
        region,
        storekey,
        total_sales,
        ROW_NUMBER() OVER (PARTITION BY region ORDER BY total_sales DESC) AS rank
    FROM 
        total_sales_per_store
)
SELECT 
    region,
    storekey,
    total_sales
FROM 
    ranked_sales
WHERE 
    rank = 1;
