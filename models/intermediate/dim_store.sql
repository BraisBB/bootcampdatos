WITH store_transformation AS (
    SELECT 
        st_storekey,
        st_storename,
        st_storenationname
    FROM {{ ref('stg_store') }}
)
SELECT * FROM store_transformation