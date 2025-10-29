{{
  config(
    materialized='view'
  )
}}

WITH source AS (
  SELECT * FROM {{ source('raw_data', 'student_roster') }}
),

cleaned AS (
  SELECT
    student_id,
    first_name,
    last_name,
    
    CONCAT(first_name, ' ', last_name) AS full_name,
    
    school_id,
    grade_level,
    special_education,
    ethnicity,
    
    effective_date,
    
    COALESCE(end_date, DATE('9999-12-31')) AS end_date,
    
    end_date IS NULL AS is_current,
    
    CURRENT_TIMESTAMP() AS _loaded_at
    
  FROM source
)

SELECT * FROM cleaned