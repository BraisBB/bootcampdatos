WITH store_source AS (
    SELECT 
        st_storekey,
        st_storename,
        st_storenationname
    FROM {{ source('adrian_brais_samuel__schema', 'raw_orders') }}
)
SELECT * FROM store_source
