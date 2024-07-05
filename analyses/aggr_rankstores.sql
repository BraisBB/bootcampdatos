WITH total_sales_per_store AS (
    SELECT 
        s.storekey,
        SUM(s.totalprice_local_store) AS total_sales,
        d.st_storenationname AS nation
    FROM  {{ ref('fact_sales') }} s
    JOIN {{ ref('dim_store') }} d ON s.storekey = d.st_storekey 
    GROUP BY 
        s.storekey, nation
),
ranked_sales AS (
    SELECT 
        nation,
        storekey,
        total_sales,
        ROW_NUMBER() OVER (PARTITION BY nation ORDER BY total_sales DESC) AS rank
    FROM 
        total_sales_per_store
)
SELECT 
    nation,
    storekey,
    total_sales
FROM 
    ranked_sales
WHERE 
    rank = 1
