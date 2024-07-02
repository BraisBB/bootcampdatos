with nation_source as (

    select
        n_nationkey,
        n_name,
        n_regionkey

    from {{ source('adrian_brais_samuel__schema', 'raw_nation') }}

)
select * from nation_source