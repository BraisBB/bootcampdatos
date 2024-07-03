WITH store_source AS (
    SELECT 
        st_storekey,
        st_storename,
        st_storenationname
    FROM {{ source('adrian_brais_samuel__schema', 'raw_store') }}
)
SELECT * FROM store_source
