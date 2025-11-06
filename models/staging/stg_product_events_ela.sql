{{ config(
    materialized='view'
) }}

SELECT
    id AS event_id,
    userId AS user_id,
    
    verb,
    object,
    product,
    
    TIMESTAMP(timestamp) AS event_timestamp,
    DATE(timestamp) AS event_date,
    
    CURRENT_TIMESTAMP() AS _loaded_at
    
FROM {{ source('raw_data', 'ela_events') }}
WHERE id IS NOT NULL
  AND userid IS NOT NULL
  AND TIMESTAMP(timestamp) <= CURRENT_TIMESTAMP()