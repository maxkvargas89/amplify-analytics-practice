{{
  config(
    materialized='view'
  )
}}

WITH source AS (
  SELECT * FROM {{ source('raw_data', 'schools') }}
),

cleaned AS (
  SELECT
    school_id,
    school_name,
    school_type,
    student_count,
    free_reduced_lunch_pct,
    
    CASE
      WHEN free_reduced_lunch_pct >= 0.75 THEN 'high_poverty'
      WHEN free_reduced_lunch_pct >= 0.40 THEN 'moderate_poverty'
      ELSE 'low_poverty'
    END AS poverty_level,
    
    CURRENT_TIMESTAMP() AS _loaded_at
    
  FROM source
)

SELECT * FROM cleaned