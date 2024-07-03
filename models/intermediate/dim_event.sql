WITH dim_event AS (
SELECT 
    ev_eventkey ,
    ev_eventname ,
    ev_eventnationame ,
    ev_startdate ,
    ev_enddate 
FROM {{ ref('stg_event') }}
)
 SELECT * FROM dim_event