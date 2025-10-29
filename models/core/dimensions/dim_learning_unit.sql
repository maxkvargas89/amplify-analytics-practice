{{
  config(
    materialized='table'
  )
}}

WITH learning_units AS (
  SELECT * FROM {{ ref('stg_learning_units') }}
),

final AS (
  SELECT
    learning_unit_id,
    unit_name,
    grade_level,
    sequence_order,
    _loaded_at
    
  FROM learning_units
)

SELECT * FROM final