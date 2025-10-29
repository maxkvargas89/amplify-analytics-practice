{{
  config(
    materialized='view'
  )
}}

WITH source AS (
  SELECT * FROM {{ source('raw_data', 'student_events') }}
),

cleaned AS (
  SELECT
    event_id,
    student_id,
    school_id,
    event_timestamp,
    
    DATE(event_timestamp) AS event_date,
    
    event_type,
    learning_unit_id,
    
    CASE 
      WHEN event_type = 'problem_attempt' THEN event_metadata.correct
      ELSE NULL
    END AS problem_correct,
    
    CASE 
      WHEN event_type = 'problem_attempt' THEN event_metadata.time_seconds
      ELSE NULL
    END AS problem_time_seconds,
    
    CURRENT_TIMESTAMP() AS _loaded_at
    
  FROM source
)

SELECT * FROM cleaned