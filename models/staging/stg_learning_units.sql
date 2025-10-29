{{
  config(
    materialized='view'
  )
}}

WITH source AS (
  SELECT * FROM {{ source('raw_data', 'learning_units') }}
),

cleaned AS (
  SELECT
    learning_unit_id,
    unit_name,
    grade_level,
    sequence_order,
    
    CURRENT_TIMESTAMP() AS _loaded_at
    
  FROM source
)

SELECT * FROM cleaned