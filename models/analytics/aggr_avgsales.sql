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
    d.st_storenationname AS nation,
     ROUND(AVG(total_sales),2) AS average_sales
FROM 
    total_sales_per_store
JOIN {{ ref('dim_store') }} d ON storekey = d.st_storekey 
GROUP BY nation   
ORDER BY average_sales DESC
