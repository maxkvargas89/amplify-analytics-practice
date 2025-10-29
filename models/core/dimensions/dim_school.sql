{{
  config(
    materialized='table'
  )
}}

WITH schools AS (
  SELECT * FROM {{ ref('stg_schools') }}
),

final AS (
  SELECT
    school_id,
    school_name,
    school_type,
    student_count,
    free_reduced_lunch_pct,
    poverty_level,
    _loaded_at
    
  FROM schools
)

SELECT * FROM final