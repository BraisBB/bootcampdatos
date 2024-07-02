with region_source as (

    select
        r_regionkey,
        r_name
        
    from {{ source('adrian_brais_samuel__schema', 'raw_region') }}

)
select * from region_source
