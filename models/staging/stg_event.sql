WITH event_source AS (
    SELECT 
        ev_eventkey ,
        ev_eventname ,
        ev_eventnationame ,
        ev_startdate ,
        ev_enddate 
    FROM {{ source('adrian_brais_samuel__schema', 'raw_event') }}
)
SELECT * FROM event_source